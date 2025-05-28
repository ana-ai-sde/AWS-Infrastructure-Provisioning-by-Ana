#!/bin/bash

# Common functions for all environments

# Logging setup
LOG_DIR="/var/log/recovery/${ENVIRONMENT}"
LOG_FILE="${LOG_DIR}/recovery-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
    local level=$1
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] [${ENVIRONMENT}] $*" | tee -a "${LOG_FILE}"
}

# Function to send notifications to multiple channels
notify_all() {
    local message=$1
    local color=${2:-"good"}
    
    for channel in ${NOTIFICATION_CHANNELS}; do
        case ${channel} in
            slack)
                notify_slack "${message}" "${color}"
                ;;
            pagerduty)
                notify_pagerduty "${message}" "${color}"
                ;;
            *)
                log "WARN" "Unknown notification channel: ${channel}"
                ;;
        esac
    done
}

# Function to verify component health
verify_component_health() {
    local namespace=$1
    local component=$2
    local retries=${3:-${HEALTH_CHECK_RETRIES}}
    local interval=${4:-${HEALTH_CHECK_INTERVAL}}

    log "INFO" "Verifying health of ${component} in namespace ${namespace}"

    for ((i=1; i<=${retries}; i++)); do
        if kubectl get pods -n "${namespace}" -l "app=${component}" | grep -q "Running"; then
            log "INFO" "Component ${component} is healthy"
            return 0
        fi
        log "WARN" "Health check attempt ${i}/${retries} failed for ${component}"
        sleep "${interval}"
    done

    log "ERROR" "Component ${component} failed health check"
    return 1
}

# Function to verify data consistency
verify_data_consistency() {
    local namespace=$1
    
    log "INFO" "Verifying data consistency in namespace ${namespace}"

    # Check ConfigMaps
    local configmaps_before=$(kubectl get configmaps -n "${namespace}" -o json | jq '.items | length')
    local configmaps_after=$(kubectl get configmaps -n "${namespace}" -o json | jq '.items | length')
    if [ "${configmaps_before}" != "${configmaps_after}" ]; then
        log "ERROR" "ConfigMap count mismatch in ${namespace}"
        return 1
    fi

    # Check Secrets
    local secrets_before=$(kubectl get secrets -n "${namespace}" -o json | jq '.items | length')
    local secrets_after=$(kubectl get secrets -n "${namespace}" -o json | jq '.items | length')
    if [ "${secrets_before}" != "${secrets_after}" ]; then
        log "ERROR" "Secret count mismatch in ${namespace}"
        return 1
    fi

    return 0
}

# Common recovery steps
common_recovery_steps() {
    log "INFO" "Starting common recovery steps"

    # Verify AWS credentials
    if ! aws sts get-caller-identity &>/dev/null; then
        log "ERROR" "AWS credentials verification failed"
        return 1
    fi

    # Verify cluster access
    if ! kubectl cluster-info &>/dev/null; then
        log "ERROR" "Cluster access verification failed"
        return 1
    fi

    # Restore critical namespaces
    for namespace in ${CRITICAL_NAMESPACES}; do
        log "INFO" "Restoring namespace: ${namespace}"
        
        if ! velero restore create "${namespace}-restore" \
            --from-backup $(velero backup get --output json | jq -r ".items[] | select(.spec.includedNamespaces[0]==\"${namespace}\") | .metadata.name" | sort -r | head -1) \
            --include-namespaces "${namespace}"; then
            log "ERROR" "Failed to restore namespace: ${namespace}"
            return 1
        fi

        if ! verify_component_health "${namespace}" "*"; then
            log "ERROR" "Health verification failed for namespace: ${namespace}"
            return 1
        fi

        if ! verify_data_consistency "${namespace}"; then
            log "ERROR" "Data consistency check failed for namespace: ${namespace}"
            return 1
        fi
    done

    return 0
}
#!/bin/bash

# Production-specific recovery configuration
export ENVIRONMENT="prod"
export CLUSTER_NAME="eks-platform-prod"
export REGION="ap-south-1"
export MIN_NODES=3
export MAX_NODES=5
export CRITICAL_NAMESPACES="argocd monitoring gatekeeper-system"
export NOTIFICATION_CHANNELS="slack pagerduty"
export BACKUP_RETENTION_DAYS=30
export HEALTH_CHECK_RETRIES=5
export HEALTH_CHECK_INTERVAL=60

# Source common functions
source $(dirname "$0")/common-functions.sh

# Production-specific pre-recovery checks
prod_pre_recovery_checks() {
    log "INFO" "Running production pre-recovery checks..."

    # Check AWS backup encryption
    if ! aws backup describe-backup-vault --backup-vault-name "${BACKUP_VAULT}" | grep -q "Encrypted"; then
        log "ERROR" "Production backup vault is not encrypted"
        return 1
    }

    # Verify minimum node count
    local node_count=$(kubectl get nodes --no-headers | wc -l)
    if [ "${node_count}" -lt "${MIN_NODES}" ]; then
        log "ERROR" "Insufficient nodes: ${node_count}/${MIN_NODES}"
        return 1
    }

    # Verify critical certificates
    for cert in $(kubectl get certificates -n cert-manager -o name); do
        if ! kubectl get "${cert}" -n cert-manager -o json | jq -r '.status.conditions[] | select(.type=="Ready").status' | grep -q "True"; then
            log "ERROR" "Certificate ${cert} is not ready"
            return 1
        fi
    done

    return 0
}

# Production-specific post-recovery validation
prod_post_recovery_validation() {
    log "INFO" "Running production post-recovery validation..."

    # Verify high availability
    for deployment in $(kubectl get deployments -A -l tier=critical -o name); do
        local replicas=$(kubectl get "${deployment}" -o jsonpath='{.spec.replicas}')
        if [ "${replicas}" -lt 2 ]; then
            log "ERROR" "Critical deployment ${deployment} has insufficient replicas: ${replicas}"
            return 1
        fi
    done

    # Verify security policies
    if ! kubectl get constraints -A | grep -q "ENFORCED"; then
        log "ERROR" "Security policies are not enforced"
        return 1
    }

    # Verify monitoring stack
    if ! curl -s "http://prometheus-operated:9090/api/v1/query?query=up" | grep -q '"value":\[.*,"1"\]'; then
        log "ERROR" "Prometheus is not operational"
        return 1
    fi

    return 0
}

# Main recovery process for production
main() {
    log "INFO" "Starting production recovery process"
    notify_all "Starting production cluster recovery" "warning"

    # Run production-specific pre-checks
    if ! prod_pre_recovery_checks; then
        log "ERROR" "Production pre-recovery checks failed"
        notify_all "Production pre-recovery checks failed" "danger"
        exit 1
    fi

    # Run common recovery steps
    if ! common_recovery_steps; then
        log "ERROR" "Common recovery steps failed"
        notify_all "Common recovery steps failed" "danger"
        exit 1
    fi

    # Run production-specific validation
    if ! prod_post_recovery_validation; then
        log "ERROR" "Production post-recovery validation failed"
        notify_all "Production post-recovery validation failed" "danger"
        exit 1
    }

    log "INFO" "Production recovery completed successfully"
    notify_all "Production recovery completed successfully" "good"
}

# Execute main function
main "$@"
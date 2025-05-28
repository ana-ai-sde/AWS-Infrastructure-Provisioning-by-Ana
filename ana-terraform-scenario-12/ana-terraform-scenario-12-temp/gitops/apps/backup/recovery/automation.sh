#!/bin/bash

set -euo pipefail

# Configuration
BACKUP_LOCATION="aws-backup"
CLUSTER_NAME="eks-platform"
REGION="ap-south-1"
NOTIFICATION_WEBHOOK="https://hooks.slack.com/services/YOUR_WEBHOOK"

# Logging setup
LOG_DIR="/var/log/recovery"
LOG_FILE="${LOG_DIR}/recovery-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "${LOG_DIR}"

# Function to log messages
log() {
    local level=$1
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] $*" | tee -a "${LOG_FILE}"
}

# Function to send notifications
notify() {
    local message=$1
    local color=${2:-"good"}
    
    curl -X POST -H 'Content-type: application/json' \
        --data "{
            \"attachments\": [
                {
                    \"color\": \"${color}\",
                    \"title\": \"Cluster Recovery Status\",
                    \"text\": \"${message}\",
                    \"fields\": [
                        {
                            \"title\": \"Cluster\",
                            \"value\": \"${CLUSTER_NAME}\",
                            \"short\": true
                        },
                        {
                            \"title\": \"Region\",
                            \"value\": \"${REGION}\",
                            \"short\": true
                        }
                    ]
                }
            ]
        }" "${NOTIFICATION_WEBHOOK}"
}

# Function to verify cluster health
verify_cluster_health() {
    log "INFO" "Verifying cluster health..."
    
    # Check nodes
    if ! kubectl get nodes | grep -q "Ready"; then
        log "ERROR" "Node health check failed"
        return 1
    fi
    
    # Check core components
    for namespace in kube-system argocd monitoring; do
        if ! kubectl get pods -n "${namespace}" | grep -q "Running"; then
            log "ERROR" "Core components check failed in ${namespace}"
            return 1
        fi
    done
    
    log "INFO" "Cluster health verification completed"
    return 0
}

# Function to restore core components
restore_core_components() {
    log "INFO" "Starting core components restoration..."
    
    # Restore ETCD
    velero restore create etcd-restore \
        --from-backup $(velero backup get --output json | jq -r '.items[] | select(.spec.includedNamespaces[0]=="kube-system") | .metadata.name' | sort -r | head -1) \
        --include-namespaces kube-system \
        --include-resources etcd || {
            log "ERROR" "ETCD restoration failed"
            notify "ETCD restoration failed" "danger"
            return 1
        }
    
    # Restore ArgoCD
    velero restore create argocd-restore \
        --from-backup $(velero backup get --output json | jq -r '.items[] | select(.spec.includedNamespaces[0]=="argocd") | .metadata.name' | sort -r | head -1) \
        --include-namespaces argocd || {
            log "ERROR" "ArgoCD restoration failed"
            notify "ArgoCD restoration failed" "danger"
            return 1
        }
    
    log "INFO" "Core components restored successfully"
    return 0
}

# Function to restore platform services
restore_platform_services() {
    log "INFO" "Starting platform services restoration..."
    
    # Restore monitoring stack
    velero restore create monitoring-restore \
        --from-backup $(velero backup get --output json | jq -r '.items[] | select(.spec.includedNamespaces[0]=="monitoring") | .metadata.name' | sort -r | head -1) \
        --include-namespaces monitoring || {
            log "ERROR" "Monitoring stack restoration failed"
            notify "Monitoring stack restoration failed" "danger"
            return 1
        }
    
    # Restore security policies
    velero restore create policies-restore \
        --from-backup $(velero backup get --output json | jq -r '.items[] | select(.spec.includedNamespaces[0]=="gatekeeper-system") | .metadata.name' | sort -r | head -1) \
        --include-namespaces gatekeeper-system || {
            log "ERROR" "Security policies restoration failed"
            notify "Security policies restoration failed" "danger"
            return 1
        }
    
    log "INFO" "Platform services restored successfully"
    return 0
}

# Main recovery process
main() {
    log "INFO" "Starting cluster recovery process"
    notify "Starting cluster recovery process" "warning"
    
    # Step 1: Verify AWS credentials
    if ! aws sts get-caller-identity &>/dev/null; then
        log "ERROR" "AWS credentials verification failed"
        notify "AWS credentials verification failed" "danger"
        exit 1
    fi
    
    # Step 2: Verify cluster access
    if ! kubectl cluster-info &>/dev/null; then
        log "ERROR" "Cluster access verification failed"
        notify "Cluster access verification failed" "danger"
        exit 1
    }
    
    # Step 3: Verify Velero installation
    if ! velero version &>/dev/null; then
        log "ERROR" "Velero client verification failed"
        notify "Velero client verification failed" "danger"
        exit 1
    }
    
    # Step 4: Restore core components
    if ! restore_core_components; then
        log "ERROR" "Core components restoration failed"
        exit 1
    fi
    
    # Step 5: Verify cluster health
    if ! verify_cluster_health; then
        log "ERROR" "Cluster health verification failed"
        notify "Cluster health verification failed" "danger"
        exit 1
    }
    
    # Step 6: Restore platform services
    if ! restore_platform_services; then
        log "ERROR" "Platform services restoration failed"
        exit 1
    }
    
    # Step 7: Final health check
    if ! verify_cluster_health; then
        log "ERROR" "Final health check failed"
        notify "Final health check failed" "danger"
        exit 1
    }
    
    log "INFO" "Cluster recovery completed successfully"
    notify "Cluster recovery completed successfully" "good"
}

# Execute main function
main "$@"
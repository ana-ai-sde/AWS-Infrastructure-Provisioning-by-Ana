#!/bin/bash

# Staging-specific recovery configuration
export ENVIRONMENT="staging"
export CLUSTER_NAME="eks-platform-staging"
export REGION="ap-south-1"
export MIN_NODES=2
export MAX_NODES=4
export CRITICAL_NAMESPACES="argocd monitoring"
export NOTIFICATION_CHANNELS="slack"
export BACKUP_RETENTION_DAYS=7
export HEALTH_CHECK_RETRIES=3
export HEALTH_CHECK_INTERVAL=30

# Source common functions
source $(dirname "$0")/common-functions.sh

# Staging-specific pre-recovery checks
staging_pre_recovery_checks() {
    log "INFO" "Running staging pre-recovery checks..."

    # Verify minimum node count
    local node_count=$(kubectl get nodes --no-headers | wc -l)
    if [ "${node_count}" -lt "${MIN_NODES}" ]; then
        log "ERROR" "Insufficient nodes: ${node_count}/${MIN_NODES}"
        return 1
    fi

    return 0
}

# Staging-specific post-recovery validation
staging_post_recovery_validation() {
    log "INFO" "Running staging post-recovery validation..."

    # Verify core services
    for service in argocd prometheus grafana; do
        if ! verify_component_health "${service}" "${service}"; then
            log "ERROR" "Core service ${service} validation failed"
            return 1
        fi
    done

    return 0
}

# Main recovery process for staging
main() {
    log "INFO" "Starting staging recovery process"
    notify_all "Starting staging cluster recovery" "warning"

    # Run staging-specific pre-checks
    if ! staging_pre_recovery_checks; then
        log "ERROR" "Staging pre-recovery checks failed"
        notify_all "Staging pre-recovery checks failed" "danger"
        exit 1
    fi

    # Run common recovery steps
    if ! common_recovery_steps; then
        log "ERROR" "Common recovery steps failed"
        notify_all "Common recovery steps failed" "danger"
        exit 1
    fi

    # Run staging-specific validation
    if ! staging_post_recovery_validation; then
        log "ERROR" "Staging post-recovery validation failed"
        notify_all "Staging post-recovery validation failed" "danger"
        exit 1
    }

    log "INFO" "Staging recovery completed successfully"
    notify_all "Staging recovery completed successfully" "good"
}

# Execute main function
main "$@"
#!/bin/bash

# Development-specific recovery configuration
export ENVIRONMENT="dev"
export CLUSTER_NAME="eks-platform-dev"
export REGION="ap-south-1"
export MIN_NODES=1
export MAX_NODES=3
export CRITICAL_NAMESPACES="argocd monitoring"
export NOTIFICATION_CHANNELS="slack"
export BACKUP_RETENTION_DAYS=3
export HEALTH_CHECK_RETRIES=2
export HEALTH_CHECK_INTERVAL=15

# Source common functions
source $(dirname "$0")/common-functions.sh

# Development-specific pre-recovery checks
dev_pre_recovery_checks() {
    log "INFO" "Running development pre-recovery checks..."

    # Basic node check
    if ! kubectl get nodes --no-headers | grep -q "Ready"; then
        log "ERROR" "No ready nodes found"
        return 1
    fi

    return 0
}

# Development-specific post-recovery validation
dev_post_recovery_validation() {
    log "INFO" "Running development post-recovery validation..."

    # Verify basic services
    for service in argocd prometheus; do
        if ! verify_component_health "${service}" "${service}"; then
            log "WARN" "Service ${service} validation failed, but continuing..."
        fi
    done

    return 0
}

# Main recovery process for development
main() {
    log "INFO" "Starting development recovery process"
    notify_all "Starting development cluster recovery" "warning"

    # Run development-specific pre-checks
    if ! dev_pre_recovery_checks; then
        log "ERROR" "Development pre-recovery checks failed"
        notify_all "Development pre-recovery checks failed" "danger"
        exit 1
    fi

    # Run common recovery steps
    if ! common_recovery_steps; then
        log "ERROR" "Common recovery steps failed"
        notify_all "Common recovery steps failed" "danger"
        exit 1
    fi

    # Run development-specific validation
    dev_post_recovery_validation

    log "INFO" "Development recovery completed"
    notify_all "Development recovery completed" "good"
}

# Execute main function
main "$@"
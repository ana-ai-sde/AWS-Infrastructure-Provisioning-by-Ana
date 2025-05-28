#!/bin/bash

# Test configuration
export TEST_ENVIRONMENTS="dev staging prod"
export TEST_SCENARIOS=(
    "full_cluster_recovery"
    "partial_recovery"
    "component_recovery"
)
export TEST_COMPONENTS=(
    "argocd"
    "monitoring"
    "gatekeeper"
)

# Source common functions
source $(dirname "$0")/common-functions.sh

# Function to create test cluster
create_test_cluster() {
    local env=$1
    log "INFO" "Creating test cluster for ${env}"

    # Create kind cluster
    kind create cluster --name "test-${env}" --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

    # Install required components
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update

    # Install ArgoCD
    helm install argocd argo/argo-cd --namespace argocd --create-namespace

    # Install Prometheus Stack
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring --create-namespace

    # Install Velero
    velero install \
        --provider aws \
        --plugins velero/velero-plugin-for-aws:v1.5.0 \
        --bucket test-backup-${env} \
        --secret-file ./credentials-velero \
        --use-volume-snapshots=false \
        --namespace velero \
        --create-namespace
}

# Function to simulate failure
simulate_failure() {
    local env=$1
    local scenario=$2
    log "INFO" "Simulating failure for ${env} - ${scenario}"

    case ${scenario} in
        "full_cluster_recovery")
            # Simulate full cluster failure
            kind delete cluster --name "test-${env}"
            ;;
        "partial_recovery")
            # Delete specific namespaces
            kubectl delete namespace argocd monitoring
            ;;
        "component_recovery")
            # Delete specific components
            kubectl delete deployment -n argocd argocd-server
            kubectl delete statefulset -n monitoring prometheus-prometheus
            ;;
    esac
}

# Function to test recovery
test_recovery() {
    local env=$1
    local scenario=$2
    log "INFO" "Testing recovery for ${env} - ${scenario}"

    # Run recovery script
    if ! ./${env}-recovery.sh; then
        log "ERROR" "Recovery failed for ${env} - ${scenario}"
        return 1
    fi

    # Verify recovery
    case ${scenario} in
        "full_cluster_recovery")
            # Verify all components
            for component in "${TEST_COMPONENTS[@]}"; do
                if ! verify_component_health "${component}" "*"; then
                    log "ERROR" "Component ${component} verification failed"
                    return 1
                fi
            done
            ;;
        "partial_recovery")
            # Verify specific namespaces
            for ns in argocd monitoring; do
                if ! kubectl get namespace "${ns}" &>/dev/null; then
                    log "ERROR" "Namespace ${ns} not recovered"
                    return 1
                fi
            done
            ;;
        "component_recovery")
            # Verify specific components
            if ! kubectl get deployment -n argocd argocd-server &>/dev/null; then
                log "ERROR" "ArgoCD server not recovered"
                return 1
            fi
            if ! kubectl get statefulset -n monitoring prometheus-prometheus &>/dev/null; then
                log "ERROR" "Prometheus not recovered"
                return 1
            fi
            ;;
    esac

    return 0
}

# Function to run all tests
run_all_tests() {
    local failed_tests=0

    for env in ${TEST_ENVIRONMENTS}; do
        for scenario in "${TEST_SCENARIOS[@]}"; do
            log "INFO" "Starting test: ${env} - ${scenario}"

            # Create test cluster
            if ! create_test_cluster "${env}"; then
                log "ERROR" "Failed to create test cluster for ${env}"
                failed_tests=$((failed_tests + 1))
                continue
            fi

            # Simulate failure
            simulate_failure "${env}" "${scenario}"

            # Test recovery
            if ! test_recovery "${env}" "${scenario}"; then
                log "ERROR" "Recovery test failed: ${env} - ${scenario}"
                failed_tests=$((failed_tests + 1))
            else
                log "INFO" "Recovery test passed: ${env} - ${scenario}"
            fi

            # Cleanup
            kind delete cluster --name "test-${env}"
        done
    done

    return ${failed_tests}
}

# Main function
main() {
    log "INFO" "Starting recovery testing"

    # Run all tests
    if ! run_all_tests; then
        log "ERROR" "Some recovery tests failed"
        exit 1
    fi

    log "INFO" "All recovery tests passed"
}

# Execute main function
main "$@"
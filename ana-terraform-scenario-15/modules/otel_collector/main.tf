resource "kubernetes_namespace" "otel" {
  metadata {
    name = "otel-system"
  }
}

resource "kubernetes_config_map" "otel_collector_config" {
  metadata {
    name      = "otel-collector-config"
    namespace = kubernetes_namespace.otel.metadata[0].name
  }

  data = {
    "config.yaml" = <<-EOT
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: 0.0.0.0:4317
            http:
              endpoint: 0.0.0.0:4318

      processors:
        batch:
          timeout: 1s
          send_batch_size: 1024
        memory_limiter:
          check_interval: 1s
          limit_mib: 1024

      exporters:
        otlp/tempo:
          endpoint: http://tempo:3200
          tls:
            insecure: true
        loki:
          endpoint: http://loki:3100
          tls:
            insecure: true
        prometheus:
          endpoint: "prometheus-server:9090"
          namespace: monitoring

      service:
        pipelines:
          traces:
            receivers: [otlp]
            processors: [memory_limiter, batch]
            exporters: [otlp/tempo]
          logs:
            receivers: [otlp]
            processors: [memory_limiter, batch]
            exporters: [loki]
          metrics:
            receivers: [otlp]
            processors: [memory_limiter, batch]
            exporters: [prometheus]
    EOT
  }
}

resource "kubernetes_service_account" "otel_collector" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.otel.metadata[0].name
  }
}

resource "kubernetes_deployment" "otel_collector" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.otel.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "otel-collector"
      }
    }

    template {
      metadata {
        labels = {
          app = "otel-collector"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.otel_collector.metadata[0].name

        container {
          name  = "otel-collector"
          image = "otel/opentelemetry-collector-contrib:0.70.0"
          
          args = [
            "--config=/conf/config.yaml"
          ]

          resources {
            limits = {
              cpu    = "500m"
              memory = "1Gi"
            }
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/conf"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 13133
            }
            initial_delay_seconds = 10
            period_seconds       = 30
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 13133
            }
            initial_delay_seconds = 10
            period_seconds       = 30
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.otel_collector_config.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_config_map.otel_collector_config]
}

resource "kubernetes_service" "otel_collector" {
  metadata {
    name      = "otel-collector"
    namespace = kubernetes_namespace.otel.metadata[0].name
  }

  spec {
    selector = {
      app = "otel-collector"
    }

    port {
      name        = "otlp-grpc"
      port        = 4317
      target_port = 4317
    }

    port {
      name        = "otlp-http"
      port        = 4318
      target_port = 4318
    }

    type = "ClusterIP"
  }
}
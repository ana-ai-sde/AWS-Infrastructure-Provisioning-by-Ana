resource "grafana_dashboard" "slo_dashboard" {
  config_json = jsonencode({
    title       = "Service Level Objectives Dashboard"
    description = "SLO monitoring and error budget tracking"
    panels = [
      {
        title    = "Availability SLO"
        type     = "gauge"
        gridPos  = { h = 8, w = 12, x = 0, y = 0 }
        targets  = [{
          expr = "avg_over_time(service_availability_ratio[24h]) * 100"
          legendFormat = "Availability"
        }]
        thresholds = {
          steps = [
            { value = null, color = "red" },
            { value = 95, color = "yellow" },
            { value = 99, color = "green" }
          ]
        }
      },
      {
        title    = "Latency SLO"
        type     = "gauge"
        gridPos  = { h = 8, w = 12, x = 12, y = 0 }
        targets  = [{
          expr = "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))"
          legendFormat = "P95 Latency"
        }]
        thresholds = {
          steps = [
            { value = null, color = "green" },
            { value = 0.2, color = "yellow" },
            { value = 0.5, color = "red" }
          ]
        }
      },
      {
        title    = "Error Budget Consumption"
        type     = "timeseries"
        gridPos  = { h = 8, w = 24, x = 0, y = 8 }
        targets  = [{
          expr = "1 - avg_over_time(service_availability_ratio[24h])"
          legendFormat = "Error Budget Used"
        }]
      }
    ]
  })
}

resource "grafana_alert_rule" "slo_breach" {
  name      = "SLO Breach Alert"
  folder_id = 0

  data = jsonencode([
    {
      refId         = "A"
      queryType     = "range"
      relativeTimeRange = {
        from = 900
        to   = 0
      }
      datasourceUid = "default"
      model = {
        expr = "avg_over_time(service_availability_ratio[15m]) < ${var.slo_thresholds["api"].availability / 100}"
        legendFormat = "Availability SLO Breach"
      }
    }
  ])

  condition = "A"
  no_data_state = "OK"
  exec_err_state = "Error"

  for = "5m"

  annotations = {
    description = "Service availability has dropped below the SLO threshold"
    summary     = "SLO Breach Detected"
  }

  labels = {
    severity = "critical"
  }
}
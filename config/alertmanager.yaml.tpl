---
global:
  resolve_timeout: 5m

receivers:
- name: Slack
  slack_configs:
  - api_url: '${SLACK_WEBHOOK_URL}'
    channel: '#notifications'
    send_resolved: true
    icon_url: https://avatars3.githubusercontent.com/u/3380462
    text: |-
        {{ range .Alerts }}
          *Alert:* {{ .Labels.alertname }}
          *Severity:* {{ .Labels.severity }}
          *Started At:* {{ .StartsAt }}
          *Details:*
          {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
          {{ end }}
        {{ end }}

route:
  receiver: Slack
  group_by:
  - namespace
  group_interval: 5m
  repeat_interval: 5m
  group_wait: 30s

inhibit_rules:
- equal:
  - namespace
  - alertname
  source_match:
    severity: critical
  target_match_re:
    severity: warning|info
- equal:
  - namespace
  - alertname
  source_match:
    severity: warning
  target_match_re:
    severity: info

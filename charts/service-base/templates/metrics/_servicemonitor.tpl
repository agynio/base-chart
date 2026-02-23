{{- define "service-base.metrics" -}}
{{- if and .Values.metrics.enabled .Values.metrics.serviceMonitor.enabled (.Capabilities.APIVersions.Has "monitoring.coreos.com/v1") -}}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "service-base.fullname" . }}
  labels:
{{ include "service-base.labels" . | nindent 4 }}
{{- with .Values.metrics.serviceMonitor.labels }}
{{ toYaml . | nindent 4 }}
{{- end }}
{{- with .Values.metrics.serviceMonitor.annotations }}
  annotations:
{{ toYaml . | nindent 4 }}
{{- end }}
{{- if .Values.metrics.serviceMonitor.namespace }}
  namespace: {{ .Values.metrics.serviceMonitor.namespace }}
{{- end }}
spec:
  selector:
    matchLabels:
{{ include "service-base.selectorLabels" . | nindent 6 }}
  {{- if and .Values.metrics.serviceMonitor.namespace (ne .Values.metrics.serviceMonitor.namespace .Release.Namespace) }}
  namespaceSelector:
    matchNames:
      - {{ .Values.metrics.serviceMonitor.namespace }}
  {{- end }}
  endpoints:
{{- range .Values.metrics.serviceMonitor.endpoints }}
    - port: {{ .port }}
      path: {{ .path | default "/metrics" }}
      {{- $interval := default $.Values.metrics.serviceMonitor.interval .interval }}
      {{- if $interval }}
      interval: {{ $interval }}
      {{- end }}
      {{- $scrapeTimeout := default $.Values.metrics.serviceMonitor.scrapeTimeout .scrapeTimeout }}
      {{- if $scrapeTimeout }}
      scrapeTimeout: {{ $scrapeTimeout }}
      {{- end }}
      honorLabels: {{ $.Values.metrics.serviceMonitor.honorLabels }}
      {{- with $.Values.metrics.serviceMonitor.relabelings }}
      relabelings:
{{ toYaml . | nindent 8 }}
      {{- end }}
      {{- with $.Values.metrics.serviceMonitor.metricRelabelings }}
      metricRelabelings:
{{ toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
{{- end -}}
{{- end -}}

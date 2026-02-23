{{- define "service-base.hpa" -}}
{{- if .Values.autoscaling.enabled -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "service-base.fullname" . }}
  labels:
{{ include "service-base.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "service-base.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
{{- if .Values.autoscaling.metrics }}
  metrics:
{{ toYaml .Values.autoscaling.metrics | nindent 4 }}
{{- else }}
  metrics:
{{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
{{- end }}
{{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
{{- end }}
{{- end }}
{{- with .Values.autoscaling.behavior }}
  behavior:
{{ toYaml . | nindent 4 }}
{{- end }}
{{- end -}}
{{- end -}}

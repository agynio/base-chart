{{- define "service-base.pdb" -}}
{{- if .Values.pdb.enabled -}}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "service-base.fullname" . }}
  labels:
{{ include "service-base.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
{{ include "service-base.selectorLabels" . | nindent 6 }}
{{- if .Values.pdb.minAvailable }}
  minAvailable: {{ .Values.pdb.minAvailable }}
{{- else if .Values.pdb.maxUnavailable }}
  maxUnavailable: {{ .Values.pdb.maxUnavailable }}
{{- end }}
{{- end -}}
{{- end -}}

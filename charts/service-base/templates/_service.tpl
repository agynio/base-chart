{{- define "service-base.service" -}}
{{- if .Values.service.enabled -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "service-base.fullname" . }}
  labels:
{{ include "service-base.labels" . | nindent 4 }}
{{- with .Values.service.labels }}
{{ toYaml . | nindent 4 }}
{{- end }}
{{- with .Values.service.annotations }}
  annotations:
{{ toYaml . | nindent 4 }}
{{- end }}
spec:
  type: {{ .Values.service.type }}
  selector:
{{ include "service-base.selectorLabels" . | nindent 4 }}
  ports:
{{- range .Values.service.ports }}
    - name: {{ .name }}
      port: {{ .port }}
      targetPort: {{ .targetPort }}
      protocol: {{ .protocol | default "TCP" }}
{{- end }}
{{- end -}}
{{- end -}}

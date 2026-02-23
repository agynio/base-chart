{{- define "service-base.service" -}}
{{- if .Values.service.enabled -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "service-base.fullname" . }}
  labels:
{{ include "service-base.labels" . | nindent 4 }}
{{- with .Values.service.annotations }}
  annotations:
{{ toYaml . | nindent 4 }}
{{- end }}
spec:
  type: {{ .Values.service.type }}
  selector:
{{ include "service-base.selectorLabels" . | nindent 4 }}
  ports:
    - name: {{ .Values.service.portName }}
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
{{- range .Values.service.additionalPorts }}
    - name: {{ .name }}
      port: {{ .port }}
      targetPort: {{ .targetPort }}
      protocol: {{ .protocol | default "TCP" }}
{{- end }}
{{- end -}}
{{- end -}}

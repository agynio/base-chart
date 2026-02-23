{{- define "service-base.ingress" -}}
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "service-base.fullname" . }}
  labels:
{{ include "service-base.labels" . | nindent 4 }}
{{- with .Values.ingress.annotations }}
  annotations:
{{ toYaml . | nindent 4 }}
{{- end }}
spec:
{{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
{{- end }}
{{- if .Values.ingress.tls }}
  tls:
{{ toYaml .Values.ingress.tls | nindent 4 }}
{{- end }}
  rules:
{{- range .Values.ingress.hosts }}
    - host: {{ .host }}
      http:
        paths:
{{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "service-base.fullname" $ }}
                port:
                  {{- if kindIs "int" .servicePort }}
                  number: {{ .servicePort }}
                  {{- else }}
                  name: {{ .servicePort }}
                  {{- end }}
{{- end }}
{{- end }}
{{- end -}}
{{- end -}}

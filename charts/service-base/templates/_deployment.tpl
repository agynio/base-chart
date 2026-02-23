{{- define "service-base.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "service-base.fullname" . }}
  labels:
{{ include "service-base.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  revisionHistoryLimit: {{ .Values.revisionHistoryLimit }}
  selector:
    matchLabels:
{{ include "service-base.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
{{ include "service-base.selectorLabels" . | nindent 8 }}
{{- with .Values.podLabels }}
{{ toYaml . | nindent 8 }}
{{- end }}
{{- with .Values.podAnnotations }}
      annotations:
{{ toYaml . | nindent 8 }}
{{- end }}
    spec:
      serviceAccountName: {{ include "service-base.serviceAccountName" . }}
      automountServiceAccountToken: {{ .Values.automountServiceAccountToken }}
{{ include "service-base.imagePullSecrets" . | nindent 6 }}
{{- with .Values.podSecurityContext }}
      securityContext:
{{ toYaml . | nindent 8 }}
{{- end }}
      containers:
        - name: {{ include "service-base.name" . }}
          image: {{ include "service-base.image" . | quote }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
{{- if .Values.command }}
          command:
{{ toYaml .Values.command | nindent 12 }}
{{- end }}
{{- if .Values.args }}
          args:
{{ toYaml .Values.args | nindent 12 }}
{{- end }}
          ports:
{{ toYaml .Values.containerPorts | nindent 12 }}
{{- if .Values.env }}
          env:
{{ toYaml .Values.env | nindent 12 }}
{{- end }}
{{- if .Values.envFrom }}
          envFrom:
{{ toYaml .Values.envFrom | nindent 12 }}
{{- end }}
{{- with .Values.resources }}
          resources:
{{ toYaml . | nindent 12 }}
{{- end }}
{{- with .Values.containerSecurityContext }}
          securityContext:
{{ toYaml . | nindent 12 }}
{{- end }}
{{- with .Values.livenessProbe }}
          livenessProbe:
{{ toYaml . | nindent 12 }}
{{- end }}
{{- with .Values.readinessProbe }}
          readinessProbe:
{{ toYaml . | nindent 12 }}
{{- end }}
{{- with .Values.startupProbe }}
          startupProbe:
{{ toYaml . | nindent 12 }}
{{- end }}
{{- if or .Values.configMounts .Values.extraVolumeMounts }}
          volumeMounts:
{{- if .Values.configMounts }}
{{ include "service-base.configMounts" . | nindent 12 }}
{{- end }}
{{- if .Values.extraVolumeMounts }}
{{ toYaml .Values.extraVolumeMounts | nindent 12 }}
{{- end }}
{{- end }}
{{- if or .Values.configMounts .Values.extraVolumes }}
      volumes:
{{- if .Values.configMounts }}
{{ include "service-base.configVolumes" . | nindent 8 }}
{{- end }}
{{- if .Values.extraVolumes }}
{{ toYaml .Values.extraVolumes | nindent 8 }}
{{- end }}
{{- end }}
{{- with .Values.nodeSelector }}
      nodeSelector:
{{ toYaml . | nindent 8 }}
{{- end }}
{{- with .Values.affinity }}
      affinity:
{{ toYaml . | nindent 8 }}
{{- end }}
{{- with .Values.tolerations }}
      tolerations:
{{ toYaml . | nindent 8 }}
{{- end }}
{{- end -}}

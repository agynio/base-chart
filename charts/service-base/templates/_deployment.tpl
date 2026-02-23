{{- define "service-base.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "service-base.fullname" . }}
  labels:
{{ include "service-base.labels" . | nindent 4 }}
  {{- $annotations := include "service-base.commonAnnotations" . }}
  {{- if $annotations }}
  annotations:
{{ $annotations | nindent 4 }}
  {{- end }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  revisionHistoryLimit: {{ .Values.revisionHistoryLimit }}
  {{- with .Values.updateStrategy }}
  strategy:
{{ toYaml . | nindent 4 }}
  {{- end }}
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
      {{- if .Values.priorityClassName }}
      priorityClassName: {{ .Values.priorityClassName }}
      {{- end }}
      {{- if not (eq .Values.terminationGracePeriodSeconds nil) }}
      terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
      {{- end }}
      serviceAccountName: {{ include "service-base.serviceAccountName" . }}
      automountServiceAccountToken: {{ .Values.automountServiceAccountToken }}
{{ include "service-base.imagePullSecrets" . | nindent 6 }}
{{- $podSecurityContext := include "service-base.podSecurityContext" . }}
{{- if $podSecurityContext }}
      securityContext:
{{ $podSecurityContext | nindent 8 }}
{{- end }}
{{- if .Values.initContainers }}
      initContainers:
{{ toYaml .Values.initContainers | nindent 8 }}
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
{{- $env := include "service-base.renderEnv" . }}
{{- if $env }}
{{ $env | nindent 10 }}
{{- end }}
{{- $envFrom := include "service-base.renderEnvFrom" . }}
{{- if $envFrom }}
{{ $envFrom | nindent 10 }}
{{- end }}
{{- with .Values.resources }}
          resources:
{{ toYaml . | nindent 12 }}
{{- end }}
{{- $containerSecurityContext := include "service-base.securityContext" . }}
{{- if $containerSecurityContext }}
          securityContext:
{{ $containerSecurityContext | nindent 12 }}
{{- end }}
{{- with .Values.lifecycle }}
          lifecycle:
{{ toYaml . | nindent 12 }}
{{- end }}
{{- if .Values.livenessProbe.enabled }}
          livenessProbe:
{{ omit .Values.livenessProbe "enabled" | toYaml | nindent 12 }}
{{- end }}
{{- if .Values.readinessProbe.enabled }}
          readinessProbe:
{{ omit .Values.readinessProbe "enabled" | toYaml | nindent 12 }}
{{- end }}
{{- if .Values.startupProbe.enabled }}
          startupProbe:
{{ omit .Values.startupProbe "enabled" | toYaml | nindent 12 }}
{{- end }}
{{- if or .Values.configMounts .Values.extraVolumeMounts }}
          volumeMounts:
{{- if .Values.configMounts }}
{{ include "service-base.config" . | nindent 12 }}
{{- end }}
{{- $extraVolumeMounts := include "service-base.renderExtraVolumeMounts" . }}
{{- if $extraVolumeMounts }}
{{ $extraVolumeMounts | nindent 12 }}
{{- end }}
{{- end }}
{{- if .Values.extraContainers }}
{{ toYaml .Values.extraContainers | nindent 8 }}
{{- end }}
{{- if or .Values.configMounts .Values.extraVolumes }}
      volumes:
{{- if .Values.configMounts }}
{{ include "service-base.configVolumes" . | nindent 8 }}
{{- end }}
{{- $extraVolumes := include "service-base.renderExtraVolumes" . }}
{{- if $extraVolumes }}
{{ $extraVolumes | nindent 8 }}
{{- end }}
{{- end }}
{{- if .Values.topologySpreadConstraints }}
      topologySpreadConstraints:
{{ toYaml .Values.topologySpreadConstraints | nindent 8 }}
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

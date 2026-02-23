{{- define "service-base.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service-base.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "service-base.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{- define "service-base.labels" -}}
helm.sh/chart: {{ include "service-base.chart" . }}
{{ include "service-base.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{- define "service-base.selectorLabels" -}}
app.kubernetes.io/name: {{ include "service-base.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "service-base.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else -}}
{{- include "service-base.fullname" . -}}
{{- end -}}
{{- else -}}
{{- if .Values.serviceAccount.name -}}
{{- .Values.serviceAccount.name -}}
{{- else -}}
default
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "service-base.imageTag" -}}
{{- if .Values.image.tag -}}
{{- .Values.image.tag -}}
{{- else -}}
{{- .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "service-base.image" -}}
{{- $registry := "" -}}
{{- if .Values.global.imageRegistry -}}
{{- $registry = .Values.global.imageRegistry -}}
{{- else -}}
{{- $registry = .Values.image.registry -}}
{{- end -}}
{{- $registry = trimSuffix "/" $registry -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry .Values.image.repository (include "service-base.imageTag" .) -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository (include "service-base.imageTag" .) -}}
{{- end -}}
{{- end -}}

{{- define "service-base.imagePullSecrets" -}}
{{- $globalSecrets := .Values.global.imagePullSecrets | default (list) -}}
{{- $imageSecrets := .Values.image.pullSecrets | default (list) -}}
{{- $pullSecrets := concat $globalSecrets $imageSecrets | uniq -}}
{{- if $pullSecrets }}
imagePullSecrets:
{{- range $secret := $pullSecrets }}
  - name: {{ $secret }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "service-base.configVolumeMounts" -}}
{{- range .Values.configMounts }}
- name: {{ .name }}
  mountPath: {{ .mountPath }}
  {{- if .subPath }}
  subPath: {{ .subPath }}
  {{- end }}
  readOnly: {{ .readOnly | default true }}
{{- end }}
{{- end -}}

{{- define "service-base.config" -}}
{{- include "service-base.configVolumeMounts" . -}}
{{- end -}}

{{- define "service-base.configMounts" -}}
{{- include "service-base.configVolumeMounts" . -}}
{{- end -}}

{{- define "service-base.configVolumes" -}}
{{- range .Values.configMounts }}
{{- $sourceName := required "configMounts[].sourceName is required" .sourceName -}}
- name: {{ .name }}
  {{- if eq (default "configMap" .type) "secret" }}
  secret:
    secretName: {{ $sourceName }}
    {{- if .items }}
    items:
{{ toYaml .items | nindent 6 }}
    {{- end }}
  {{- else }}
  configMap:
    name: {{ $sourceName }}
    {{- if .items }}
    items:
{{ toYaml .items | nindent 6 }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "service-base.commonAnnotations" -}}
{{- $annotations := dict -}}
{{- with .Values.commonAnnotations }}
{{- $annotations = merge $annotations . -}}
{{- end }}
{{- with .Values.deploymentAnnotations }}
{{- $annotations = merge $annotations . -}}
{{- end }}
{{- if $annotations }}
{{ toYaml $annotations }}
{{- end }}
{{- end -}}

{{- define "service-base.renderEnv" -}}
{{- $env := concat (.Values.env | default (list)) (.Values.extraEnvVars | default (list)) -}}
{{- if $env }}
env:
{{ toYaml $env | nindent 2 }}
{{- end }}
{{- end -}}

{{- define "service-base.renderEnvFrom" -}}
{{- $envFrom := list -}}
{{- if .Values.envFrom }}
{{- $envFrom = concat $envFrom .Values.envFrom -}}
{{- end }}
{{- if .Values.extraEnvVarsCM }}
{{- $envFrom = append $envFrom (dict "configMapRef" (dict "name" .Values.extraEnvVarsCM)) -}}
{{- end }}
{{- if .Values.extraEnvVarsSecret }}
{{- $envFrom = append $envFrom (dict "secretRef" (dict "name" .Values.extraEnvVarsSecret)) -}}
{{- end }}
{{- if $envFrom }}
envFrom:
{{ toYaml $envFrom | nindent 2 }}
{{- end }}
{{- end -}}

{{- define "service-base.renderExtraVolumes" -}}
{{- if .Values.extraVolumes }}
{{ toYaml .Values.extraVolumes }}
{{- end }}
{{- end -}}

{{- define "service-base.renderExtraVolumeMounts" -}}
{{- if .Values.extraVolumeMounts }}
{{ toYaml .Values.extraVolumeMounts }}
{{- end }}
{{- end -}}

{{- define "service-base.podSecurityContext" -}}
{{- if .Values.podSecurityContext.enabled }}
{{ omit .Values.podSecurityContext "enabled" | toYaml }}
{{- end }}
{{- end -}}

{{- define "service-base.securityContext" -}}
{{- if .Values.securityContext.enabled }}
{{ omit .Values.securityContext "enabled" | toYaml }}
{{- end }}
{{- end -}}

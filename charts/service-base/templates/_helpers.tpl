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
{{- printf "%s:%s" .Values.image.repository (include "service-base.imageTag" .) -}}
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

{{- define "service-base.configMounts" -}}
{{- include "service-base.configVolumeMounts" . -}}
{{- end -}}

{{- define "service-base.configVolumes" -}}
{{- range .Values.configMounts }}
- name: {{ .name }}
  {{- if eq (default "configMap" .type) "secret" }}
  secret:
    secretName: {{ .name }}
    {{- if .items }}
    items:
{{ toYaml .items | nindent 6 }}
    {{- end }}
  {{- else }}
  configMap:
    name: {{ .name }}
    {{- if .items }}
    items:
{{ toYaml .items | nindent 6 }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}

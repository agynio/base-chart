{{- define "service-base.rbac" -}}
{{- if .Values.rbac.create -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: {{ ternary "ClusterRole" "Role" .Values.rbac.clusterWide }}
metadata:
  name: {{ include "service-base.fullname" . }}
  labels:
{{ include "service-base.labels" . | nindent 4 }}
rules:
{{ toYaml .Values.rbac.rules | nindent 2 }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: {{ ternary "ClusterRoleBinding" "RoleBinding" .Values.rbac.clusterWide }}
metadata:
  name: {{ include "service-base.fullname" . }}
  labels:
{{ include "service-base.labels" . | nindent 4 }}
subjects:
  - kind: ServiceAccount
    name: {{ include "service-base.serviceAccountName" . }}
    namespace: {{ .Release.Namespace }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: {{ ternary "ClusterRole" "Role" .Values.rbac.clusterWide }}
  name: {{ include "service-base.fullname" . }}
{{- end -}}
{{- end -}}

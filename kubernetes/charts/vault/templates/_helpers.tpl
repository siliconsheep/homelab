{{/*
Copied from the vault charts's _helpers.tpl, updated to reflect the subchart Values
*/}}

{{- define "vault.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "vault.name" -}}
{{- default .Chart.Name .Values.vault.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "vault.serviceAccount.name" -}}
{{- if .Values.vault.server.serviceAccount.create -}}
    {{ default (include "vault.fullname" .)) .Values.vault.server.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.vault.server.serviceAccount.name }}
{{- end -}}
{{- end -}}
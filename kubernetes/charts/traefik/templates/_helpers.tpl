{{- define "traefik.hostname" -}}
  {{- printf "%s.traefik.%s" .Values.global.cluster .Values.global.domain -}}
{{- end -}}

{{- define "traefik.secretname" -}}
  {{- include "traefik.hostname" . | replace "." "-" -}}
{{- end -}}

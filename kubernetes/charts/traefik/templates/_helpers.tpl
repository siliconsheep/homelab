{{- define "traefik.hostname" -}}
  {{- printf "%s.traefik.%s" .Values.cluster .Values.domain -}}
{{- end -}}

{{- define "traefik.secretname" -}}
  {{- include "traefik.hostname" . | replace "." "-" -}}
{{- end -}}

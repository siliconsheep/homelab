module "prometheus-oke" {
  source = "./modules/proxy-application"

  name          = "Prometheus (OKE)"
  description   = "Prometheus monitoring system and time series database"
  icon_url      = "https://prometheus.io/assets/favicons/android-chrome-192x192.png"
  external_host = "https://oke.prometheus.siliconsheep.se"
  group         = "Monitoring"
}

module "alertmanager-oke" {
  source = "./modules/proxy-application"

  name          = "Alertmanager (OKE)"
  description   = "Alertmanager handles alerts sent by client applications such as the Prometheus server"
  icon_url      = "https://prometheus.io/assets/favicons/android-chrome-192x192.png"
  external_host = "https://oke.alertmanager.siliconsheep.se"
  group         = "Monitoring"
}

module "prometheus-home" {
  source = "./modules/proxy-application"

  name          = "Prometheus (Home)"
  description   = "Prometheus monitoring system and time series database"
  icon_url      = "https://prometheus.io/assets/favicons/android-chrome-192x192.png"
  external_host = "https://home.prometheus.siliconsheep.se"
  group         = "Monitoring"
}

module "alertmanager-home" {
  source = "./modules/proxy-application"

  name          = "Alertmanager (Home)"
  description   = "Alertmanager handles alerts sent by client applications such as the Prometheus server"
  icon_url      = "https://prometheus.io/assets/favicons/android-chrome-192x192.png"
  external_host = "https://home.alertmanager.siliconsheep.se"
  group         = "Monitoring"
}

module "sabnzbd-home" {
  source = "./modules/proxy-application"

  name          = "SABnzbd"
  description   = "SABnzbd is a multi-platform binary newsreader written in Python"
  icon_url      = "https://avatars.githubusercontent.com/u/960698?s=200&v=4"
  external_host = "https://sabnzbd.siliconsheep.se"
  group         = "Media"
}

module "sonarr-home" {
  source = "./modules/proxy-application"

  name          = "Sonarr"
  description   = "Sonarr is a PVR for Usenet and BitTorrent users"
  icon_url      = "https://avatars.githubusercontent.com/u/1082903?s=200&v=4"
  external_host = "https://sonarr.siliconsheep.se"
  group         = "Media"
}

module "radarr-home" {
  source = "./modules/proxy-application"

  name          = "Radarr"
  description   = "Radarr is a movie collection manager for Usenet and BitTorrent users"
  icon_url      = "https://avatars.githubusercontent.com/u/25025331?s=280&v=4"
  external_host = "https://radarr.siliconsheep.se"
  group         = "Media"
}

module "argocd" {
  source = "./modules/oauth2-application"

  name        = "ArgoCD"
  description = "Declarative continuous deployment for Kubernetes"
  icon_url    = "https://argo-cd.readthedocs.io/en/stable/assets/logo.png"
  redirect_uris = [
    "https://argocd.siliconsheep.se/api/dex/callback",
    "http://localhost:8085/auth/callback"
  ]
  group = "GitOps"
}

module "grafana" {
  source = "./modules/oauth2-application"

  name        = "Grafana"
  description = "Grafana is the open source analytics and monitoring solution for every database"
  icon_url    = "https://grafana.com/static/img/about/grafana_logo_swirl_fullcolor.jpg"
  redirect_uris = [
    "https://grafana.siliconsheep.se/login/generic_oauth"
  ]
  group = "Monitoring"
}

module "goldilocks" {
  source = "./modules/proxy-application"

  name          = "Goldilocks"
  description   = "Goldilocks is a Kubernetes resource management tool that helps you optimize your cluster resource usage"
  external_host = "https://goldilocks.siliconsheep.se"
  group         = "Monitoring"
}

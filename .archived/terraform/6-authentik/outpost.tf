module "authentik-outpost-home" {
  source = "./modules/outpost"
  providers = {
    authentik  = authentik
    kubernetes = kubernetes
  }

  name             = "home"
  kube_config_path = var.kube_config_path
  kube_context     = "siliconsheep-home"
  secret_name      = "authentik"
  secret_namespace = "auth"

  protocol_providers = [
    module.prometheus-home.provider_id,
    module.alertmanager-home.provider_id,
    module.sabnzbd-home.provider_id,
    module.sonarr-home.provider_id,
    module.radarr-home.provider_id,
  ]
}

module "authentik-outpost-oke" {
  source = "./modules/outpost"
  providers = {
    authentik = authentik
  }

  name             = "oke"
  local_connection = true

  protocol_providers = [
    module.prometheus-oke.provider_id,
    module.alertmanager-oke.provider_id,
    module.goldilocks.provider_id,
  ]
}

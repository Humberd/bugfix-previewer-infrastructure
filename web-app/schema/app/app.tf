locals {
  namespace = "bugfix-previewer"
  url = "bugfix-previewer.humberd.pl"
}

resource "kubernetes_deployment" "bugfix-previewer-web" {
  timeouts {
    create = "1 minute"
  }

  metadata {
    name = "bugfix-previewer-web"
    namespace = local.namespace
  }
  spec {
    selector {
      match_labels = {
        type = "bugfix-previewer-web-instance"
      }
    }
    template {
      metadata {
        labels = {
          type = "bugfix-previewer-web-instance"
        }
      }
      spec {
        restart_policy = "Never"

        container {
          name = "angular-instance"
          image = "humberd/bugfix-previewer-web:latest"

          port {
            container_port = 80
          }

          startup_probe {
            timeout_seconds = 60
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "bugfix-previewer-web" {
  metadata {
    name = "bugfix-previewer-web"
    namespace = local.namespace
  }
  spec {
    selector = {
      type = "bugfix-previewer-web-instance"
    }
    port {
      port = 80
    }
  }
}

resource "kubernetes_ingress" "bugfix-previewer-web" {
  metadata {
    name = "bugfix-previewer-web-ingress"
    namespace = local.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "ingress.kubernetes.io/ssl-redirect" = true
    }
  }
  spec {
    rule {
      host = local.url
      http {
        path {
          backend {
            service_name = "bugfix-previewer-web"
            service_port = 80
          }
          path = "/"
        }
      }
    }
    tls {
      hosts = [local.url]
      secret_name = "bugfix-previewer-humberd-pl-tls"
    }
  }
}

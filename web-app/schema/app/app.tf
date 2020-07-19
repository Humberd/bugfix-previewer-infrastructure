locals {
  namespace = "bugfix-previewer"
}

resource "kubernetes_deployment" "bugfix-previewer-web" {
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
        container {
          name = "angular-instance"
          image = "humberd/bugfix-previewer-web:amd64-1"

          port {
            container_port = 80
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
      host = "bugfix-previewer.humberd.pl"
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
      hosts = ["bugfix-previewer.humberd.pl"]
      secret_name = "bugfix-previewer-humberd-pl-tls"
    }
  }
}

locals {
  namespace = "bugfix-previewer"

  database = {
    postgres_username = "bugfix-previewer"
    postgres_password = "bugfix-previewer-server-password"
    postgres_db = "bugfix-previewer"
    postgres_url = "bugfix-previewer-postgres-postgresql:5432"
  }

  url = "api.bugfix-previewer.humberd.pl"
}

resource "helm_release" "postgres" {
  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  name = "bugfix-previwer-postgres"
  namespace = local.namespace

  set {
    name = "image.repository"
    value = "postgres"
  }

  set {
    name = "image.tag"
    value = "12.2"
  }

  set {
    name = "postgresqlUsername"
    value = local.database.postgres_username
  }

  set {
    name = "postgresqlPassword"
    value = local.database.postgres_password
  }

  set {
    name = "postgresqlDatabase"
    value = local.database.postgres_db
  }
}

resource "kubernetes_deployment" "bugfix-previwer-server" {
  depends_on = [
    helm_release.postgres
  ]

  metadata {
    name = "bugfix-previewer-server"
    namespace = local.namespace
  }
  spec {
    selector {
      match_labels = {
        type = "bugfix-previewer-server-instance"
      }
    }
    template {
      metadata {
        labels = {
          type = "bugfix-previewer-server-instance"
        }
      }
      spec {
        container {
          name = "kotlin-instance"
          image = "humberd/bugfix-previewer-server:latest"

          port {
            container_port = 8080
          }

          env {
            name = "POSTGRES_URL"
            value = local.database.postgres_url
          }

          env {
            name = "POSTGRES_DB"
            value = local.database.postgres_db
          }

          env {
            name = "POSTGRES_USERNAME"
            value = local.database.postgres_username
          }

          env {
            name = "POSTGRES_PASSWORD"
            value = local.database.postgres_password
          }

          env {
            name = "AWS_ACCESS_KEY_ID"
            value = var.aws_access_key_id
          }

          env {
            name = "AWS_SECRET_ACCESS_KEY"
            value = var.aws_access_secret_key
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "bugfix-previewer-server" {
  metadata {
    name = "bugfix-previwer-server"
    namespace = local.namespace
  }
  spec {
    selector = {
      type = "bugfix-previewer-server-instance"
    }
    port {
      port = 8080
    }
  }
}

resource "kubernetes_ingress" "bugfix-previewer-server" {
  metadata {
    name = "bugfix-previewer-server-ingress"
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
            service_name = "bugfix-previewer-server"
            service_port = 8080
          }
          path = "/"
        }
      }
    }
    tls {
      hosts = [local.url]
      secret_name = "api-bugfix-previewer-humberd-pl-tls"
    }
  }
}


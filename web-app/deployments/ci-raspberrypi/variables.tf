variable "kubernetes_host" {
  type = string
  description = "Host of Kubernetes, for example: https://example.com:6443"
}

variable "kubernetes_cluster_ca_certificate" {
  type = string
  description = "Cluster certificate. It will be base64decode(thisToken)"
}

variable "kubernetes_token" {
  type = string
  description = "Service account token. It will be base64decode(thisToken)"
}

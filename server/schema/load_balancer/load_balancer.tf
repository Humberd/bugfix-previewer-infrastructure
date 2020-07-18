data "helm_repository" "stable-repo" {
  name = "stable"
  url = "https://kubernetes-charts.storage.googleapis.com/"
}


resource "helm_release" "ingress-controller" {
  chart = "stable/nginx-ingress"
  name = "nginx-ingress"

  set {
    name = "controller.publishService.enabled"
    value = true
  }
}

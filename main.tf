variable "namespace_name" {
  type    = string
  default = "demo-telcel"
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = var.namespace_name
  }
}

resource "kubernetes_resource_quota" "cuota" {
  metadata {
    name      = "cuota-recursos"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = "2"
      "requests.memory" = "4Gi"
      "limits.cpu"      = "4"
      "limits.memory"   = "8Gi"
      "pods"            = "10"
    }
  }
}

resource "kubernetes_role_binding" "admin" {
  metadata {
    name      = "rol-admin"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "User"
    name      = "usuario-admin-telcel"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role_binding" "dev" {
  metadata {
    name      = "rol-desarrollo"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind      = "User"
    name      = "usuario-dev-telcel"
    api_group = "rbac.authorization.k8s.io"
  }
}

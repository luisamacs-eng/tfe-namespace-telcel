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

# Crea un grupo NUEVO de administradores (aislado, no toca los grupos existentes)
resource "kubernetes_manifest" "grupo_admin" {
  manifest = {
    apiVersion = "user.openshift.io/v1"
    kind       = "Group"
    metadata = {
      name = "${var.namespace_name}-adm-group"
    }
    users = []
  }
}

# Crea un grupo NUEVO de desarrollo (aislado)
resource "kubernetes_manifest" "grupo_dev" {
  manifest = {
    apiVersion = "user.openshift.io/v1"
    kind       = "Group"
    metadata = {
      name = "${var.namespace_name}-dev-group"
    }
    users = []
  }
}
# RoleBinding admin: enlaza el grupo admin -> ClusterRole admin
# (mismo patrón que su RoleBinding terraform-prueba-adm)
resource "kubernetes_role_binding" "admin" {
  metadata {
    name      = "${var.namespace_name}-adm"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "Group"
    name      = "${var.namespace_name}-adm-group"
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [kubernetes_manifest.grupo_admin]
}

# RoleBinding desarrollo: enlaza el grupo dev -> ClusterRole edit
resource "kubernetes_role_binding" "dev" {
  metadata {
    name      = "${var.namespace_name}-dev"
    namespace = kubernetes_namespace.demo.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind      = "Group"
    name      = "${var.namespace_name}-dev-group"
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [kubernetes_manifest.grupo_dev]
}
# trigger

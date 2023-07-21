---
apiVersion: v1
kind: Config
clusters:
  - name: default-cluster
    cluster:
      certificate-authority-data: ${ca}
      server: ${server}
contexts:
  - name: default-context
    context:
      cluster: default-cluster
      namespace: ${namespace}
      user: authentik-user
current-context: default-context
users:
  - name: authentik-user
    user:
      token: ${token}
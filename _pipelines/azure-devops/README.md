# How to use?

Apply:

1. service-account.yml
2. roles.yml
3. Run
```bash
TOKEN=`kubectl get serviceAccounts/azure-devops -n bugfix-previewer -o=jsonpath="{.secrets[0].name}"`
kubectl get secret $TOKEN -n bugfix-previewer -o json
```
4. In the kubernetes provider paste the values:

data['ca.crt'] --> cluster_ca_certificate

data.token --> token

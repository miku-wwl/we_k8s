```
mutatingwebhookconfiguration.admissionregistration.k8s.io/jaeger-operator-mutating-webhook-configuration created
validatingwebhookconfiguration.admissionregistration.k8s.io/jaeger-operator-validating-webhook-configuration created
Error from server (InternalError): error when creating "jaeger-operator.yaml": Internal error occurred: failed calling webhook "webhook.cert-manager.io": failed to call webhook: Post "https://c                         ert-manager-webhook.cert-manager.svc:443/validate?timeout=30s": tls: failed to verify certificate: x509: certificate signed by unknown authority
Error from server (InternalError): error when creating "jaeger-operator.yaml": Internal error occurred: failed calling webhook "webhook.cert-manager.io": failed to call webhook: Post "https://c                         ert-manager-webhook.cert-manager.svc:443/validate?timeout=30s": tls: failed to verify certificate: x509: certificate signed by unknown authority
```
该错误是此前cert-manager资源残留导致出错。

使用指令
```
kubectl delete all --all -n cert-manager
```
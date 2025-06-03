--------------------------------------------------------------------
1、CronJob
CronJob
https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/

activedeadline:



--------------------------------------------------------------------
3、限制CPU和内存request
https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/


--------------------------------------------------------------------
7、配置Container安全上下文

以用户 30000 运行 
禁止特权提升。


--------------------------------------------------------------------
9、RBAC授权 
root@master01:/ckad/prompt-escargot# kubectl get sa -n gorilla
NAME         SECRETS   AGE
boxweb-sa    0         90d
default      0         90d
gorilla-sa   0         90d
root@master01:/ckad/prompt-escargot# kubectl get role -n gorilla
NAME           CREATED AT
boxweb-role    2025-03-04T14:42:40Z
gorilla-role   2025-03-04T14:42:36Z
root@master01:/ckad/prompt-escargot#


--------------------------------------------------------------------
10、Secret 
https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data

``` yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-secret
  name: nginx-secret
spec:
  containers:
  - image: nginx:1.16
    name: nginx-secret
    resources: {}
    env:
    - name: COOL_VARIABLE
      valueFrom:
        secretKeyRef:
          name: another-secret
          key: key1
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

--------------------------------------------------------------------
13、Deployment 使用 ServiceAcount
kubectl -n frontend set sa deployments frontend-deployment app




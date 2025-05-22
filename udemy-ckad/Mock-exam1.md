### Q. 1  
**Task**  
Deploy a pod named `nginx-448839` using the `nginx:alpine` image.  

**Solution**  
```bash
kubectl run  nginx-448839 --image=nginx:alpine
```  

**Details**  
- Name: `nginx-448839`  
- Image: `nginx:alpine`  


### Q. 2  
**Task**  
Create a namespace named `apx-z993845`.  

**Solution**  
```bash
kubectl create namespace apx-z993845
```  

**Details**  
- Namespace: `apx-z993845`  


### Q. 3  
**Task**  
Create a new Deployment named `httpd-frontend` with 3 replicas using image `httpd:2.4-alpine`.  

**Solution**  
```bash
kubectl create deployment httpd-frontend --image=httpd:2.4-alpine --replicas=3
```  

**Details**  
- Name: `httpd-frontend`  
- Replicas: `3`  
- Image: `httpd:2.4-alpine`  


### Q. 4  
**Task**  
Deploy a messaging pod using the `redis:alpine` image with the labels set to `tier=msg`.  

**Solution**  
```bash
kubectl run messaging --image=redis:alpine -l tier=msg
```  

**Details**  
- Pod Name: `messaging`  
- Image: `redis:alpine`  
- Labels: `tier=msg`  


### Q. 5  
**Task**  
A replicaset `rs-d33393` is created. However the pods are not coming up. Identify and fix the issue. Ensure the ReplicaSet has 4 Ready replicas.  

**Solution**  
1. Edit the replicaset:  
   ```bash
   kubectl edit rs rs-d33393
   ```  
   - Fix the image from `busyboxXXXXXXX` to `busybox`.  
2. Delete all PODs to recreate:  
   ```bash
   kubectl delete pods -l <rs-selector>
   ```  

**Details**  
- Replicas: `4`  


### Q. 6  
**Task**  
Create a service `messaging-service` to expose the redis deployment in the `marketing` namespace within the cluster on port 6379. Use imperative commands.  

**Solution**  
```bash
kubectl expose deployment redis --port=6379 --name messaging-service --namespace marketing
```  

**Details**  
- Service: `messaging-service`  
- Port: `6379`  


### Q. 7  
**Task**  
Update the environment variable on the pod `webapp-color` to use a green background.  

**Solution YAML**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: webapp-color
  name: webapp-color
  namespace: default
spec:
  containers:
  - env:
    - name: APP_COLOR
      value: green
    image: kodekloud/webapp-color
    imagePullPolicy: Always
    name: webapp-color
```  

**Command**  
```bash
kubectl replace -f <yaml-file> --force
```  

**Details**  
- Pod Name: `webapp-color`  
- Label Name: `webapp-color`  
- Env: `APP_COLOR=green`  


### Q. 8  
**Task**  
Create a new ConfigMap named `cm-3392845` with the given literals.  

**Solution**  
```bash
kubectl create configmap cm-3392845 --from-literal=DB_NAME=SQL3322 --from-literal=DB_HOST=sql322.mycompany.com --from-literal=DB_PORT=3306
```  

**Details**  
- ConfigMap Name: `cm-3392845`  
- Data: `DB_NAME=SQL3322`, `DB_HOST=sql322.mycompany.com`, `DB_PORT=3306`  


### Q. 9  
**Task**  
Create a new Secret named `db-secret-xxdf` with the given literals.  

**Solution**  
```bash
kubectl create secret generic db-secret-xxdf --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123
```  

**Details**  
- Secret Name: `db-secret-xxdf`  
- Secrets: `DB_Host=sql01`, `DB_User=root`, `DB_Password=password123`  


### Q. 10  
**Task**  
Update pod `app-sec-kff3345` to run as Root user and with the `SYS_TIME` capability.  

**Solution YAML**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-sec-kff3345
  namespace: default
spec:
  securityContext:
    runAsUser: 0
  containers:
  - command:
    - sleep
    - "4800"
    image: ubuntu
    name: ubuntu
    securityContext:
     capabilities:
        add: ["SYS_TIME"]
```  

**Details**  
- Pod Name: `app-sec-kff3345`  
- Image Name: `ubuntu`  
- SecurityContext: `Capability SYS_TIME`  


### Q. 11  
**Task**  
Export the logs of the `e-com-1123` pod to the file `/opt/outputs/e-com-1123.logs`. Identify the namespace first.  

**Solution**  
```bash
kubectl logs e-com-1123 --namespace <namespace> > /opt/outputs/e-com-1123.logs
```  
（假设命名空间为 `e-commerce`，需先用 `kubectl get pods -A` 确认）  

**Details**  
- Task Completed  


### Q. 12  
**Task**  
Create a Persistent Volume with the given specification.  

**Solution YAML**  
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-analytics
spec:
  capacity:
    storage: 100Mi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteMany
  hostPath:
      path: /pv/data-analytics
```  

**Details**  
- Volume Name: `pv-analytics`  
- Storage: `100Mi`  
- Access modes: `ReadWriteMany`  
- Host Path: `/pv/data-analytics`  


### Q. 13  
**Task**  
1. Create a redis deployment with `redis:alpine`, 1 replica, label `app=redis`.  
2. Expose via ClusterIP service `redis` on port 6379.  
3. Create Ingress NetworkPolicy `redis-access` allowing only pods with label `access=redis` to access.  

**Solution**  
1. Deployment:  
   ```bash
   kubectl create deployment redis --image=redis:alpine --replicas=1 -l app=redis
   ```  
2. Service:  
   ```bash
   kubectl expose deployment redis --name=redis --port=6379 --target-port=6379
   ```  
3. NetworkPolicy YAML:  
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: redis-access
     namespace: default
   spec:
     podSelector:
       matchLabels:
          app: redis
     policyTypes:
     - Ingress
     ingress:
     - from:
       - podSelector:
           matchLabels:
             access: redis
       ports:
        - protocol: TCP
          port: 6379
   ```  

**Details**  
- Image: `redis:alpine`  
- Deployment/Service created correctly  
- NetworkPolicy allows `access=redis` pods  


### Q. 14  
**Task**  
Create a Pod called `sega` with two containers:  
- Container 1: `tails`, image `busybox`, command `sleep 3600`.  
- Container 2: `sonic`, image `nginx`, ENV `NGINX_PORT=8080`.  

**Solution YAML**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sega
spec:
  containers:
  - image: busybox
    name: tails
    command:
    - sleep
    - "3600"
  - image: nginx
    name: sonic
    env:
    - name: NGINX_PORT
      value: "8080"
```  

**Details**  
- Container `sonic`: ENV `NGINX_PORT=8080`  
- Container `tails` created correctly  
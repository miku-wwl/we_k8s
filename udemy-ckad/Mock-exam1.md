### Q. 1  
**Task**  
Deploy a pod named nginx-448839 using the nginx:alpine image.  
Once done, click on the Next Question button in the top right corner of this panel. You may navigate back and forth freely between all questions. Once done with all questions, click on End Exam. Your work will be validated at the end and score shown. Good Luck!  

**Solution**  
Use the command `kubectl run  nginx-448839 --image=nginx:alpine`  

**Details**  
- Name: nginx-448839  
- Image: nginx:alpine  


### Q. 2  
**Task**  
Create a namespace named apx-z993845  

**Solution**  
Run the command `kubectl create namespace apx-z993845`  

**Details**  
- Namespace: apx-z993845  


### Q. 3  
**Task**  
Create a new Deployment named httpd-frontend with 3 replicas using image httpd:2.4-alpine  

**Solution**  
Command: `kubectl create deployment httpd-frontend --image=httpd:2.4-alpine --replicas=3`  

**Details**  
- Name: httpd-frontend  
- Replicas: 3  
- Image: httpd:2.4-alpine  


### Q. 4  
**Task**  
Deploy a messaging pod using the redis:alpine image with the labels set to tier=msg.  

**Solution**  
Use the command `kubectl run messaging --image=redis:alpine -l tier=msg`  

**Details**  
- Pod Name: messaging  
- Image: redis:alpine  
- Labels: tier=msg  


### Q. 5  
**Task**  
A replicaset rs-d33393 is created. However the pods are not coming up. Identify and fix the issue.  
Once fixed, ensure the ReplicaSet has 4 Ready replicas.  

**Solution**  
The image used for the replicaset should be `busybox` instead of `busyboxXXXXXXX`. Use `kubectl edit rs rs-d33393` to fix the image. Then delete all PODs to provision new ones with the new image.  

**Details**  
- Replicas: 4  


### Q. 6  
**Task**  
Create a service messaging-service to expose the redis deployment in the marketing namespace within the cluster on port 6379.  
Use imperative commands  

**Solution**  
Run the command `kubectl expose deployment redis --port=6379 --name messaging-service --namespace marketing`  

**Details**  
- Service: messaging-service  
- Port: 6379  
- Use the right type of Service  
- Use the right labels  


### Q. 7  
**Task**  
Update the environment variable on the pod webapp-color to use a green background.  

**Solution**  
Set the environment variable `APP_COLOR` to `green`  
Here is the solution YAML file:  
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2021-07-24T04:54:05Z"
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
Recreate the existing pod with the above YAML file. You can make use of the replace command like this:  
`kubectl replace -f <above yaml file> --force`. This will delete the old pod and replace it with the new one with the configuration defined in the YAML file.  

**Details**  
- Pod Name: webapp-color  
- Label Name: webapp-color  
- Env: `APP_COLOR=green`  


### Q. 8  
**Task**  
Create a new ConfigMap named cm-3392845. Use the spec given on the below.  

**Solution**  
Use the command `kubectl create configmap cm-3392845 --from-literal=DB_NAME=SQL3322 --from-literal=DB_HOST=sql322.mycompany.com --from-literal=DB_PORT=3306`  

**Details**  
- ConfigMap Name: cm-3392845  
- Data: `DB_NAME=SQL3322`  
- Data: `DB_HOST=sql322.mycompany.com`  
- Data: `DB_PORT=3306`  


### Q. 9  
**Task**  
Create a new Secret named db-secret-xxdf with the data given (on the below).  

**Solution**  
Run command `kubectl create secret generic db-secret-xxdf --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123`  

**Details**  
- Secret Name: db-secret-xxdf  
- Secret 1: `DB_Host=sql01`  
- Secret 2: `DB_User=root`  
- Secret 3: `DB_Password=password123`  


### Q. 10  
**Task**  
Update pod app-sec-kff3345 to run as Root user and with the SYS_TIME capability.  

**Solution**  
Add `SYS_TIME` capability to the container's securityContext.  
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
- Pod Name: app-sec-kff3345  
- Image Name: ubuntu  
- SecurityContext: Capability `SYS_TIME`  


### Q. 11  
**Task**  
Export the logs of the e-com-1123 pod to the file `/opt/outputs/e-com-1123.logs`  
It is in a different namespace. Identify the namespace first.  

**Solution**  
Run the command `kubectl logs e-com-1123 --namespace e-commerce > /opt/outputs/e-com-1123.logs`  

**Details**  
- Task Completed  


### Q. 12  
**Task**  
Create a Persistent Volume with the given specification.  

**Solution**  
The solution is provided below:  
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
- Volume Name: pv-analytics  
- Storage: 100Mi  
- Access modes: ReadWriteMany  
- Host Path: `/pv/data-analytics`  


### Q. 13  
**Task**  
Create a redis deployment using the image redis:alpine with 1 replica and label `app=redis`. Expose it via a ClusterIP service called `redis` on port 6379. Create a new Ingress Type NetworkPolicy called `redis-access` which allows only the pods with label `access=redis` to access the deployment.  

**Solution**  
1. To create deployment:  
   `kubectl create deployment redis --image=redis:alpine --replicas=1 --labels=app=redis`  
2. To expose the deployment using ClusterIP:  
   `kubectl expose deployment redis --name=redis --port=6379 --target-port=6379`  
3. To create ingress rule:  
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
- Image: redis:alpine  
- Deployment created correctly?  
- Service created correctly?  
- Network Policy allows the correct pods?  
- Network Policy applied on the correct pods?  


### Q. 14  
**Task**  
Create a Pod called `sega` with two containers:  
- Container 1: Name `tails` with image `busybox` and command: `sleep 3600`.  
- Container 2: Name `sonic` with image `nginx` and Environment variable: `NGINX_PORT` with the value `8080`.  

**Solution**  
The pod yaml file should be:  
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
- Container Sonic has the correct ENV name  
- Container Sonic has the correct ENV value  
- Container tails created correctly?  
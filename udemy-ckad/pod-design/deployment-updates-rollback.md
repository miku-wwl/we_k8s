### **案例：部署并更新一个简单的Nginx应用**

#### **1. 创建初始Deployment**
首先，我们创建一个部署Nginx 1.14.2版本的Deployment：

```yaml
# deployment-v1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2  # 使用1.14.2版本
        ports:
        - containerPort: 80
```

**部署命令：**
```bash
kubectl apply -f deployment-v1.yaml
```


#### **2. 更新Deployment（版本升级）**
将Nginx从1.14.2升级到1.16.1：

```yaml
# deployment-v2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.16.1  # 更新为1.16.1版本
        ports:
        - containerPort: 80
```

**更新命令：**
```bash
kubectl apply -f deployment-v2.yaml
```


#### **3. 回滚Deployment（版本回退）**
假设1.16.1版本有问题，需要回退到1.14.2：

**查看历史版本：**
```bash
kubectl rollout history deployment/nginx-deployment
```

**回滚到上一个版本：**
```bash
kubectl rollout undo deployment/nginx-deployment
```

**回滚到指定版本（例如版本1）：**
```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=1
```


#### **4. 查看更新状态**
```bash
kubectl rollout status deployment/nginx-deployment
```


### **练习题**

#### **题目1：创建并更新Deployment**
1. 创建一个名为`myapp-deployment`的Deployment，使用`httpd:2.4`镜像，副本数为2。
2. 将镜像更新为`httpd:2.4.57`。
3. 验证所有Pod都运行在新版本上。

**解题步骤：**
1. 创建`httpd-v1.yaml`文件：
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: myapp-deployment
   spec:
     replicas: 2
     selector:
       matchLabels:
         app: httpd
     template:
       metadata:
         labels:
           app: httpd
       spec:
         containers:
         - name: httpd
           image: httpd:2.4
   ```
2. 部署并验证：
   ```bash
   kubectl apply -f httpd-v1.yaml
   kubectl get pods -l app=httpd
   ```
3. 创建`httpd-v2.yaml`文件，修改镜像为`httpd:2.4.57`。
4. 更新并验证：
   ```bash
   kubectl apply -f httpd-v2.yaml
   kubectl rollout status deployment/myapp-deployment
   kubectl get pods -l app=httpd -o jsonpath='{.items[*].spec.containers[*].image}'
   ```


#### **题目2：模拟失败的更新并回滚**
1. 创建一个名为`buggy-deployment`的Deployment，使用`nginx:1.25`镜像，副本数为3。
2. 尝试更新为不存在的镜像`nginx:99.99`。
3. 观察更新失败，回滚到上一个版本。

**解题步骤：**
1. 创建`buggy-v1.yaml`文件：
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: buggy-deployment
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: nginx
     template:
       metadata:
         labels:
           app: nginx
       spec:
         containers:
         - name: nginx
           image: nginx:1.25
   ```
2. 部署并验证：
   ```bash
   kubectl apply -f buggy-v1.yaml
   kubectl get pods -l app=nginx
   ```
3. 创建`buggy-v2.yaml`文件，修改镜像为`nginx:99.99`。
4. 更新并观察失败：
   ```bash
   kubectl apply -f buggy-v2.yaml
   kubectl rollout status deployment/buggy-deployment  # 会卡住
   kubectl get pods -l app=nginx  # 会看到Pod处于ImagePullBackOff状态
   ```
5. 回滚：
   ```bash
   kubectl rollout undo deployment/buggy-deployment
   kubectl rollout status deployment/buggy-deployment  # 等待回滚完成
   ```


### **关键概念总结**
1. **声明式更新**：通过修改YAML文件并重新`apply`实现。
2. **滚动更新**：默认策略，逐步替换旧Pod，确保服务可用性。
3. **回滚机制**：基于Deployment的版本历史，可以随时回退到任意版本。
4. **状态查看**：使用`kubectl rollout status`和`kubectl get pods`验证更新结果。
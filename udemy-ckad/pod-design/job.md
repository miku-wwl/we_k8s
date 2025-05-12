### 一、基础案例：Hello World Job
#### 案例说明
创建一个Job，启动一个Pod执行`echo "Hello World"`命令，执行完成后Pod自动终止。

#### 声明式YAML文件（job-hello.yaml）
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello-world-job
spec:
  template:
    spec:
      containers:
      - name: hello-container
        image: busybox:1.36
        command: ["echo", "Hello World from Kubernetes Job!"]
      restartPolicy: Never  # 任务完成后不重启容器
  backoffLimit: 4  # 失败时重试4次（默认值为6，此处显式设置）
```

#### 关键字段解析
1. **apiVersion**：指定API版本，1.32版本使用`batch/v1`
2. **template.spec.containers**：定义Pod的容器配置
3. **restartPolicy: Never**：确保任务完成后Pod不会重启
4. **backoffLimit**：控制失败重试次数（默认6次，此处设置为4）

#### 执行与验证
1. 创建Job：
```bash
kubectl apply -f job-hello.yaml
```

2. 查看Job状态：
```bash
kubectl get jobs
# 输出示例：
# NAME              COMPLETIONS   DURATION   AGE
# hello-world-job   1/1           3s         10s
```

3. 查看Pod日志：
```bash
kubectl logs $(kubectl get pods -l job-name=hello-world-job -o jsonpath='{.items[0].metadata.name}')
# 输出：Hello World from Kubernetes Job!
```

4. 删除Job：
```bash
kubectl delete job hello-world-job
```

### 二、进阶案例：并行任务处理
#### 案例说明
创建一个Job，并行执行3个Pod，每个Pod打印当前时间并休眠10秒，总共需要完成6次任务。

#### 声明式YAML文件（job-parallel.yaml）
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: time-job
spec:
  completions: 6      # 总共需要6次成功执行
  parallelism: 3      # 同时运行3个Pod
  template:
    spec:
      containers:
      - name: time-container
        image: busybox:1.36
        command: ["sh", "-c", "date; sleep 10"]
      restartPolicy: Never
```

#### 关键字段解析
1. **completions: 6**：指定总任务完成次数
2. **parallelism: 3**：控制并行执行的Pod数量
3. **command**：使用`date`打印时间，`sleep 10`模拟任务耗时

#### 执行与验证
1. 创建Job：
```bash
kubectl apply -f job-parallel.yaml
```

2. 观察Pod创建过程：
```bash
watch kubectl get pods -l job-name=time-job
# 输出示例：
# NAME              READY   STATUS      RESTARTS   AGE
# time-job-abc123   0/1     Completed   0          12s
# time-job-def456   0/1     Completed   0          12s
# time-job-xyz789   0/1     Completed   0          12s
```

3. 查看Job统计信息：
```bash
kubectl describe job time-job
# 输出中会显示成功完成的Pod数量
```

### 三、练习题及解答
#### 练习1：调整任务重试次数
**题目**：修改基础案例的Job配置，将失败重试次数改为2次，并验证效果。

**解答步骤**：
1. 修改`backoffLimit`为2：
```yaml
backoffLimit: 2
```

2. 故意让任务失败（例如将命令改为错误指令）：
```yaml
command: ["false"]  # 此命令会返回非零退出码
```

3. 应用配置并观察重试次数：
```bash
kubectl apply -f job-hello.yaml
kubectl describe job hello-world-job
# 事件中会显示2次重试后失败
```

#### 练习2：实现斐波那契数列计算
**题目**：创建一个Job，计算斐波那契数列的第10项并输出结果。

**解答步骤**：
1. 编写YAML文件（job-fibonacci.yaml）：
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: fibonacci-job
spec:
  template:
    spec:
      containers:
      - name: fib-container
        image: python:3.10
        command: ["python", "-c", "def fib(n): return n if n <=1 else fib(n-1)+fib(n-2); print(fib(10))"]
      restartPolicy: Never
```

2. 执行并验证结果：
```bash
kubectl apply -f job-fibonacci.yaml
kubectl logs $(kubectl get pods -l job-name=fibonacci-job -o jsonpath='{.items[0].metadata.name}')
# 输出应为55
```

#### 练习3：故障排查
**题目**：Job创建后Pod一直处于Pending状态，如何排查？

**解答步骤**：
1. 查看Pod事件：
```bash
kubectl describe pod <pod-name>
# 检查是否有资源不足或调度失败的提示
```

2. 检查节点资源：
```bash
kubectl top nodes
# 确认节点有足够的CPU/内存资源
```

3. 验证镜像是否存在：
```bash
kubectl describe pod <pod-name> | grep "Failed to pull image"
# 若存在镜像拉取失败，检查镜像名称和仓库权限
```

### 四、核心概念总结
1. **Job类型**：
   - Non-parallel Jobs：默认类型，单个Pod执行任务
   - Parallel Jobs：通过`completions`和`parallelism`控制并行度

2. **关键参数**：
   - `completions`：总任务完成次数
   - `parallelism`：并行执行的Pod数量
   - `backoffLimit`：失败重试次数
   - `activeDeadlineSeconds`：任务超时时间（可选）

3. **状态检查**：
   - `kubectl get jobs`：查看Job状态摘要
   - `kubectl describe job`：获取详细执行信息
   - `kubectl logs`：查看Pod输出内容
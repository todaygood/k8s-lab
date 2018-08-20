# What is DaemonSet 

   DaemonSet 确保全部（或者某些）节点上运行一个 Pod 的副本。当有节点加入集群时，也会为他们新增一个 Pod 。 当有节点从集群移除时，这些 Pod 也会被回收。删除 DaemonSet 将会删除它创建的所有 Pod。
   简单来说就是DaemonSet就是让一个应用在所有的k8s集群节点上都运行一个副本。典型的应用包括：

   - 日志收集，比如Fluentd，Logstash等

   - 系统监控，比如Prometheus Node Exporter，Collectd，New Relic agent，Ganglia gmond等

   - 系统程序，比如Kube-proxy, Kube-dns, Glusterd, Ceph等


实际上Kubernetes自己本身就在用DaemonSet运行自己的系统组件，下面目睹下。

```bash

[root@k8s-1 ~]# kubectl get daemonset -n kube-system
NAME              DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR                   AGE
kube-flannel-ds   2         2         2         2            2           beta.kubernetes.io/arch=amd64   23h
kube-proxy        2         2         2         2            2           beta.kubernetes.io/arch=amd64   23h
[root@k8s-1 ~]# kubectl describe daemonset kube-proxy 
Error from server (NotFound): daemonsets.extensions "kube-proxy" not found
[root@k8s-1 ~]# kubectl describe daemonset kube-proxy  -n kube-system
Name:           kube-proxy
Selector:       k8s-app=kube-proxy
Node-Selector:  beta.kubernetes.io/arch=amd64
Labels:         k8s-app=kube-proxy
Annotations:    <none>
Desired Number of Nodes Scheduled: 2
Current Number of Nodes Scheduled: 2
Number of Nodes Scheduled with Up-to-date Pods: 2
Number of Nodes Scheduled with Available Pods: 2
Number of Nodes Misscheduled: 0
Pods Status:  2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:           k8s-app=kube-proxy
  Annotations:      scheduler.alpha.kubernetes.io/critical-pod=
  Service Account:  kube-proxy
  Containers:
   kube-proxy:
    Image:      k8s.gcr.io/kube-proxy-amd64:v1.11.2
    Port:       <none>
    Host Port:  <none>
    Command:
      /usr/local/bin/kube-proxy
      --config=/var/lib/kube-proxy/config.conf
    Environment:  <none>
    Mounts:
      /lib/modules from lib-modules (ro)
      /run/xtables.lock from xtables-lock (rw)
      /var/lib/kube-proxy from kube-proxy (rw)
  Volumes:
   kube-proxy:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      kube-proxy
    Optional:  false
   xtables-lock:
    Type:          HostPath (bare host directory volume)
    Path:          /run/xtables.lock
    HostPathType:  FileOrCreate
   lib-modules:
    Type:          HostPath (bare host directory volume)
    Path:          /lib/modules
    HostPathType:  
Events:            <none>

```

## 删除DaemonSet 

删除时会自动删除所有的POD, 但如果加参数--cascade参数时，`kubectl delete --cascade=false` 会保留POD


# DaemonSet和其他的资源对象异同

## 静态 Pod

可能需要通过在一个指定目录下编写文件来创建 Pod，该目录受 Kubelet 所监视。这些 Pod 被称为 静态 Pod。 不像 DaemonSet，静态 Pod 不受 kubectl 和其它 Kubernetes API 客户端管理。静态 Pod 不依赖于 apiserver，这使得它们在集群启动的情况下非常有用。 而且，未来静态 Pod 可能会被废弃掉; 

如 kubeadm安装后的api server就是这种静态POD, 它监视/etc/kubernetes/manifests/目录，自动重启。


## Replication Controller

DaemonSet 与 Replication Controller 非常类似，它们都能创建 Pod，这些 Pod 对应的进程都不希望被终止掉（例如，Web 服务器、存储服务器）。 为无状态的 Service 使用 Replication Controller，比如前端（Frontend）服务，实现对副本的数量进行扩缩容、平滑升级，比之于精确控制 Pod 运行在某个主机上要重要得多。 需要 Pod 副本总是运行在全部或特定主机上，并需要先于其他 Pod 启动，当这被认为非常重要时，应该使用 Daemon Controller。

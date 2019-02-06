
# 手动安装k8s集群

版本1.11.2

## Step0- Plan

准备搭建一个2个节点的k8s cluster ,网络插件使用flanel。

主机名
- k8s-0  192.168.122.167
- k8s-1  192.168.122.253 

是2个centos7.5 kvm虚拟机。

## Step1- 准备，在每一个node上运行

1. disable selinux, swap off 
2. install docker community version  17.03.2-ce
3. add k8s.repo, yum install -y kubelet kubeadm kubectl 
   systemctl enable kubelet && systemctl start kubelet
   
4. adjust parameter 
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

## step2- 安装master

这一步仅仅在master上运行，是master bootstrap 


5. download docker image from vps ,import into system.

在kubeadm init过程中要从google服务器下载image,但国内是访问不了的，建议在一个kvm vps中docker pull下来，然后
docker save ,docker load 的方法导入到master node .

k8s.gcr.io/kube-apiserver-amd64:v1.11.2
k8s.gcr.io/kube-controller-manager-amd64:v1.11.2
k8s.gcr.io/kube-scheduler-amd64:v1.11.2
k8s.gcr.io/kube-proxy-amd64:v1.11.2
k8s.gcr.io/pause:3.1
k8s.gcr.io/coredns:1.1.3
k8s.gcr.io/etcd-amd64:3.2.18



6. kubeadm init 

因为我准备采用flanel的网络插件，所以需要加上--pod-network-cidr参数

`kubeadm -v 100 init  --pod-network-cidr=10.244.0.0/16`

注意加上-v 100, 可以看到具体的过程，如果成功，可以看到如下输出：

```log
Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 192.168.122.253:6443 --token py7af9.p3vdwsso4pxqh1j5 --discovery-token-ca-cert-hash sha256:ab75e7c27135505c1558b29ad2ab6383eeab96fcef7856a85ecdbcd6da38327d
```

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

7. deploy a pod network to the cluster

```bash
[root@k8s-1 opt]# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.extensions/kube-flannel-ds created
```
此过程会下载quay.io/coreos/flannel:v0.10.0-amd64 image,如果需要翻墙，需提前准备。

```bash
[root@k8s-1 opt]# kubectl get nodes
NAME                      STATUS     ROLES     AGE       VERSION
k8s-1.cloud.genomics.cn   NotReady   master    7m        v1.11.2
[root@k8s-1 opt]# kubectl get podes
error: the server doesn't have a resource type "podes"
[root@k8s-1 opt]# kubectl get pods
No resources found.
[root@k8s-1 opt]# kubectl get pods --all-namespaces
NAMESPACE     NAME                                              READY     STATUS    RESTARTS   AGE
kube-system   coredns-78fcdf6894-66sck                          1/1       Running   0          7m
kube-system   coredns-78fcdf6894-zrc96                          1/1       Running   0          7m
kube-system   etcd-k8s-1.cloud.genomics.cn                      1/1       Running   0          7m
kube-system   kube-apiserver-k8s-1.cloud.genomics.cn            1/1       Running   0          6m
kube-system   kube-controller-manager-k8s-1.cloud.genomics.cn   1/1       Running   0          7m
kube-system   kube-flannel-ds-hgg58                             1/1       Running   0          50s
kube-system   kube-proxy-mg4q2                                  1/1       Running   0          7m
kube-system   kube-scheduler-k8s-1.cloud.genomics.cn            1/1       Running   0          6m
[root@k8s-1 opt]# kubectl get node
NAME                      STATUS    ROLES     AGE       VERSION
k8s-1.cloud.genomics.cn   Ready     master    9m        v1.11.2
```

## Step3- 加入node 


在每一个待加入cluster的node上面运行kubeadm join 

```bash
[root@k8s-0 ~]# kubeadm join 192.168.122.253:6443 --token py7af9.p3vdwsso4pxqh1j5 --discovery-token-ca-cert-hash sha256:ab75e7c27135505c1558b29ad2ab6383eeab96fcef7856a85ecdbcd6da38327d
[preflight] running pre-flight checks
	[WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh] or no builtin kernel ipvs support: map[ip_vs:{} ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{} nf_conntrack_ipv4:{}]
you can solve this problem with following methods:
 1. Run 'modprobe -- ' to load missing kernel modules;
2. Provide the missing builtin kernel ipvs support

I0819 03:38:16.899124   30732 kernel_validator.go:81] Validating kernel version
I0819 03:38:16.902550   30732 kernel_validator.go:96] Validating kernel config
	[WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
[discovery] Trying to connect to API Server "192.168.122.253:6443"
[discovery] Created cluster-info discovery client, requesting info from "https://192.168.122.253:6443"
[discovery] Requesting info from "https://192.168.122.253:6443" again to validate TLS against the pinned public key
[discovery] Cluster info signature and contents are valid and TLS certificate validates against pinned roots, will use API Server "192.168.122.253:6443"
[discovery] Successfully established connection with API Server "192.168.122.253:6443"
[kubelet] Downloading configuration for the kubelet from the "kubelet-config-1.11" ConfigMap in the kube-system namespace
[kubelet] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[preflight] Activating the kubelet service
[tlsbootstrap] Waiting for the kubelet to perform the TLS Bootstrap...
[patchnode] Uploading the CRI Socket information "/var/run/dockershim.sock" to the Node API object "k8s-0.cloud.genomics.cn" as an annotation

This node has joined the cluster:
* Certificate signing request was sent to master and a response
  was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```

## Step4- 查看安装结果

```bash
[root@k8s-1 opt]# kubectl get nodes
NAME                      STATUS     ROLES     AGE       VERSION
k8s-0.cloud.genomics.cn   NotReady   <none>    14s       v1.11.2
k8s-1.cloud.genomics.cn   Ready      master    17m       v1.11.2
```

过一会儿，可以看到从NotReady状态变化到Ready状态。

```bash
[root@k8s-1 opt]# kubectl get nodes
NAME                      STATUS    ROLES     AGE       VERSION
k8s-0.cloud.genomics.cn   Ready     <none>    26m       v1.11.2
k8s-1.cloud.genomics.cn   Ready     master    44m       v1.11.2
```

### 测试DNS

测试dns 
```bash
[root@k8s-0 ~]# kubectl run curl --image=radial/busyboxplus:curl -i --tty
If you don't see a command prompt, try pressing enter.
[ root@curl-87b54756-gprn5:/ ]$ nslookup kubernetes
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
[ root@curl-87b54756-gprn5:/ ]$ nslookup my-nginx
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      my-nginx
Address 1: 10.106.115.252 my-nginx.default.svc.cluster.local
```
### modify config 
如果要修改如api-server的配置， api server等是安装过程中用容器来做的k8s服务
可以直接修改/etc/kubernetes/manifests目录下的文件
```bash
[root@k8s-1 manifests]# pwd
/etc/kubernetes/manifests
[root@k8s-1 manifests]# ls
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
```

参见 https://github.com/kubernetes/kubeadm/issues/106




# Ref

https://blog.csdn.net/godwei_ding/article/details/78501803

https://kubernetes.io/docs/setup/independent/install-kubeadm/

https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

https://www.do1618.com/archives/1164/kubeadm-centos-7-4-%E5%AE%89%E8%A3%85-kubernetes-1-9-1/

各种问题参见

https://tonybai.com/2016/12/30/install-kubernetes-on-ubuntu-with-kubeadm/

https://juejin.im/post/5b45d4185188251ac062f27c


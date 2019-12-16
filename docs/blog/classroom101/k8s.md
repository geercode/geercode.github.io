<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

## 一、综述

## 二、资源对象

```
宏观上看:node(节点,实体物理机）
微观上看:pod(有独立ip的虚拟容器)

service:负载均衡的一个虚拟ip (ClusterIP、NodePort、LoadBalancer、ExternalName、externalIPs、Ingress)
container:pod中的服务进程,与pod共享一个ip

deployment:一次编排发布

```

## 三、服务发现

* 环境变量
* dns

## 四、网络组件(过于复杂引起不适极度醒脑)

k8s整个构架于每个pod都拥有一个唯一的ip地址、并且在集群中所有ip都互通这两个假设上,并开发CNI标准的插件接口,供三方网络插件进行接入开发，本身
并不关注节点与节点之间的通信方式

* kube-proxy 开启ipvs模式,使用ipvs管理大量路由规则，较单纯使用iptables性能提升明显
* iptables
* 插件
    * flannel 隧道技术 overlay网络 p2p
    * calico BGP 路由 有ACL权限管理 标准三层
    * canal 上面二者结合,calico的权限管理，flannel的网络方案
    * kube-router
    
```
大白话版：
1.节点之内通过docker建立bridge网络通信
2.节点之间通过插件通信与管理ip
3.安装kube-proxy以便集群控制,通过管理iptables与调用插件来调整网络
4.kube-proxy与绝大多数插件都会把路由信息存储在etcd中
```

[Kubernetes中文社区 | Kubernetes网络原理及方案](https://www.kubernetes.org.cn/2059.html)

[官方文档 | service的网络跟概念](https://kubernetes.io/docs/concepts/services-networking/service/)

[网络暴露后的请求过程](https://cloud.tencent.com/developer/news/299556)

[图解Kubernetes网络](http://dockone.io/article/3211)

## 五、命令

* kubectl

## 六、addson

```
一些官方推荐安装的容器组件
```

## 七、helm

```
类似linux上的包管理器、手机上的应用商店，用来一键安装官方调试好的image与配置
```

[Helm Hub](https://hub.helm.sh/)

## 八、lstio

```
搞不清楚模糊的 SERVICE MESH 跟 微服务 概念有啥太大的区别
service mesh更侧重与网络，是代理转发实现微服务要实现的网络目标，是一种组件
微服务更倾向于对业务的拆解，讲究服务拆分细化的粒度,与讲求devops的大环境比较贴合，是一种模式

1.通过同步容器内注册的资源服务信息来维护信息，同时也可以不依赖容器使用
2.通过sidecar的模式劫持pod内的数据包来代理转发请求与相应，功能打包了服务发现、负载均衡、灰度路由、熔断、trace、metrics等微服务关键功能
注：springcloud没有一个完善的网络灰度隔离方案，唯一一个开源的是军哥的discovery项目 https://github.com/Nepxion/Discovery
3.拥有统一管理的管理界面、较原生k8s会好一些

lstio是k8s社区推荐的一个service mesh组件，蚂蚁金服的 sofa-mesh 是基于lstio的改造项目，主要是对bolt、dubbo等协议的扩充支持，还有一些
基于他们自身情况的增强
```

## 九、推荐文档

[Kubernetes中文社区 | 中文文档](http://docs.kubernetes.org.cn/)

[Kubernetes国人维护者倪鹏飞 | gitbook中文维护版](https://feisky.gitbooks.io/kubernetes/)
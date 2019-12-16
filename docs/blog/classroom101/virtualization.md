<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

* 种类
    * 硬件虚拟化(全虚拟化)
        * hypervisor
        * kvm
        * QEMU
        * kvm-qumu
        * EXSI
    * 系统虚拟化(半虚拟化)
        * vmware workstation
        * virtual box
    * 库函数虚拟化
        * lxc
    * 语言虚拟化
        * jvm
* 网络
    * 基础
        * 网络协议栈
            * netfilter(四表五链)
            * 路由
        * 虚拟设备
            * bridge
            * tun
            * tap
            * veth
        * namespaces
    * 模式
        * 网桥
        * NAT
        * HOST
        * BOND
        * VLAN
        * TUN
* 存储
    * lvm
    * Object
    * SCSI LUN
    * cifs
    * ntfs、ext4、btrfs、zfs、加密存储
* 常用方案
    * vmware
    * openstack
    * proxmox
    * lxc
    * docker
    * docker swarm
    * k8s
    
> 结论:
>> 1.阿里云是基于kvm+lvm的超大型虚拟系统，融合了其他多种虚拟化技术并自己研发了一些虚拟化的技术<br>
>> 2.docker是基于Linux Container容器沙盒技术的上层应用，swarm与k8s是为使用这些技术更为易用而产生的应用系统<br>
>> 3.每个云计算公司的网络方案与存储方案都不尽相同，k8s给各个云计算公司开放了网络与存储的接口，更为开放，已然战胜docker官方的swarm，底层的容器技术是可以替换的，docker并不是唯一选择
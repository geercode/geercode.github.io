<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

## 一、docker命令

* 镜像(image)
    * ***images***
    * ***rmi***
    * ***tag***
    * build
    * history
    * save
    * import
* 生命周期
    * ***run***
    * ***start/stop/restart***
    * ***kill***
    * ***rm***
    * pause/unpause
    * create
    * ***exec***
* 容器(container)
    * ***ps***
    * inspect
    * ***top***
    * attach
    * events
    * ***logs***
    * wait
    * export
    * port
* 容器rootfs命令
    * ***commit***
    * cp
    * diff
* 远程仓库(github或自建)
    * ***login***
    * ***pull***
    * ***push***
    * ***search***
* 本地文件管理
    * docker system info 查看docker信息
    * docker system df 查看docker使用文件情况,添加 -v 可以显示详细情况
    * docker rmi $(docker images -q) 删除全部镜像
    * docker rm $(docker ps -a -q) 删除全部container
    * docker rmi $(docker images | grep "^<none>" | awk "{print $3}") 删除所有tag没有标记，也就是显示为none的镜像,常用
    
## 二、docker 网络模式

* bridge
* container
* host
* none
* overlay
* macvlan

## 三、docker服务编排(docker-compose)

* docker network create
* docker-compose -f xxx.yml up
* docker-compose -f xxx.yml down
* docker-compose -f xxx.yml rm

```
创建网桥
docker network create -d bridge --subnet=172.18.0.0/16 --gateway 172.18.0.1 app-network
启动镜像
docker-compose -f xxx.yml up
示例配置文件

version: "3"
services:
  mysql:
    image: mysql:5.7
    container_name: mysql
    dns:
      - 119.29.29.29
      - 114.114.114.114
    networks:
      default:
        ipv4_address: 172.18.0.4
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=WeAreSuperman
    volumes:
      - /opt/mysql/conf:/etc/mysql/conf.d
      - /opt/mysql/data:/var/lib/mysql
networks:
  default:
    external:
      name: app-network
```

## 四、docker集群(docker swarm)

* docker swarm
* docker node
* docker stack


> 注：粗斜体为常用管理命令

> 拓展阅读
* [基于busybox构建最小linux Docker镜像系统](https://blog.csdn.net/hknaruto/article/details/70229896)
* [Alpine Linux 使用简介](https://blog.csdn.net/csdn_duomaomao/article/details/76152416)

## 五、docker工具

* Docker for Windows
* Kitematic

[docker官方文档](https://docs.docker.com/get-started/)
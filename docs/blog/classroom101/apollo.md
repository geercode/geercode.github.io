<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

## 一、概念
```
Env:逻辑环境(如dev,pro,uat)
namespace:配置文件名,支持多种格式(springboot中的application.properties支持springboot环境加载,其他均只看做配置文件,需要手动加载)
    (格式支持properties、xml、yml、yaml、json等)
cluster(idc):机房

注意:关于public namespace，只有管理员可以删除,但是每个小组都可以创建,全局唯一,所以不要自己创建，基础架构部门会有统一发布的公共namespace，
    springboot环境加载可以指定多个namespace,但是必须是properties格式的
    公共namespace应用场景:
        部门级别共享的配置
        小组级别共享的配置
        几个项目之间共享的配置
        中间件客户端的配置
附：yaml与properties互转地址  http://www.toyaml.com/index.html
```

## 二、配置

```
下面几项配置优先级依次递增
1.代码中:/META-INF/app.properties  apollo-env.properties
2.云服务器：server.properties (位置为/opt/settings/server.properties或C:\opt\settings\server.properties)
3.k8s：系统环境变量
4.命令行:
    java -jar
    -Dapp.id=YOUR-APP-ID
    -Denv=DEV
    -Dapollo.meta=http://config-service-url
    -Dapollo.cacheDir=/opt/data/some-cache-dir
    -Dapollo.cluster=SomeCluster
    xxx.jar

必选：
app.id 在apollo配置的逻辑appId
env apollo中环境的名称
apollo.meta apollo自带eureka注册地址
可选：
cacheDir 默认为
cluster(idc) 默认为default

tips:
1.指定启动环境的时候要在启动命令上加 -Denv=DEV或者使用server.properties进行指定
2.配置生效顺序为  apollo -> consul -> 本地配置文件，后面的配置不能替换前面的配置
```

`META-INF/app.properties`

```
app.id=api-gateway
```

`apollo-env.properties`

```
dev.meta=http://192.168.21.58:8058
uat.meta=http://172.16.199.138:8080
pro.meta=http://10.80.227.207:8080,http://10.29.183.7:8080
```

`bootstrap.yml`

```
# bootup的namespaces可以写多个，需要用逗号分开,默认即为application,仅支持properties类型的文件
apollo:
  bootstrap:
    enabled: true
    namespaces: application
```

`server.properties`

```
env=DEV
apollo.meta=http://192.168.21.58:8058
apollo.cacheDir=/home/jerry/personal/apollo
idc=default
```

## 三、规范

```
1.springboot项目需要在resource目录下添加3个文件
META-INF/app.properties
apollo-env.properties
bootstrap.yml
2.云服务器用server.properties文件来指定,个人如果需要指定也可以在自己开发环境上指定,尤其像我一样缓存位置没写入权限又不想改的可以改改缓存位置
    权限的问题用建立opt管理组把prod用户加入opt组来实现
3.k8s环境用系统环境变量指定
```

## 四、离线开发

```
先连上环境,启动一次把缓存配置文件下载下来，再在本地的server.properties文件中修改env=Local,就会利用本地的缓存配置文件去加载配置
```
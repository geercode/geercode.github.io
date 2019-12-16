<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

> <h1>elastic search 通用解决方案</h1>

```
整体流程：
数据库 -> logstash -> elastic search -> middleground中台服务 -> 各app后台 -> 前台展示
```

## 一、对应关系

数据库|es
---|---
database|index
table|type
column|column

> 注意:elastic search中type已经在逐步取消中,我们使用的6.x版本无法在一个index下创建多个type,默认用logstash同步过去的type为doc，
替代方案为index名命名规则为 ${database}-${table} 来映射我们数据库与索引的关系

## 二、版本信息

```
ELK(elastic search, logstash, kibana) version ：6.3.2
用到的插件：
    logstash-jdbc-input插件(安装包中有,但需要自己执行一下安装) ==> bin/logstash-plugin install logstash-input-jdbc
    smartcn中文分词 ==> elasticsearch-plugin install analysis-smartcn
    x-pack(很多跟安全相关的东西,测试环境并没有安装,生产安装的时候需要解决下这个问题)
```

## 三、配置信息

示例配置在[here](config)

> 注意：logstash启动不能用 & 将进程挂到后台,要用nohup启动 ==> nohup ./logstash > /dev/null 2>&1 &

## 四、elastic search 服务器角色

```
master node 主节点
data node 数据节点
ingest node 预处理节点
coordinating only node 负载均衡节点

默认安装四者都是
```

## 五、elastic search 安全

```
elastic search 默认的策略就是通过绑定IP号来进行安全隔离,单机的就是127.0.0.1,多节点的就是局域网地址,如果不是访问该ip对elastic search
进行访问,就会拒绝连接
需要用账号密码提升安全性的时候,需要安装x-pack插件,相应的kibana、logstash、与java客户端均需要安装x-pack才能进行访问
```

## 六、java客户端

```
兼容性最好的是TransportClient,底层是用tcp连接,使用9300端口
兼容性其次的是elasticsearch-rest-client,官方维护,各版本不会发生太大变化
使用性最好的是elasticsearch-rest-high-level-client,官方维护，基于elasticsearch-rest-client,加入了一些便利的用法
其他的客户端基本版本都跟不上更新
```

## 七、同步操作

* 创建索引(推荐使用kibana的devTool)

```
PUT jf_pay-comm_code_cnaps
{
  "settings": {
    "index.analysis.analyzer.default.type": "smartcn"
  },
  "mappings": {
    "doc": {
      "properties": {
        "bank_name": {
          "type": "text",
          "analyzer": "smartcn"
        }
      }
    }
  }
}

```

> 注意:由于默认同步到索引字符字段会变为keyword类型,以节省性能,必须要对需要进行分词检索的字段先创建索引，设置好字段类型跟分词器,然后再进行同步

* 启动logstash进行同步

```
需要注意的是,logstash-input-jdbc进行同步时对增量、更新、删除是直接进行查询实现的、示例配置文件中是以update_time为准进行增量更新、删除
需要修改当前的update_time,并修改逻辑删除字段来达到删除的目的,所以如果有需要删除的情况时,必须设置删除位字段(推荐isDel,与mybatis-plus默
认设置相同),update_time是必须的,需要用此字段进行增量更新
```

## 八、链接

[logstash-jdbc-input插件文档](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-jdbc.html)

[elastic search官方文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)

[kibana官方文档](https://www.elastic.co/guide/en/kibana/current/index.html)

> 初期接口会对 搜索、高亮、词补全、聚合 做一些通用的接口,如有更准确细致的需求可以提需求,讨论合作做一个方案出来

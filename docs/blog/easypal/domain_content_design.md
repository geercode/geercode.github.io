<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

### 内容领域需要应对的通用问题

#### 1.长连接双工通信

```
> Reactive RSocket websocket tls stomp 高性能连接器与转接器
```

* [spring官网webflux与websocket、stomp、Rsocket](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html#webflux-config-websocket-service)
* [响应式编程之网络新约：RSocket](https://blog.csdn.net/alex_xfboy/article/details/89704091)
* [游戏服务端典型架构](http://www.blogjava.net/landon/archive/2012/07/14/383092.html)
* [游戏服务端架构师博客](https://github.com/landon30/Bulls/wiki)

#### 2.实时定位LBS（附近）

```
> 低延时、针对场景优化、确定地理位置关系  mongo redis geohash
> redis mongo elasticsearch均有geohash方案
```

* [GeoHash算法解析及Redis支持GEO地理位置运用](https://zhuanlan.zhihu.com/p/38639394)

#### 3.关系

```
> 场景优化
> 图数据应用，点与边，通用查询API，C端简单模型优化，B端复杂查询支持
> TAO ByteGraph neo4j SparkGraphX Plato
> 简单图模型API一致，具体属性不同
```

* [架构解读-Facebook社交图谱TAO](https://zhuanlan.zhihu.com/p/158361250)
* [facebook 架构_facebook系统架构简介](https://blog.csdn.net/weixin_26714375/article/details/108907245)
* [Neo4j基础（详细）](https://www.jianshu.com/p/9e3c4892ab3e)
* [Spark GraphX学习（一）图（GraphX ）简介](https://blog.csdn.net/qq_41851454/article/details/80388443)
* [Gitee Plato](https://gitee.com/mirrors/plato)
* [字节跳动自研万亿级图数据库 & 图计算实践](https://blog.csdn.net/weixin_45825082/article/details/104497449?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-2.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-2.control)

#### 4.内容

```
> 场景优化
> feed流（时间线），pull & push 阈值
> 动态、朋友圈、微博
> 帖子、图片、评论、定位
> 删除、拉黑、标签、不让他看、三天可见（权限）
> 赞、踩、标签、回复、引用、分享

> 评论系统
>> 盖楼评论
>> 单层评论
>> 树状折叠

> 评论倒排缓存跨页拉取
> 敏感词过滤（AhoCorasickDoubleArrayTrie）
```

* [微信朋友圈设计原理](https://blog.csdn.net/u011212394/article/details/105170676)
* [AC自动机+双数组trie树](https://github.com/hankcs/AhoCorasickDoubleArrayTrie)
* [评论系统数据库设计及实现](https://www.cnblogs.com/godlovesme/p/10708358.html)
* [如何设计一个好的新闻或微博评论区点赞系统](https://www.zhihu.com/question/46215843)


#### 5.流计算

```
> 简单基本实时流计算需求
```



其中关系与内容均需要对内容有阈值扩散策略与缓存顶层设计，都有推荐、热度排序方面的需求

#### 现有问题

```
> 1.针对场景长连接与LBS需要优化，现有PUSH服务的IM与围栏服务功能重叠，能否复用？
> 2.关系与内容需要针对跨越网络阈值的内容单独设计一套扩散与查询存储逻辑
> 3.底层用mongo方便一些，social场景的一致性与事务性天然是要求较低的，最终一致性与可用性要求更高
```
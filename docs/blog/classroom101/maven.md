<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

## 一、maven工作流

### 1.生命周期(Lifecycle )
> Maven有三套相互独立的生命周期(Lifecycle )
> * Clean Lifecycle：做一些清理工作
> * Default Lifecycle：构建的核心部分、编译、测试、打包、部署等
> * Site Lifecycle：生成项目报告、站点、发布站点

### 2.阶段(Phase)
> Clean Lifecycle
> * pre-clean
> * clean
> * post-clean

> Site Lifecycle
> * pre-site
> * site
> * post-site
> * site-deploy

> Default Lifecycle
> * validate
> * initialize
> * generate-sources
> * process-sources
> * generate-resources
> * process-resources
> * compile
> * process-classes
> * generate-test-sources
> * process-test-sources
> * generate-test-resources
> * process-test-resources
> * test-compile
> * process-test-classes
> * test
> * prepare-package
> * package
> * pre-integration-test
> * integration-test
> * post-integration-test
> * verify
> * install
> * deploy

*更多内容请参考[官方文档](http://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle_Reference)*

## 二、maven继承

### 1.可继承的元素
* groupId：项目组ID，项目坐标的核心元素
* version：项目版本，项目坐标的核心因素
* description：项目的描述信息
* organization：项目的组织信息
* inceptionYear：项目的创始年份
* url：项目的URL地址
* developers：项目的开发者信息
* contributors：项目的贡献者信息
* distributionManagement：项目的部署配置
* issueManagement：项目的缺陷跟踪系统信息
* ciManagement：项目的持续集成系统信息
* scm：项目的版本控制系统信息
* malilingLists：项目的邮件列表信息
* properties：自定义的Maven属性
* dependencies：项目的依赖配置
* dependencyManagement：项目的依赖管理配置
* repositories：项目的仓库配置
* build：包括项目的源码目录配置、输出目录配置、插件配置、插件管理配置等
* reporting：包括项目的报告输出目录配置、报告插件配置等

### 2.依赖管理

```
    dependencies依赖的模块是可继承的,但是子模块丧失了选择的权利,pom描述依赖并没有依赖到的包,还会加大依赖冲突的几率
    dependencyManagement可以约束dependencies,当groupId、artifactId一致的情况下,会加载父模块的配置
```

### 3.插件管理

```
    pluginManagement管理plugin,当子模块声名了插件,并且groupId、artifactId一致的情况下,会加载父模块的配置
```

### 4.发布管理

```
    distributionManagement,项目的发布配置
```

### 5.聚合与继承的关系

* 区别
    * 对于聚合模块来说，它知道有哪些被聚合的模块，但那些被聚合的模块不知道这个聚合模块的存在
    * 对于继承关系的父POM来说，它不知道有哪些子模块继承与它，但那些子模块都必须知道自己的父POM是什么
* 共同点
    * 聚合POM与继承关系中的父POM的packaging都是pom
    * 聚合模块与继承关系中的父模块除了POM之外都没有实际的内容

![](../asset/classroom101/maven_extend_aggregate.png)

### 6.父模块构建

```
    聚合模块想要执行对应的maven命令但又不想影响子模块的构建配置,要设置plugin为<inherited>false</inherited>,reporting中对应的设置是
<reportSets><reportSet><inherited>false</inherited></reportSet></reportSets>
```

## 三、maven依赖

<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

### 1.基本概念

* Dependency mediation(依赖调解)
    * 最短路径优先
    * 路径长度一致,出现优先
    
![](../asset/classroom101/maven_mediation_01.png)

* Dependency scope(依赖范围)
    * scope可继承

scope|brief|life|description
---|---|---|---
compile|默认|对主代码有效,对测试代码有效,打包运行时有效|编译、打包、参与运行、传递依赖
test|测试时有效|对主代码无效,对测试代码有效,被打包运行时无效|测试编译、测试运行、不打包、不传递依赖
runtime|运行时有效|对主代码无效,对测试代码无效,被打包运行时有效|不编译、参与运行、打包、传递依赖
import|版本管理|只在dependencyManagement中使用|传递依赖
provided|运行时提供|对主代码有效,对测试代码有效,被打包运行时无效|参与编译、不打包、参与运行、不传递依赖
system|系统提供|不经常使用|需要提供systemPath属性、不到仓库拉取、从本地系统指定路径下寻找

![](../asset/classroom101/maven_scope_01.png)

* Dependency management(依赖管理)
    * dependencyManagement(依赖传递)
        * GA相同
    * pluginManagement(插件依赖传递)
        * 有plugin声名,GA相同,inherited为true(默认)
* Excluded dependencies(排除依赖)
    * dependencies -> dependency -> exclusions -> exclusion
* Optional dependencies(可选依赖)
    * dependencies -> dependency -> optional (true则依赖不会传递,需要显式声名,false则会传递)
    * 与provided的区别:provided的包在运行时应该提供,默认需要提供才会正常运行,optional的意思是不用该部分的功能就可以不提供。[quote:maven官方的解释](http://maven.apache.org/guides/introduction/introduction-to-optional-and-excludes-dependencies.html)
    
* 特殊情况:dependencyManagement与依赖传递同时存在不产生冲突却产生错误的情况,依赖调解会范围包括dependencyManagement中的元素,dependencyManagement中的依赖优先,虽然不产生冲突,但是版本发生了变化,会导致异常
    * 要在dependencyManagement中显示声名该包的版本,两个版本2选1,选择高版本不冲突的,如果做不到,就在子模块中显示声名该包,缩短声名路径

### 2.最佳实践
* dependencies(依赖继承) -管理项目的所有版本依赖
* bom(依赖继承) -列出本项目的所有可选组件
* parent(构建继承) -管理项目的构建
* build(聚合) -管理需要构建的模块
* flatten-maven-plugin(精简pom) -清理pom文件敏感与无用属性

> 依赖冲突示意

![](../asset/classroom101/maven_dependency_conflict.png)

> idea有关功能

```
右键pom.xml -> Maven -> Show Effective Pom -effective pom展示
安装插件Maven Helper -调试maven依赖冲突
```

## 四、maven插件

<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

> 所有pom都继承super pom,在在 maven-model-builder-{version}.jar 包的org/apache/maven/model 中的 pom-4.0.0.xml 这个文件
> 生命周期绑定文件在 maven-core-{version}.jar 包中META-INF/plexus/components.xml 中

### 1.默认插件

* maven-clean-plugin
* maven-resources-plugin
* maven-compiler-plugin
* maven-surefire-plugin
* maven-jar-plugin
* maven-install-plugin
* maven-deploy-plugin

### 2.优秀插件

主要插件来源于maven官方、codehaus、google code、开源组件自带
详情参考[maven官方文档](http://maven.apache.org/plugins/index.html)

### 3.开发插件

[开发插件链接](http://www.cnblogs.com/davenkin/p/advanced-maven-write-your-own-plugin.html)

注:目前对maven生命周期模型不再改动,开发插件以在生命周期的绑定阶段改变goal来实现,不再修改packaging属性

### 4.插件命令

插件|命令|作用
---|---|---
maven-dependency-plugin|mvn dependency:tree|项目依赖树分析
versions-maven-plugin|mvn versions:set|pom版本修改
~|mvn versions:revert|pom版本回退
~|mvn versions:commit|pom版本提交
maven-archetype-plugin|mvn archetype:generate|脚手架

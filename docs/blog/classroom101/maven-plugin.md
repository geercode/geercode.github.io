<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

> 所有pom都继承super pom,在在 maven-model-builder-{version}.jar 包的org/apache/maven/model 中的 pom-4.0.0.xml 这个文件
> 生命周期绑定文件在 maven-core-{version}.jar 包中META-INF/plexus/components.xml 中

## 一、默认插件

* maven-clean-plugin
* maven-resources-plugin
* maven-compiler-plugin
* maven-surefire-plugin
* maven-jar-plugin
* maven-install-plugin
* maven-deploy-plugin

## 二、优秀插件

主要插件来源于maven官方、codehaus、google code、开源组件自带
详情参考[maven官方文档](http://maven.apache.org/plugins/index.html)

## 三、开发插件

[开发插件链接](http://www.cnblogs.com/davenkin/p/advanced-maven-write-your-own-plugin.html)

注:目前对maven生命周期模型不再改动,开发插件以在生命周期的绑定阶段改变goal来实现,不再修改packaging属性

## 四、插件命令

插件|命令|作用
---|---|---
maven-dependency-plugin|mvn dependency:tree|项目依赖树分析
versions-maven-plugin|mvn versions:set|pom版本修改
~|mvn versions:revert|pom版本回退
~|mvn versions:commit|pom版本提交
maven-archetype-plugin|mvn archetype:generate|脚手架
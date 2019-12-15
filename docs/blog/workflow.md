# Maven的声明周期(Lifecycle )和阶段(Phase)
## 生命周期(Lifecycle )
> Maven有三套相互独立的生命周期(Lifecycle )
> * Clean Lifecycle：做一些清理工作
> * Default Lifecycle：构建的核心部分、编译、测试、打包、部署等
> * Site Lifecycle：生成项目报告、站点、发布站点

## 阶段(Phase)
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

_更多内容请参考[官方文档](http://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle_Reference)_
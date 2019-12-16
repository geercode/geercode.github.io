<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

> <h1>springboot基本使用辑录</h1>

* 上传maven私服仓库

```
1.在pom中添加
<project>
    <distributionManagement>
        <repository>
            <id>nexus</id>
            <name>hosted-release</name>
            <url>http://svn.xxx.com:8087/nexus/content/repositories/release</url>
        </repository>
        <snapshotRepository>
            <id>nexus</id>
            <name>hosted-snapshots</name>
            <url>http://svn.xxx.com:8087/nexus/content/repositories/snapshots</url>
        </snapshotRepository>
    </distributionManagement>
</project>
2.在maven settings.xml文件中添加
<settings>
    <servers>
        <server>
            <id>nexus</id>
            <username>管理账号</username>
            <password>管理密码</password>
        </server>
    </servers>
</settings>
注意:可以在maven根目录conf文件夹下修改，也可以在用户文件夹.m2文件夹下修改，前者是全局设置，后者是个人设置，server的id必须与pom中的id相同
3.mvn deploy
注意:禁止账号密码写在pom文件中，只允许写在settings.xml中
```

* 可运行jar包

```
1.设置<packaging>jar</packaging>(默认即是此项)
2.添加springboot编译插件,build-info会把jar的版本信息打包进jar内,springcloud监控模块可以读取,repackage会把启动所需的自动配置代码与容器等jar包一起打包为一个可执行的jar文件
<project>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>${spring-boot-maven-plugin.version}</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>build-info</goal>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
3.mvn package
```

* 编译、启动命令

```bash
    # START:
    -生产
    java -jar -Xms1024m -Xmx4096m {xxx.jar} --spring.cloud.config.label=master --spring.profiles.active=prod &
    -测试
    java -jar -Xms400m -Xmx1024m {xxx.jar} --spring.cloud.config.label=test --spring.profiles.active=test &
    -开发
    java -jar -Xms400m -Xmx1024m {xxx.jar} --spring.cloud.config.label=dev --spring.profiles.active=dev &
    或默认启动
    # STOP:
    ps -ef | grep apply
    kill -2 pid
    # 后台启动不输出console流:
    nohup java -jar -Xms400m -Xmx1024m apply-1.0-SNAPSHOT.jar --spring.cloud.config.label=dev --spring.profiles.active=dev > /dev/null 2>&1 &
    # 多模块只编译单个模块(所依赖的本地模块也会编译):
    mvn clean install -Dmaven.test.skip=true -pl {module name} -am -amd
    eg : mvn clean install -Dmaven.test.skip=true -pl apply -am -amd
```

* 普通web项目打war包

```
1.设置<packaging>war</packaging>
2.把tomcat的依赖给排除掉
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>
3.添加servlet依赖(provided)
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api</artifactId>
    <scope>provided</scope>
</dependency>
4.添加容器依赖(provided)(可选,或者自己配置ide中的服务器)
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-tomcat</artifactId>
    <scope>provided</scope>
</dependency>
5.实现SpringBootServletInitializer接口
@Configuration
public class ServletInitialConfig extends SpringBootServletInitializer {
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        return builder.sources(App.class);
    }
}
6.修改maven-war-plugin版本(最低为3.0.0,否则需要配置忽略web.xml检测)
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-war-plugin</artifactId>
    <version>3.2.2</version>
</plugin>
7.添加spring-boot-maven-plugin插件 goal包括repackage
<project>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>${spring-boot-maven-plugin.version}</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>build-info</goal>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
8.war包名称或者jar包名称可以通过
<project>
    <build>
        <finalName>warOrJarName</finalName>
    </build>
</project>
来进行修改
9.所有provided的包会默认放在war包中的WEB-INF/lib-provided文件夹中,会浪费一些硬盘资源，目前不太清楚为什么这样设计
附：启动原理
servlet3.0标准：
1.服务器启动（web应用启动）会创建当前web应用里面每一个jar包里面ServletContainerInitializer实例
2.jar包的META-INF/services文件夹下，有一个名为javax.servlet.ServletContainerInitializer的文件，内容就是ServletContainerInitializer的实现类的全类名
3.还可以使用@HandlesTypes，在应用启动的时候加载我们感兴趣的类
4.容器启动过程中首先调用ServletContainerInitializer 实例的onStartup方法
war包启动原理：
1.启动所有 META-INF/services 下声明的 ServletContainerInitializer 的实现类
2.其中SpringServletContainerInitializer 上有注解 @HandlesTypes({WebApplicationInitializer.class}) 表明加载所有WebApplicationInitializer的实现类
3.启动SpringBootServletInitializer的实现类，加载启动配置
jar包启动原理:
SpringApplication#run()
AnnotationConfigServletWebServerApplicationContext#refresh()
ServletWebServerApplicationContext#refresh() -> #createWebServer() -> #getServletContextInitializerBeans() -> 启动所有onStartUp()
 -> #finishRefresh() -> #publishEvent(new ServletWebServerInitializedEvent(webServer, this))

ServletWebServerInitializedEvent jar方式初始化会发送此事件,war方式不会
```

* tomcat等容器集成

```
目前官方支持的容器有tomcat、undertow、jetty，其中tomcat与undertow性能接近,gc上undertow更为平稳一些，jetty性能大幅弱于前二者，由于对tomcat比较熟悉，所以还是选用tomcat，有兴趣的人可以试试undertow，但是jetty不推荐
以undertow为例
1.因为默认是以tomcat为容器，需要把tomcat的依赖给排除掉
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>
2.添加undertow依赖
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-undertow</artifactId>
</dependency>
注意:jetty是一样的 artifactId 为 spring-boot-starter-jetty
3.添加springboot打包插件,goal要包含repackage
需要注意的，这几个容器在yml配置文件中的属性名称并不相同
```
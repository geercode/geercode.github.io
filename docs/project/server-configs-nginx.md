<p align="right"><b><em>last updated at {docsify-updated}</em></b></p>

```
nginx的典型规范配置，是h5bp的一个企业级维护分支，原repo地址:https://github.com/h5bp/server-configs-nginx
```

[server-configs-nginx github地址](https://github.com/geercode/server-configs-nginx)

## 一、目录

```
.
├── certs
│   ├── default.crt
│   ├── default.key
├── conf.d
│   ├── default.conf
│   ├── no-ssl.default.conf
│   └── templates
│       ├── example.com.conf
│       ├── no-ssl.example.com.conf
│       ├── other.example.com.conf
│       ├── slb.example.com.conf
│       └── www.example.com.conf
├── h5bp
│   ├── basic.conf
│   ├── cross-origin
│   │   ├── requests.conf
│   │   └── resource_timing.conf
│   ├── errors
│   │   └── custom_errors.conf
│   ├── internet_explorer
│   │   └── x-ua-compatible.conf
│   ├── location
│   │   ├── security_file_access.conf
│   │   ├── web_performance_filename-based_cache_busting.conf
│   │   └── web_performance_svgz-compression.conf
│   ├── media_types
│   │   ├── character_encodings.conf
│   │   └── media_types.conf
│   ├── security
│   │   ├── content-security-policy.conf
│   │   ├── referrer-policy.conf
│   │   ├── server_software_information.conf
│   │   ├── strict-transport-security.conf
│   │   ├── x-content-type-options.conf
│   │   ├── x-frame-options.conf
│   │   └── x-xss-protection.conf
│   ├── ssl
│   │   ├── certificate_files.conf
│   │   ├── ocsp_stapling.conf
│   │   ├── policy_deprecated.conf
│   │   ├── policy_intermediate.conf
│   │   ├── policy_modern.conf
│   │   └── ssl_engine.conf
│   └── web_performance
│       ├── cache_expiration.conf
│       ├── cache-file-descriptors.conf
│       ├── compression.conf
│       ├── no-transform.conf
│       ├── pre-compressed_content_brotli.conf
│       └── pre-compressed_content_gzip.conf
├── mime.types
└── nginx.conf
```

## 二、特性

```
1.多站点
.
├── certs
│   ├── default.crt
│   ├── default.key
│   ├── geercode.com.crt
│   ├── geercode.com.key
│   ├── baidu.com.crt
│   ├── baidu.com.key
│   ├── bilibili.com.crt
│   ├── bilibili.com.key
└── conf.d
    ├── default.conf
    ├── no-ssl.default.conf
    ├── geercode.com.conf
    ├── test.geercode.com.conf
    └── slb-test.geercode.com.conf
2.多url匹配
3.http自动跳转https
所有对nginx的http请求统一转到https，对应域名不存在则返回444，无法连接
监听一级域名转到二级域名www
4.slb限制内网访问
5.nginx服务器配置文件范式，方便做自动化
certs：域名命名证书
conf.d: 域名命名server配置
域名规范
外网域名:test.geercode.com
内网域名:slb-test.geercode.com
目录规范：
/var/www/www.geercode.com
/var/www/test.geercode.com
```

## 三、快速开始

### 1.编译安装

```
本文基于deepin安装，属debian系

wget http://nginx.org/download/nginx-1.16.1.tar.gz
tar xzvf nginx-1.16.1.tar.gz
cd nginx-1.16.1
apt install gcc libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev
./configure --with-http_ssl_module --with-http_v2_module
make && make install
make clean
ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/nginx
```

### 2.初始配置

```
cd /usr/local/nginx
mkdir bak
cd /usr/local/nginx/conf
mv ./* ../bak
git clone https://github.com/geercode/server-configs-nginx.git
```

### 3.添加一级域名

```bash
$ cd /etc/nginx/conf.d
```

* 创建
```bash
$ cp templates/www.example.com.conf actual-hostname.conf
$ sed -i 's/example.com/actual-hostname/g' actual-hostname.conf
eg:
$ cp templates/www.example.com.conf geercode.com.conf
$ sed -i 's/example.com/geercode.com/g' geercode.com.conf
$ nginx -s reload
记得创建目录 /var/www/www.geercode.com/public/index.html
```

* 失效
```bash
$ mv actual-hostname.conf .actual-hostname.conf
```

* 有效
```bash
$ mv .actual-hostname.conf actual-hostname.conf
```

* 测试配置
```bash
$ nginx -t
```

* 重新载入配置
```bash
$ nginx -s reload
```

> 注意:需要自行修改证书

### 4.添加二级域名

```bash
$ cp templates/other.example.com.conf other.actual-hostname.conf
$ sed -i 's/other.example.com/other.actual-hostname/g' other.actual-hostname.conf
$ nginx -s reload
eg:
$ cp templates/other.example.com.conf test.geercode.com.conf
$ sed -i 's/other.example.com/test.geercode.com/g' test.geercode.com.conf
$ nginx -s reload
记得创建目录 /var/www/test.geercode.com/public/index.html
```

### 5.添加内网域名

```bash
$ cp templates/slb.example.com.conf slb.actual-hostname.conf
$ sed -i 's/slb.example.com/slb.actual-hostname/g' slb.actual-hostname.conf
$ nginx -s reload
eg:
$ cp templates/slb.example.com.conf slb-test.geercode.com.conf
$ sed -i 's/slb.example.com/slb-test.geercode.com/g' slb-test.geercode.com.conf 
```

### 6.配置url地址匹配

```
语法规则：location [=|~|~*|^~]/uri/{...}
```

* = 开头表示精确匹配
* ^~ 开头表示uri以某个常规字符串开头，不是正则匹配，理解为匹配url路径即可。nginx不对url做编码，因此请求为/static/20%/aa,可以被规则 ^~ /static/ /aap匹配到（注意是空格）。        <span style="color:blue">以xx开头</span>
* ~ 开头表示区分大小写的正则匹配。        <span style="color:blue">以xx结尾</span>
* ~* 开头表示不区分大小写的正则匹配。     <span style="color:blue">以xx结尾</span>
* !~ 和 !~* 分别为区分大小写不匹配及不区分大小写不匹配的正则
* / 通用匹配，任何请求都会匹配到

```
location命中规则:
1.先进行精准匹配，如果命中立即返回结果并结束解析的过程。
2.精准匹配未命中判断普通匹配，如果命中多个会记录下"最长的"命中结果，单不会结束解析。
3.继续判断正则匹配，按照正则匹配设置的规则正则表达式进行匹配，如果又多个正则匹配则由上到下进行匹配，一旦匹配成功一个会立即返回结果并结束解析

ps:普通匹配的前后顺序是无所谓的，因为记录的是最长的结果，而正则匹配是按从上到下匹配的，这个需要注意!!!
```

![](asset/location_diagram.png)

```
upstream backend {
	server 192.168.1.114:8080;
	server 192.168.1.114:8081;
}

server {
    ssl_certificate     /path/to/public.crt;
    ssl_certificate_key /path/to/private.key;
    
    location /fe {
        try_files $uri $uri/ /fe/index.html;
    }
    
    location /be {
      proxy_pass         http://backend;
      proxy_set_header   X-Forwarded-Proto $scheme;
      proxy_set_header   X-Real-IP         $remote_addr;
      # 外网域名
      proxy_set_header   Host              $proxy_host;
      proxy_set_header   X-Forwarded-For   $remote_addr;
      # 内网域名
      # proxy_set_header   Host              $http_host;
      # proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
    }
}
```

### 7.示例

> 在仓库 [sample](https://github.com/geercode/server-configs-nginx/tree/sample) 分支可以查看

## 四、自动化

```
lvs keepalived nginx ansible
```

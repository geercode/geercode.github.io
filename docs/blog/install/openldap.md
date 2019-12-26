### 1.初始化准备

系统centos7 64位，配置yum源
    
    wget http://mirrors.aliyun.com/repo/Centos-7.repo
    cp Centos-7.repo /etc/yum.repos.d/
    cd /etc/yum.repos.d/
    mv CentOS-Base.repo CentOS-Base.repo.bak
    mv Centos-7.repo CentOS-Base.repo
    yum clean all
    yum makecache

关闭selinux和防火墙

    sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config && setenforce 0 && systemctl disable firewalld.service && systemctl stop firewalld.service
 
环境初始化完毕后，我们就可以安装OpenLDAP。

### 2.安装OpenLDAP

使用如下命令安装OpenLDAP

    yum -y install openldap compat-openldap openldap-clients openldap-servers openldap-servers-sql openldap-devel
     
查看OpenLDAP版本，使用如下命令
    
    slapd -VV
     
OpenLDAP安装完毕后，接下来我们开始配置OpenLDAP。

### 3.配置OpenLDAP

    OpenLDAP配置比较复杂牵涉到的内容比较多，接下来我们一步一步对其相关的配置进行介绍。
    注意:从OpenLDAP2.4.23版本开始所有配置数据都保存在/etc/openldap/slapd.d/中，建议不再使用slapd.conf作为配置文件。

#### 3.1.配置OpenLDAP管理员密码

    设置OpenLDAP的管理员密码:
    slappasswd -s 123456
     
    上述加密后的字段保存下，等会我们在配置文件中会使用到。
    
#### 3.2.修改olcDatabase={2}hdb.ldif文件

    vim /etc/openldap/slapd.d/cn=config/olcDatabase\=\{2\}hdb.ldif

    # AUTO-GENERATED FILE - DO NOT EDIT!! Use ldapmodify.
    # CRC32 4aced2be
    dn: olcDatabase={2}hdb
    objectClass: olcDatabaseConfig
    objectClass: olcHdbConfig
    olcDatabase: {2}hdb
    olcDbDirectory: /var/lib/ldap
    olcRootPW: 123456
    olcSuffix: dc=my-domain,dc=com
    olcRootDN: cn=Manager,dc=my-domain,dc=com
    olcDbIndex: objectClass eq,pres
    olcDbIndex: ou,cn,mail,surname,givenname eq,pres,sub
    structuralObjectClass: olcHdbConfig
    entryUUID: 2f2bb8d8-e90c-1037-92e4-b1ea8c895bad
    creatorsName: cn=config
    createTimestamp: 20180511021013Z
    entryCSN: 20180511021013.435988Z#000000#000#000000
    modifiersName: cn=config
    modifyTimestamp: 20180511021013Z


    注意：其中cn=Manager中的Manager表示OpenLDAP管理员的用户名，而olcRootPW表示OpenLDAP管理员的密码。

#### 3.3.修改olcDatabase={1}monitor.ldif文件
    
    修改olcDatabase={1}monitor.ldif文件，如下：
    vim /etc/openldap/slapd.d/cn=config/olcDatabase\=\{1\}monitor.ldif

    # AUTO-GENERATED FILE - DO NOT EDIT!! Use ldapmodify.
    # CRC32 ab5656a7
    dn: olcDatabase={1}monitor
    objectClass: olcDatabaseConfig
    olcDatabase: {1}monitor
    olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=extern
     al,cn=auth" read by dn.base="cn=Manager,dc=my-domain,dc=com" read by * none
    structuralObjectClass: olcDatabaseConfig
    entryUUID: 2f2ba56e-e90c-1037-92e3-b1ea8c895bad
    creatorsName: cn=config
    createTimestamp: 20180511021013Z
    entryCSN: 20180511021013.435493Z#000000#000#000000
    modifiersName: cn=config
    modifyTimestamp: 20180511021013Z
    
     
    注意：该修改中的dn.base是修改OpenLDAP的管理员的相关信息的。
    
    验证OpenLDAP的基本配置，使用如下命令：
    slaptest -u

启动OpenLDAP服务
    
    注：chmod -R ldap:ldap /etc/openldap/slapd.d
    systemctl enable slapd
    systemctl start slapd
    systemctl status slapd
     
    OpenLDAP默认监听的端口是389，下面我们来看下是不是389端口，如下：
    netstat -antup | grep 389
 
#### 3.4.配置OpenLDAP数据库
    
    OpenLDAP默认使用的数据库是BerkeleyDB，现在来开始配置OpenLDAP数据库
    cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
    
    chown ldap:ldap -R /var/lib/ldap
    chmod 700 -R /var/lib/ldap
    ll /var/lib/ldap/
    注意：/var/lib/ldap/就是BerkeleyDB数据库默认存储的路径。

#### 3.5.导入基本Schema
    
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
    
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
    
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

#### 3.6.修改migrate_common.ph文件

    migrate_common.ph文件主要是用于生成ldif文件使用，修改migrate_common.ph文件
    注：有#标明修改处是做修改的，其他都是默认

	vi /usr/share/migrationtools/migrate_common.ph
    
    $NETINFOBRIDGE = (-x "/usr/sbin/mkslapdconf");
    if ($NETINFOBRIDGE) {
    	$NAMINGCONTEXT{'aliases'}   = "cn=aliases";
    	$NAMINGCONTEXT{'fstab'} = "cn=mounts";
    	$NAMINGCONTEXT{'passwd'}= "cn=users";
    	$NAMINGCONTEXT{'netgroup_byuser'}   = "cn=netgroup.byuser";
    	$NAMINGCONTEXT{'netgroup_byhost'}   = "cn=netgroup.byhost";
    	$NAMINGCONTEXT{'group'} = "cn=groups";
    	$NAMINGCONTEXT{'netgroup'}  = "cn=netgroup";
    	$NAMINGCONTEXT{'hosts'} = "cn=machines";
    	$NAMINGCONTEXT{'networks'}  = "cn=networks";
    	$NAMINGCONTEXT{'protocols'} = "cn=protocols";
    	$NAMINGCONTEXT{'rpc'}   = "cn=rpcs";
    	$NAMINGCONTEXT{'services'}  = "cn=services";
    } else {
    	$NAMINGCONTEXT{'aliases'}   = "ou=Aliases";
    	$NAMINGCONTEXT{'fstab'} = "ou=Mounts";
    	$NAMINGCONTEXT{'passwd'}= "ou=People";
    	$NAMINGCONTEXT{'netgroup_byuser'}   = "nisMapName=netgroup.byuser";
    	$NAMINGCONTEXT{'netgroup_byhost'}   = "nisMapName=netgroup.byhost";
    	$NAMINGCONTEXT{'group'} = "ou=Group";
    	$NAMINGCONTEXT{'netgroup'}  = "ou=Netgroup";
    	$NAMINGCONTEXT{'hosts'} = "ou=Hosts";
    	$NAMINGCONTEXT{'networks'}  = "ou=Networks";
    	$NAMINGCONTEXT{'protocols'} = "ou=Protocols";
    	$NAMINGCONTEXT{'rpc'}   = "ou=Rpc";
    	$NAMINGCONTEXT{'services'}  = "ou=Services";
    }
    $DEFAULT_MAIL_DOMAIN = "my-domain";    #需要修改处
    $DEFAULT_BASE = "dc=my-domain,dc=com";   #需要修改处
    $EXTENDED_SCHEMA = 1;   #需要修改处
    if (defined($ENV{'LDAP_BASEDN'})) {
    	$DEFAULT_BASE = $ENV{'LDAP_BASEDN'};
    }
    if (defined($ENV{'LDAP_DEFAULT_MAIL_DOMAIN'})) {
    	$DEFAULT_MAIL_DOMAIN = $ENV{'LDAP_DEFAULT_MAIL_DOMAIN'};
    }
    if (defined($ENV{'LDAP_DEFAULT_MAIL_HOST'})) {
    	$DEFAULT_MAIL_HOST = $ENV{'LDAP_DEFAULT_MAIL_HOST'};
    }
    if (defined($ENV{'LDAP_BINDDN'})) {
    	$DEFAULT_OWNER = $ENV{'LDAP_BINDDN'};
    }
    if (defined($ENV{'LDAP_EXTENDED_SCHEMA'})) {
    	$EXTENDED_SCHEMA = $ENV{'LDAP_EXTENDED_SCHEMA'};
    }
    if (!defined($DEFAULT_BASE)) {
    	$DEFAULT_BASE = &domain_expand($DEFAULT_MAIL_DOMAIN);
    	$DEFAULT_BASE =~ s/,$//o;
    }
    if (-x "/usr/sbin/revnetgroup") {
    	$REVNETGROUP = "/usr/sbin/revnetgroup";
    } elsif (-x "/usr/lib/yp/revnetgroup") {
    	$REVNETGROUP = "/usr/lib/yp/revnetgroup";
    }
    $classmap{'o'} = 'organization';
    $classmap{'dc'} = 'domain';
    $classmap{'l'} = 'locality';
    $classmap{'ou'} = 'organizationalUnit';
    $classmap{'c'} = 'country';
    $classmap{'nismapname'} = 'nisMap';
    $classmap{'cn'} = 'container';
    sub parse_args
    {
    	if ($#ARGV < 0) {
    		print STDERR "Usage: $PROGRAM infile [outfile]\n";
    		exit 1;
    	}
    	
    	$INFILE = $ARGV[0];
    	
    	if ($#ARGV > 0) {
    		$OUTFILE = $ARGV[1];
    	}
    }
    sub open_files
    {
    	open(INFILE);
    	if ($OUTFILE) {
    		open(OUTFILE,">$OUTFILE");
    		$use_stdout = 0;
    	} else {
    		$use_stdout = 1;
    	}
    }
    sub domain_expand
    {
    	local($first) = 1;
    	local($dn);
    	local(@namecomponents) = split(/\./, $_[0]);
    	foreach $_ (@namecomponents) {
    		$first = 0;
    		$dn .= "dc=$_,";
    	}
    	$dn .= $DEFAULT_BASE;
    	return $dn;
    }
    sub uniq
    {
    	local($name) = shift(@_);
    	local(@vec) = sort {uc($a) cmp uc($b)} @_;
    	local(@ret);
    	local($next, $last);
    	foreach $next (@vec) {
    		if ((uc($next) ne uc($last)) &&
    			(uc($next) ne uc($name))) {
    			push (@ret, $next);
    		}
    		$last = $next;
    	}
    	return @ret;
    }
    sub getsuffix
    {
    	local($program) = shift(@_);
    	local($nc);
    	$program =~ s/^migrate_(.*)\.pl$/$1/;
    	$nc = $NAMINGCONTEXT{$program};
    	if ($nc eq "") {
    		return $DEFAULT_BASE;
    	} else {
    		return $nc . ',' . $DEFAULT_BASE;
    	}
    }
    sub ldif_entry
    {
    	local ($HANDLE, $lhs, $rhs) = @_;
    	local ($type, $val) = split(/\=/, $lhs);
    	local ($dn);
    	if ($rhs ne "") {
    		$dn = $lhs . ',' . $rhs;
    	} else {
    		$dn = $lhs;
    	}
    	$type =~ s/\s*$//o;
    	$type =~ s/^\s*//o;
    	$type =~ tr/A-Z/a-z/;
    	$val =~ s/\s*$//o;
    	$val =~ s/^\s*//o;
    	print $HANDLE "dn: $dn\n";
    	print $HANDLE "$type: $val\n";
    	print $HANDLE "objectClass: top\n";
    	print $HANDLE "objectClass: $classmap{$type}\n";
    	if ($EXTENDED_SCHEMA) {
    		if ($DEFAULT_MAIL_DOMAIN) {
    			print $HANDLE "objectClass: domainRelatedObject\n";
    			print $HANDLE "associatedDomain: $DEFAULT_MAIL_DOMAIN\n";
    		}
    	}
    	print $HANDLE "\n";
    }
    sub escape_metacharacters
    {
    	local($name) = @_;
    	# From Table 3.1 "Characters Requiring Quoting When Contained
    	# in Distinguished Names", p87 "Understanding and Deploying LDAP
    	# Directory Services", Howes, Smith, & Good.
    	# 1) Quote backslash
    	# Note: none of these are very elegant or robust and may cause
    	# more trouble than they're worth. That's why they're disabled.
    	# 1.a) naive (escape all backslashes)
    	# $name =~ s#\\#\\\\#og;
    	#
    	# 1.b) mostly naive (escape all backslashes not followed by
    	# a backslash)
    	# $name =~ s#\\(?!\\)#\\\\#og;
    	#
    	# 1.c) less naive and utterly gruesome (replace solitary
    	# backslashes)
    	# $name =~ s{		# Replace
    	#		(?<!\\) # negative lookbehind (no preceding backslash)
    	#		\\	# a single backslash
    	#		(?!\\)	# negative lookahead (no following backslash)
    	#	}
    	#	{		# With
    	#		\\\\	# a pair of backslashes
    	#	}gx;
    	# Ugh. Note that s#(?:[^\\])\\(?:[^\\])#////#g fails if $name
    	# starts or ends with a backslash. This expression won't work
    	# under perl4 because the /x flag and negative lookahead and
    	# lookbehind operations aren't supported. Sorry. Also note that
    	# s#(?:[^\\]*)\\(?:[^\\]*)#////#g won't work either.  Of course,
    	# this is all broken if $name is already escaped before we get
    	# to it. Best to throw a warning and make the user import these
    	# records by hand.
    	# 2) Quote leading and trailing spaces
    	local($leader, $body, $trailer) = ();
    	if (($leader, $body, $trailer) = ($name =~ m#^( *)(.*\S)( *)$#o)) {
    		$leader =~ s# #\\ #og;
    		$trailer =~ s# #\\ #og;
    		$name = $leader . $body . $trailer;
    	}
    	# 3) Quote leading octothorpe (#)
    	$name =~ s/^#/\\#/o;
    	# 4) Quote comma, plus, double-quote, less-than, greater-than,
    	# and semicolon
    	$name =~ s#([,+"<>;])#\\$1#g;
    	return $name;
    }
    1;
     
	安装配置migrationtools
	yum install migrationtools -y


	进入migrationtool配置目录
	# cd /usr/share/migrationtools/
	首先编辑migrate_common.ph（70-74行，自己看，不列出）

	下面利用pl脚本将/etc/passwd 和/etc/shadow生成LDAP能读懂的文件格式，保存在/tmp/下
	./migrate_base.pl > /tmp/base.ldif
	./migrate_passwd.pl  /etc/passwd > /tmp/passwd.ldif
	./migrate_group.pl  /etc/group > /tmp/group.ldif
	
	下面就要把这三个文件导入到LDAP，这样LDAP的数据库里就有了我们想要的用户
	ldapadd -x -w "123456" -D "cn=Manager,dc=my-domain,dc=com" -f /tmp/base.ldif
	ldapadd -x -w "123456" -D "cn=Manager,dc=my-domain,dc=com" -f /tmp/passwd.ldif
	ldapadd -x -w "123456" -D "cn=Manager,dc=my-domain,dc=com" -f /tmp/group.ldif
	过程若无报错，则LDAP服务端配置完毕
	这里的-x表示简单鉴权，-W为提醒输入口令。
	重启slapd完成配置
	# systemctl restart slapd

到此OpenLDAP的配置就已经全部完毕，下面我们来开始添加用户到OpenLDAP中。

### 4.安装phpldapadmin
	yum -y install epel-release
	yum -y install phpldapadmin

	修改/etc/httpd/conf.d/phpldapadmin.conf
	cat > /etc/httpd/conf.d/phpldapadmin.conf << “EOF”

	Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
	Alias /ldapadmin /usr/share/phpldapadmin/htdocs

	<Directory /usr/share/phpldapadmin/htdocs>
	<IfModule mod_authz_core.c>
	# Apache 2.4
	Require all granted
	</IfModule>
	<IfModule !mod_authz_core.c>
	# Apache 2.2
	Order Deny,Allow
	Deny from all
	Allow from 127.0.0.1
	Allow from ::1
	</IfModule>
	</Directory>
	EOF

	修改/etc/phpldapadmin/config.php 
	298行的IP（修改为本机IP）
	$servers->setValue('server','host','192.168.21.59');
	301行去掉注释
	$servers->setValue('server','port',389);
	397去掉注释，398加上注释
	$servers->setValue('login','attr','dn');
	// $servers->setValue('login','attr','uid');

	重启httpd服务
	systemctl restart httpd
	
	访问phpldapadmin
	http://ip/phpldapadmin

### 5.添加用户及用户组
    
    默认情况下OpenLDAP是没有普通用户的，但是有一个管理员用户。管理用户就是前面我们刚刚配置的root。
    这里示例添加普通用户组和用户：ldapgroup1和ldapuser1，如下：
    
    cat /etc/openldap/users_manage/ldapgroup1.ldif
    dn: cn=ldapgroup1,dc=my-domain,dc=com
    objectClass: posixGroup
    objectClass: top
    cn: ldapgroup1
    userPassword: 123456
    gidNumber: 1001

    cat /etc/openldap/users_manage/ldapuser1.ldif
    dn: uid=ldapuser1,ou=ldapgroup1,dc=my-domain,dc=com
    uid: ldapuser1
    cn: ldapuser1
    sn: ldapuser1
    mail: ldapuser1@my-domain.com
    objectClass: person
    objectClass: organizationalPerson
    objectClass: inetOrgPerson
    objectClass: posixAccount
    userPassword: 123456

     
    注意：后续如果要新加用户到OpenLDAP中的话，我们可以直接修改ldapuser1.ldif文件即可。

    导入用户到数据库，使用如下命令：
    ldapadd -x -w "123456" -D "cn=Manager,dc=my-domain,dc=com" -f /etc/openldap/users_manage/ldapgroup1.ldif
    导入用户组到数据库，使用如下命令
    ldapadd -x -w "123456" -D "cn=Manager,dc=my-domain,dc=com" -f /etc/openldap/users_manage/ldapuser1.ldif
    
### 6.ldap安全方案与备份恢复

```
生成密码
openssl rand -base64 8
参照
https://github.com/osixia/docker-openldap
https://github.com/osixia/docker-openldap-backup

slapd-restore-config 20190502T082301-config
slapd-restore-data 20190502T080901-data
```
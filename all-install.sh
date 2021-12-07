#!/bin/bash
 
 
## 作者：陈步云
## 微信：15648907522
##
##
## 将基本环境yum安装的包放入如下目录
##  /Basic-package/basic-rpm
##
##
## 将基础环境服务包放入如下目录
##  /Basic-package
##
##
##
 
 
function 0-basic-install () {
    
    ## 基础环境安装
 
 
    cd /Basic-package/basic-rpm || exit 
    yum -y install *.rpm
    systemctl disable firewalld
    systemctl stop firewalld
 
 
}
 
 
 
 
 
 
function 1-java-install () {
 
 
## 作者：陈步云
## 微信：15648907522
 
 
 
 
if [ "$(java -version)" ]; then
 
 
    echo "command \"java\" exists on system"
 
 
else
    if [ -d "/cby/backend/base-service/" ]; then
 
 
        echo "directory \"/cby/backend/base-service/\" exists"
 
 
    else
 
 
        ## 安装Java程序
 
 
        cd /Basic-package || exit
        mkdir -p /cby/backend/base-service/
        cp jdk-8u102-linux-x64.tar.gz /cby/backend/base-service/
        cd /cby/backend/base-service/ || exit
        tar -xf jdk-8u102-linux-x64.tar.gz
        mv /cby/backend/base-service/jdk1.8.0_102/ /cby/backend/base-service/jdk8/
 
 
    fi 
    
 
 
 
 
    if [ "$(grep "JAVA_HOME=/usr/local/jdk1.8.0_151" /etc/profile)" ]; then
 
 
        echo 'JAVA_HOME in profile'  
 
 
    else
 
 
        ## 添加Java环境变量
 
 
        echo 'export JAVA_HOME=/cby/backend/base-service/jdk8' >> /etc/profile
        echo -e 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
        echo -e 'export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile 
        source /etc/profile
 
 
    fi
    
fi
 
 
echo "java version:"
java -version 
 
 
}
 
 
 
 
function 2-mysql-install () {
 
 
## 作者：陈步云
## 微信：15648907522
 
 
 
 
 
 
 
 
 
 
if [ "$(mysql -V)" ]; then
 
 
    echo "command \"mysql\" exists on system"
 
 
else
 
 
    cd /Basic-package || exit
 
 
    if [ -x "mysql-5.7.34-1.el7.x86_64.rpm-bundle.tar" ]; then
 
 
        echo "file \"mysql-5.7.34-1.el7.x86_64.rpm-bundle.tar\" is executable"
 
 
    else
 
 
        ## 解压安装包的文件
 
 
        tar xvf mysql-5.7.34-1.el7.x86_64.rpm-bundle.tar 
 
 
        yum install ./*.rpm -y
        
    fi
 
 
    ## 启动服务，并开机自启
 
 
    if [ "$(mysql -V)" ]; then
 
 
        systemctl start mysqld
 
 
        systemctl enable mysqld
    fi
    
    ## 查看MySQL默认密码
 
 
    echo 'mysql password:'    
    sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $11}'
 
 
    ## 默认密码获取
 
 
    mysqlpssswd=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $11}')
 
 
    ## 一系列授权操作
 
 
    mysql -u root -p$mysqlpssswd -e "set global validate_password_length=0;" --connect-expired-password
    mysql -u root -p$mysqlpssswd -e "set global validate_password_policy=0;" --connect-expired-password
    mysql -u root -p$mysqlpssswd -e "set password for 'root'@'localhost' = password('123456');" --connect-expired-password
    mysql -u root -p$mysqlpssswd -e "use mysql;" --connect-expired-password
    mysql -u root -p$mysqlpssswd -e "grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option;" --connect-expired-password 
    mysql -u root -p123456 -e "flush privileges;" --connect-expired-password
 
 
fi
 
 
 
 
 
 
}
 
 
function 3-redis-install () {
 
 
 
 
## 作者：陈步云
## 微信：15648907522
 
 
yum install -y gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel
 
 
 
 
if [ "$(redis-server --version)" ]; then
 
 
    echo "command \"redis\" exists on system"
 
 
else
 
 
    if [ -d "/cby/backend/base-service/" ]; then
 
 
        echo "directory \"/cby/backend/base-service/\" exists"
 
 
    else
 
 
        mkdir -p /cby/backend/base-service/
 
 
    fi 
    
    if [ -d "/cby/backend/base-service/" ]; then
        
 
 
        ## 解压安装服务 
 
 
        cd /Basic-package || exit
        cp redis-5.0.12.tar.gz /cby/backend/base-service/
        cd /cby/backend/base-service/ || exit
        tar xf redis-5.0.12.tar.gz 
        mv /cby/backend/base-service/redis-5.0.12/ /cby/backend/base-service/redis/
 
 
    else
 
 
        mkdir -p /cby/backend/base-service/
 
 
    fi 
 
 
    if [ -d "/cby/backend/base-service/redis/" ]; then
 
 
        cd /cby/backend/base-service/redis/ || exit
 
 
## 写入配置文件
 
 
cat >redis.conf<<EOF
    bind 0.0.0.0
    protected-mode no
    daemonize yes
EOF
 
 
        ## 编译此服务
 
 
        make -j "$(cat /proc/cpuinfo |grep "processor"|wc -l)"
 
 
    fi 
  
    
    if [ -d "/cby/backend/base-service/redis/src/" ]; then
 
 
        cd /cby/backend/base-service/redis/src/ || exit
        make install
 
 
    fi 
    
## 进入安装目录后启动服务
 
 
cd /cby/backend/base-service/redis/ || exit
redis-server redis.conf
    
fi
 
 
 
 
}
 
 
 
 
function 4-minio-install () {
 
 
#!/bin/bash
 
 
## 作者：陈步云
## 微信：15648907522
 
 
if [ "$(/cby/backend/base-service/minio/minio -v)" ]; then
 
 
    echo "command \"minio\" exists on system"
 
 
else
    if [ -d "/cby/backend/base-service/minio/" ]; then
 
 
        echo "directory \"/cby/backend/base-service/minio/\" exists"
 
 
    else
 
 
        ## 添加执行权限并将服务拷贝到目的地
 
 
        cd /Basic-package || exit
        mkdir -p /cby/backend/base-service/minio/
        cp minio /cby/backend/base-service/minio/
        cd /cby/backend/base-service/minio/ || exit
        chmod +x minio
 
 
    fi 
    
    if [ "$(grep "MINIO_ACCESS_KEY" /etc/profile)" ]; then
 
 
        echo 'MINIO_ACCESS_KEY in profile'  
 
 
    else
 
 
        ## 将账号密码写入环境变量
 
 
        echo -e 'export MINIO_ACCESS_KEY=minio' >> /etc/profile
        echo -e 'export MINIO_SECRET_KEY=thinker@123' >> /etc/profile 
        source /etc/profile
 
 
    fi
 
 
    if [ -d "/cby/backend/base-service/minio/data" ]; then
 
 
        echo "directory \"/cby/backend/base-service/minio/data\" exists"
 
 
    else
 
 
        mkdir -p /cby/backend/base-service/minio/data
 
 
    fi
    
 
 
    if [ -x "/cby/backend/base-service/minio/minio" ]; then
 
 
        echo "file \"/cby/backend/base-service/minio/minio\" is executable"
 
 
        source /etc/profile
        nohup /cby/backend/base-service/minio/minio server --address 0.0.0.0:9000 /cby/backend/base-service/minio/data > minio.log 2>&1 &
 
 
    fi
    
    
    
fi
 
 
 
 
 
 
}
 
 
 
 
function 5-nginx-install () {
 
 
 
 
## 作者：陈步云
## 微信：15648907522
 
 
if [ "$(/cby/backend/base-service/nginx/sbin/nginx -v)" ]; then
 
 
    echo "command \"nginx\" exists on system"
 
 
else
    if [ -d "/cby/backend/base-service/" ]; then
 
 
        echo "directory \"/cby/backend/base-service/\" exists"
 
 
    else
 
 
        mkdir -p /cby/backend/base-service/
 
 
    fi 
 
 
    if [ -d "/cby/backend/base-service/nginx-1.18.0/" ]; then
 
 
        echo "directory \"/cby/backend/base-service/nginx-1.18.0/\" exists"
 
 
    else
 
 
        ## 解压所需包并安装所需依赖
 
 
        cd /Basic-package || exit
        cp nginx-1.18.0.tar.gz /cby/backend/base-service/
        cd /cby/backend/base-service/ || exit
        tar -zxf nginx-1.18.0.tar.gz
        yum install -y gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel
 
 
    fi 
 
 
    if [ -d "/cby/backend/base-service/nginx" ]; then
 
 
        echo "directory \"/cby/backend/base-service/nginx\" exists"
 
 
    else
 
 
        mkdir -p /cby/backend/base-service/nginx
 
 
    fi
    
    if [ -d "/cby/backend/base-service/nginx-1.18.0/" ]; then
        
        ## Nginx编译
 
 
        echo "directory \"/cby/backend/base-service/nginx-1.18.0/\" exists"
        cd /cby/backend/base-service/nginx-1.18.0/ || exit
        ./configure --prefix=/cby/backend/base-service/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module
        make -j "$(cat /proc/cpuinfo |grep "processor"|wc -l)"
        make install
 
 
    else
 
 
        exit 1
 
 
    fi 
 
 
 
 
    if [ "$(/cby/backend/base-service/nginx/sbin/nginx -v)" ]; then
        echo "command \"nginx\" exists on system"
        echo 'nginx version is :'        
        /cby/backend/base-service/nginx/sbin/nginx -v
    fi
    
    
fi
 
 
 
 
 
 
}
 
 
 
 
function 6-rocketmq-install () {
 
 
 
 
## 作者：陈步云
## 微信：15648907522
 
 
if [ "$(ls /cby/backend/base-service/rocketmq/startup.sh)" ]; then
 
 
    echo "command \"rocketmq\" exists on system"
 
 
else
    if [ -d "/cby/backend/base-service/" ]; then
 
 
        echo "directory \"/cby/backend/base-service/\" exists"
 
 
    else
 
 
        mkdir -p /cby/backend/base-service/
 
 
    fi 
 
 
    if [ -d "/cby/backend/base-service/package/rocketmq/" ]; then
 
 
        echo "directory \"/cby/backend/base-service/package/rocketmq/\" exists"
 
 
    else
 
 
        mkdir -p /cby/backend/base-service/package/rocketmq/
 
 
    fi 
 
 
    if [ -d "/cby/backend/base-service/rocketmq/" ]; then
 
 
        echo "directory \"/cby/backend/base-service/rocketmq/\" exists"
 
 
    else
 
 
        cd /Basic-package || exit
        yum -y install unzip
        cp -r rocketmq/ /cby/backend/base-service/package/
        cd /cby/backend/base-service/package/rocketmq/ || exit
        unzip rocketmq-all-4.5.2-bin-release.zip
        mv rocketmq-all-4.5.2-bin-release/ /cby/backend/base-service/rocketmq/
        cp *.sh /cby/backend/base-service/rocketmq/
        cd /cby/backend/base-service/rocketmq/ || exit
        sh /cby/backend/base-service/rocketmq/startup.sh
 
 
    fi
    
    ## 测试消息
 
 
    if [ -x "/cby/backend/base-service/rocketmq/bin/tools.sh" ]; then
        echo "file \"/cby/backend/base-service/rocketmq/bin/tools.sh\" is executable"
 
 
        echo '发送测试消息'         
        bash /cby/backend/base-service/rocketmq/bin/tools.sh  /cby/backend/base-service/rocketmq/org.apache.rocketmq.example.quickstart.Producer
 
 
        echo '接受测试消息'
        bash /cby/backend/base-service/rocketmq/bin/tools.sh  /cby/backend/base-service/rocketmq/org.apache.rocketmq.example.quickstart.Consumer
    fi
    
 
 
fi
 
 
 
 
}
 
 
 
 
function 7-rocketmq-console-install () {
 
 
## 作者：陈步云
## 微信：15648907522
 
 
if [ "$(ls /cby/backend/base-service/rocketmq-console/startup.sh)" ]; then
 
 
    echo "command \"rocketmq-console\" exists on system"
 
 
else
    if [ -d "/cby/backend/base-service/" ]; then
 
 
        echo "directory \"/cby/backend/base-service/\" exists"
 
 
    else
 
 
        mkdir -p /cby/backend/base-service/
 
 
    fi 
 
 
    if [ -d "/cby/backend/base-service/rocketmq-console" ]; then
 
 
        echo "directory \"/cby/backend/base-service/rocketmq-console\" exists"
 
 
    else
 
 
        ## 将所需包拷贝过去并启动
 
 
        cd /Basic-package || exit
        cp -r rocketmq-console/ /cby/backend/base-service/rocketmq-console
        cd /cby/backend/base-service/rocketmq-console/ || exit
        sh startup.sh
    fi
    
    
 
 
fi
 
 
 
 
}
 
 
function 8-Elasticsearch-install () {
 
 
 
 
## 作者：陈步云
## 微信：15648907522
 
 
 
 
if [ "$(ls /openes/elasticsearch)" ]; then
 
 
    echo "command \"elasticsearch\" exists on system"
 
 
else
 
 
 
 
## 修改一些配置
 
 
    cat >>/etc/security/limits.conf<<EOF
    ## 添加以下内容
    * soft nofile 65536
    * hard nofile 131072
    * soft nproc 4096
    * hard nproc 4096
EOF
 
 
    cat >"$(ls /etc/security/limits.d/*.conf)"<<EOF
    # Default limit for number of user's processes to prevent
    # accidental fork bombs.
    # See rhbz #432903 for reasoning.
    *          soft    nproc     4096
    root       soft    nproc     unlimited
EOF
 
 
    cat >>/etc/sysctl.conf<<EOF
    vm.max_map_count=655360
EOF
 
 
 
 
    if [ -d "/openes/" ]; then
 
 
        echo "directory \"/openes/\" exists"
 
 
    else
 
 
        cd /Basic-package || exit
        mkdir -p /openes/
 
 
        ## 创建目录后将安装包拷贝过去
 
 
        cp elasticsearch-7.13.2-linux-x86_64.tar.gz /openes/
 
 
        ## 添加用户并设置密码
 
 
        useradd openes
        echo "es" | passwd --stdin openes
        chown -R openes:openes /openes/
 
 
        sysctl -p
 
 
        su - openes <<!
        cd /openes
        tar xf elasticsearch-7.13.2-linux-x86_64.tar.gz 
        mv elasticsearch-7.13.2/ elasticsearch/
 
 
        if [ -d "/openes/es_repo/data" ]; then
 
 
            echo "directory \"/openes/es_repo/data\" exists"
 
 
        else
 
 
            mkdir -p /openes/es_repo/data
 
 
        fi
 
 
        if [ -d "/openes/es_repo/logs" ]; then
 
 
            echo "directory \"/openes/es_repo/logs\" exists"
 
 
        else
 
 
            mkdir -p /openes/es_repo/logs
 
 
 
 
        fi
 
 
 
 
    cat >>/openes/elasticsearch/config/elasticsearch.yml<<EOF
    ## 修改以下配置
    node.name: node-1
    ## 数据目录位置
    path.data: /openes/es_repo/data
    ## 日志目录位置
    path.logs: /openes/es_repo/logs
    cluster.initial_master_nodes: ["node-1"]
    ## 绑定到0.0.0.0，允许任何ip来访问
    network.host: 0.0.0.0
EOF
 
 
        /openes/elasticsearch/bin/elasticsearch -d
!
 
 
    fi 
 
 
 
 
sleep 20s
curl -I http://127.0.0.1:9200/
    
fi
 
 
 
 
 
 
}
 
 
 
 
 
 
function 9-Kibana-install () {
 
 
 
 
## 作者：陈步云
## 微信：15648907522
 
 
 
 
if [ "$(ls /openes/kibana)" ]; then
 
 
    echo "command \"elasticsearch\" exists on system"
 
 
else
 
 
    cd /Basic-package || exit 
    mkdir -p /openes/
    
    ## 创建目录后将安装包拷贝过去
    ## 并赋予权限
 
 
    cp -r kibana/ /openes/package/
    chown -R openes:openes /openes/
    su - openes <<!
    cd /openes/package/
    tar xf kibana-7.13.2-linux-x86_64.tar.gz 
    mv kibana-7.13.2-linux-x86_64/ /openes/kibana/
    mv *.sh /openes/kibana/
 
 
    cat >>/openes/kibana/config/kibana.yml<<EOF
    ## 修改以下配置
    server.port: 5601
    server.host: "0.0.0.0"
    elasticsearch.hosts: ["http://127.0.0.1:9200"]
    kibana.index: ".kibana"
    i18n.locale: "zh-CN"
EOF
 
 
    cd /openes/kibana/
    sh startup.sh
 
 
!
 
 
sleep 20s
 
 
## 测试验证
 
 
curl -I http://127.0.0.1:5601/
    
fi
 
 
 
 
 
 
}
 
 
 
 
function 10-Logstash-install () {
 
 
 
 
## 作者：陈步云
## 微信：15648907522
 
 
 
 
if [ "$(ls /openes/logstash)" ]; then
 
 
    echo "command \"logstash\" exists on system"
 
 
else
 
 
    cd /Basic-package || exit
    mkdir -p /openes/
 
 
    ## 创建目录后将安装包拷贝过去
    ## 并赋予权限
 
 
    cp logstash-7.13.2-linux-x86_64.tar.gz /openes/
    chown -R openes:openes /openes/
 
 
    ## 切换用户在另一个用户中执行
 
 
    su - openes <<!
    cd /openes/
    tar xf logstash-7.13.2-linux-x86_64.tar.gz 
    mv logstash-7.13.2/ /openes/logstash/
        
        if [ -d "/openes/es_repo/data" ]; then
 
 
            echo "directory \"/openes/es_repo/data\" exists"
 
 
        else
 
 
            mkdir -p /openes/es_repo/data
 
 
        fi
 
 
        if [ -d "/openes/es_repo/logs" ]; then
 
 
            echo "directory \"/openes/es_repo/logs\" exists"
 
 
        else
 
 
            mkdir -p /openes/es_repo/logs
 
 
 
 
        fi
 
 
    cat >>/openes/logstash/config/logstash.yml<<EOF
## 修改以下配置
path.data: /openes/logstash_repo/data
path.logs: /openes/logstash_repo/logs
EOF
 
 
 
 
 
 
    cat >/openes/logstash/config/logstash-data-govern.conf<<EOF
## Sample Logstash configuration for creating a simple
## tcp -> Logstash -> Elasticsearch pipeline.
input {
    tcp {
        mode => "server"
        host => "0.0.0.0"
        port => 4560
        codec => json_lines
    }
}
output {
    elasticsearch {
        hosts => ["http://127.0.0.1:9200"]
        index => "data-govern-%{+YYYY.MM.dd}"
    }
}
EOF
 
 
cd  /openes/logstash/ || exit
 
 
chown -R openes:openes /openes/
 
 
source /etc/profile
nohup ./bin/logstash -f config/logstash-data-govern.conf > logstash.log  2>&1 &
 
 
 
 
!
 
 
 
 
"ps -aux|grep logstash"
 
 
 
 
 
 
fi
 
 
 
 
 
 
}
 
 
 
 
0-basic-install
1-java-install
2-mysql-install
3-redis-install
4-minio-install
5-nginx-install
6-rocketmq-install
7-rocketmq-console-install
8-Elasticsearch-install
9-Kibana-install
10-Logstash-install

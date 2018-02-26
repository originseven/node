#/bin/sh
yum -y install python-setuptools && easy_install pip && pip install cymysql speedtest-cli && yum install git -y
yum -y groupinstall "Development Tools" && wget https://raw.githubusercontent.com/Nightiswatch/ss-panel-and-ss-py-mu/master/libsodium-1.0.13.tar.gz&&tar xf libsodium-1.0.13.tar.gz && cd libsodium-1.0.13&&./configure && make -j2 && make install&&echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf&&ldconfig&& rm -rf /root/libsodium-1.0.13.tar.gz && cd /root
yum install python-setuptools && easy_install pip
yum install git
yum -y install wget
yum -y install epel-release
yum -y install python-pip
#下载后端
cd
rm -rf shadowsocks
git clone -b manyuser https://github.com/glzjin/shadowsocks.git
yum -y install python-devel
yum -y install libffi-devel
yum -y install openssl-devel
cd shadowsocks
pip  install -r requirements.txt
pip install --upgrade pip
cp apiconfig.py userapiconfig.py
cp config.json user-config.json

#加入自启动
chmod +x /etc/rc.d/rc.local
echo "bash /root/shadowsocks/run.sh" >> /etc/rc.d/rc.local

#对接面板

echo
read -p "请输入 node_id[1-99]: " node_id
sed -i "2s/1/$node_id/g" /root/shadowsocks/userapiconfig.py
#对接模式选择
echo "---------------------------------"
echo "对接模式选择"
echo "---------------------------------"
echo "1). glzjinmod"
echo "2). modwebapi"
echo "---------------------------------"
read select
case $select in
	1)

echo
read -p "请输入 mysql host[数据库地址]: " sqlhost
echo
read -p "请输入 mysql username[数据库用户]: " sqluser
echo
read -p "请输入 mysql password[数据库密码]: " sqlpass
echo
read -p "请输入 mysql dbname[数据库库名]: " sqldbname

sed -i "15s/modwebapi/glzjinmod/1"  /root/shadowsocks/userapiconfig.py
sed -i "24s/127.0.0.1/$sqlhost/g" /root/shadowsocks/userapiconfig.py
sed -i "26s/ss/$sqluser/g" /root/shadowsocks/userapiconfig.py
sed -i "27s/ss/$sqlpass/g" /root/shadowsocks/userapiconfig.py
sed -i "28s/shadowsocks/$sqldbname/g" /root/shadowsocks/userapiconfig.py
;;
	2)
echo
read -p "请输入 webapi_url[webapi地址]: " webapi
echo
read -p "请输入 webapi_token[面板config参数]: " webtoken

sed -i "15s/modwebapi/glzjinmod/0"  /root/shadowsocks/userapiconfig.py
sed -i "17s#https://zhaoj.in#$webapi#g"  /root/shadowsocks/userapiconfig.py
sed -i "18s/glzjin/$webtoken/g" /root/shadowsocks/userapiconfig.py
		;;
esac

#配置supervisor
pip install supervisor
wget -O /etc/supervisord.conf https://qianbai.ml/supervisord.conf
wget -O /etc/init.d/supervisord https://qianbai.ml/supervisord
chmod +x /etc/init.d/supervisord
if [ ! -d "/var/log/supervisor" ]; then
  mkdir /var/log/supervisor
fi
sudo service supervisord stop
sudo service supervisord start
sudo supervisorctl reload

#iptables/firewalld
#停止firewall
systemctl stop firewalld.service
#禁止firewall开机启动
systemctl disable firewalld.service 

# 取消文件数量限制
sed -i '$a * hard nofile 512000\n* soft nofile 512000' /etc/security/limits.conf

cd
cd sha*
bash run.sh
echo done.....

reboot

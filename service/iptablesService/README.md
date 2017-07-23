使用数据库sqlite3,基于文件的小型数据库
CREATE TABLE IF NOT EXISTS portConfig (type text,port int,enabled int,inputTraffic int,outputTraffic int,primary key(port,type));
type:tcp/udp
port:port number
enabled:1/0
inputTraffic:输入流量
outputTraffic:输出流量

每次防火墙关闭的时候累加当前流量到inputTraffic和outputTraffic中

数据库的操作专门写一个脚本提供API

数据库表

1. 本防火墙只针对filter表进行设置
2. filter的INPUT链默认规则(policy)是DROP,OUTPUT链和FORWARD的默认规则是ACCEPT
3. 然后依次读取数据表中的端口号,进行放行,对于放行的端口号，同时增加一条出站规则，但是没有动作(没有-j选项),这样的目的是可以记录这个端口出站的流量

启动防火墙顺序:
先设置policy,INPUT -> DROP  OUTPUT -> ACCEPT FORWARD -> ACCEPT
读取数据表中的数据，如果是enable的，
则插入到INPUT中
#则在iptables-save -t filter的输出中查找'-p tcp-or-udp -m tcp-or-udp --dport some-port'(注意：由于-是bash的特殊符号，所以用grep查找的时候需要转义，在前面加反斜杠),如果没有的话则新加一条这个端口的规则(并且加上OUTPUT但是没有动作的规则，为了统计流量iptables -t filter -A INPUT -p tcp-or-udp --sport some-port)

#如果是disable的，则在iptables-save的输出中查找有没这个端口，有的话则删除，没有什么都不做，删除的做法是：iptables -t filter -L INPUT --line-numbers的输出中搜索那个端口，然后找到后截取第一段的序号，最后用iptables -t filter -D INPUT 序号 来删除

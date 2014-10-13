echo "net.ipv6.conf.all.disable_ipv6 = 1 " >>  /etc/sysctl.conf
sysctl -p
#环境变量
echo ""> /root/.bashrc
cat <<EOF>/root/.bashrc
 PS1='\${debian_chroot:+(\$debian_chroot)}\h:\w\\$ '
 umask 022
 export LS_OPTIONS='--color=auto'
 eval "\`dircolors\`"
 alias ls='ls \$LS_OPTIONS'
 alias ll='ls \$LS_OPTIONS -l'
 alias l='ls \$LS_OPTIONS -lA'
 alias rm='rm -i'
 alias cp='cp -i'
 alias mv='mv -i'
 alias q='exit'
EOF
source /root/.bashrc
sed -i.old 's/22/21/' /etc/ssh/sshd_config
/etc/init.d/ssh restart

#3proxy
wget --no-check-certificate https://raw.github.com/benjamin74/3proxy/master/3proxyinstaller.sh
chmod +x 3proxyinstaller.sh
./3proxyinstaller.sh
echo "">/etc/3proxy/3proxy.cfg
cat <<EOF> /etc/3proxy/3proxy.cfg
nserver 8.8.8.8
nserver 8.8.8.4
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
internal 127.0.0.1
daemon
log /var/log/3proxy.log D
logformat "L%d %H:%M %N-%p %C:%c %R:%r %O %I %h %T err:%E"
rotate 30

auth iponly
allow *
socks -a
flush
auth iponly
allow *
proxy -a
EOF
/etc/init.d/3proxyinit start

#stunnel
apt-get install aptitude -y
aptitude install stunnel
cat <<EOF>/etc/stunnel/stunnel.conf
pid = /stunnel4.pid
cert = /etc/stunnel/changyou.cer
key = /etc/stunnel/changyou.key

sslVersion = all
debug = 7
output = /var/log/stunnel4/stunnel.log

socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
socket = l:SO_LINGER=1:1
socket = r:SO_LINGER=1:1
compression = deflate

[https]
accept = 500
connect = 3128

[socks]
accept = 10000
connect = 1080

TIMEOUTclose = 0
EOF
sed -i.old 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
#证书
cat <<EOF>/etc/stunnel/changyou.cer
-----BEGIN CERTIFICATE----- 
MIIE+TCCA+GgAwIBAgIRAOe4VUX+Tow/ZUTEEFGZQcYwDQYJKoZIhvcNAQEFBQAw 
czELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4G 
A1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxGTAXBgNV 
BAMTEFBvc2l0aXZlU1NMIENBIDIwHhcNMTMwODEwMDAwMDAwWhcNMTQwODEwMjM1 
OTU5WjBQMSEwHwYDVQQLExhEb21haW4gQ29udHJvbCBWYWxpZGF0ZWQxFDASBgNV 
BAsTC1Bvc2l0aXZlU1NMMRUwEwYDVQQDEwxjaGFuZ3lvdS5iaXowggEiMA0GCSqG 
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDVKHPZSYeqyksO6v5oAFhUigQ2/Aq9dpFp 
AfJTThuOlepH9prabcxePHcTeI9VRWKEBi2a9G3G6fci8eR2E2l4RaVcFegRLjeC 
y0fWARdSEzO/gcGqqnQlxqfPjPwIaqh2HAG1lCDkTsWKmld0WgVUBUvvH/gpGkQE 
5gNsRFiVmSjrRppHISvaahDrNOi/WDCjpGbJTvX4hSqftn5C7nZoz3CnqRnmJ1gY 
zodkUAd0JWmT4v8W5qgRb8jEsMSc/SeTVkLo60CcNqWSbtba8thobH1Xz7z/aKSI 
n9ujhfBc209Mm+mlVQwPeiW5XchYG4qfm8nHvkTT4iBVVtZSCWZdAgMBAAGjggGp 
MIIBpTAfBgNVHSMEGDAWgBSZ5EBfaxRePgXZ3dNjVPxiuPcArDAdBgNVHQ4EFgQU 
scoP9XZ/fBLckHKviTrIjf6ZE6kwDgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQC 
MAAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMFAGA1UdIARJMEcwOwYL 
KwYBBAGyMQECAgcwLDAqBggrBgEFBQcCARYeaHR0cDovL3d3dy5wb3NpdGl2ZXNz 
bC5jb20vQ1BTMAgGBmeBDAECATA7BgNVHR8ENDAyMDCgLqAshipodHRwOi8vY3Js 
LmNvbW9kb2NhLmNvbS9Qb3NpdGl2ZVNTTENBMi5jcmwwbAYIKwYBBQUHAQEEYDBe 
MDYGCCsGAQUFBzAChipodHRwOi8vY3J0LmNvbW9kb2NhLmNvbS9Qb3NpdGl2ZVNT 
TENBMi5jcnQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTAp 
BgNVHREEIjAgggxjaGFuZ3lvdS5iaXqCEHd3dy5jaGFuZ3lvdS5iaXowDQYJKoZI 
hvcNAQEFBQADggEBAI5Zm/hBrwZuREhrKgKW+cFIpUYMs4KJ7Q9FHCFnAa4UjgPq 
PYkIaINf4z/lmQwfZEi25h75aZJQ2pIO1bq43oHeq/JDzWo4U9VUio/zYl6slS2s 
y9aOjbl6QnNeVrciFjCUx30uJ55aEVMoTBeJsqwlU5huRHAGH56lUVq1MTslXZFu 
PmGKjRma4mjOeyXJeA+fc3Ga3xqeAJ5aGN45oaxEgR1VWpX+sp71HY7TReFKMOPb 
zcZEGYfcsyWnvqXnfsRuju58b7nIskfkG22yyWaCS3VRtfazgx4NP3iOHr/uo90w 
aKFZDPiS5avbZPaPkrsIrcIYEkxkE08NTI2lNkE= 
-----END CERTIFICATE-----
EOF
cat <<EOF>/etc/stunnel/changyou.key
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDVKHPZSYeqyksO
6v5oAFhUigQ2/Aq9dpFpAfJTThuOlepH9prabcxePHcTeI9VRWKEBi2a9G3G6fci
8eR2E2l4RaVcFegRLjeCy0fWARdSEzO/gcGqqnQlxqfPjPwIaqh2HAG1lCDkTsWK
mld0WgVUBUvvH/gpGkQE5gNsRFiVmSjrRppHISvaahDrNOi/WDCjpGbJTvX4hSqf
tn5C7nZoz3CnqRnmJ1gYzodkUAd0JWmT4v8W5qgRb8jEsMSc/SeTVkLo60CcNqWS
btba8thobH1Xz7z/aKSIn9ujhfBc209Mm+mlVQwPeiW5XchYG4qfm8nHvkTT4iBV
VtZSCWZdAgMBAAECggEACOiW5ubmz6GCv43cshYJmwblpDKmdEKnUx8stISYLD5h
uz44PJbIKswWIe8w9lxfAKuNbmN2zxBqLsCzTqgDCW7HuXCE8WrgEQxT5ULIabq5
t/BBWtOi5Q1HaCo5QlTK05zaCW+2bDRKlz9aFlfIzzklckoAwh8B5r6COB0nIqFf
hDyyt18DEOZxEPoHj3/FFCSxJRHaUuEsKmpavZaS8Gfj7oO2MNIgqtdq6I4mvoSR
Lys1e9lbHtjods3IKNwSNuDCnPrjr83n6VGvAVO5Qef2X76oIuZytuHeif9jB3NJ
a9TrhwgLr7ARVGcLsV+lzdHXwCA7B1+bXbvd72vUtQKBgQDzxOwZjShT+ETQlCk6
d9VBYmpDng+qufxriA/+ZhLiGOhEBgx+LD1PDpWMbNeqGBiUrkgKg9yG1wOvP5gJ
x/1+HmpQVyU4+R6TWTMYq1Jj9ueAsRf+GmRpelXkMMfuHczbholPCb62K8bNzvEu
5v/3VPe9RnkEDfqRizFnuSULTwKBgQDf2li7OpreztglYhDFaMEI30wmLpy4z1ux
NGOQaU5OB0v9xIHnqc76dlp2z15CkOwNp5n1sMa+mphHiBCCIeYLsWVP9wrZ3jOr
fBk5XyHZU5cXyIyTeZIlb0A09eFWAYbwuZwmh3BSXNqY1GzHA3EUOrD8tlw7G9Ur
Z5zRROOYkwKBgQDnUeDxxj+Uny09+Lq+3uQhLbDFBYK8cc0UhYMX1+jnYNdXZZ4J
RRXQpXhITyjAIimBPXjjcYmc8wBuFpzB+2OTgG1GW8vYqp3XGXghWsHOVogMWQD5
gjXy2cITzi6KyQCS+LHnrMmquRPoTQ4VgeM34wtMM0m3DUTPRBTX5ps+hQKBgF7o
ajpnbIYO2KFw5H9uHHmwgs6lcJkCgXOuLJBrtWFrwpJDIHiiDDkwuMYqwWIjo5Fe
f+4lFv50+R9K1wT1bl2CxtuSeC1LAkkwgllKtkU4JZVV2BQmtQneEzDhFrqqRxYE
++lx/vNMnvmxBrWSBf13rNZYUt5UvJp8gYZQWNa1AoGBAIdIxG9OsWF8DcT3FxG+
9tup2YbEdBwGTsWN2fQ2D/Rqh1VaDMqWqSb7ypBA8AFOrbemgwJC3wk2DOEskr3Q
bu9ut4ddpVSbfGDYrXras4zLwC3pRqxRIyOY1mod8uIElB17y6UEZlk2j1C5kZJg
4WUYgWFfdo4RHwk1VTrHhZFD
-----END PRIVATE KEY-----
EOF
/etc/init.d/stunnel4 restart


#shadowsocks
cat <<EOF>> /etc/apt/sources.list
# Debian Wheezy, Ubuntu 12.04 or any distribution with libssl > 1.0.1
deb http://shadowsocks.org/debian wheezy main

# Debian Squeeze, Ubuntu 11.04, or any distribution with libssl > 0.9.8, but < 1.0.0
deb http://shadowsocks.org/debian squeeze main
EOF
apt-get update
apt-get install shadowsocks -y --force-yes

cat <<EOF>/etc/shadowsocks/config.json
{
    "server":"209.141.57.170",
    "server_port":8388,
    "local_port":1080,
    "password":"sansam",
    "timeout":60,
    "method":"table"
}
EOF
/etc/init.d/shadowsocks restart
wget http://www.packetix-download.com/files/packetix/v4.02-9387-rtm-2013.09.16-tree/Linux/PacketiX%20VPN%20Server/32bit%20-%20Intel%20x86/vpnserver-v4.02-9387-rtm-2013.09.16-linux-x86-32bit.tar.gz
tar -xzvf vpnserver-v4.02-9387-rtm-2013.09.16-linux-x86-32bit.tar.gz
cd vpnserver
make

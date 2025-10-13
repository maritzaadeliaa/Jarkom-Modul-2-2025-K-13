# Jarkom-Modul-2-2025-K-13

Soal 1

1.	Di tepi Beleriand yang porak-poranda, Eonwe merentangkan tiga jalur: Barat untuk Earendil dan Elwing, Timur untuk Círdan, Elrond, Maglor, serta pelabuhan DMZ bagi Sirion, Tirion, Valmar, Lindon, Vingilot. Tetapkan alamat dan default gateway tiap tokoh sesuai glosarium yang sudah diberikan.
```
Eonwe:

auto eth0
iface eth0 inet dhcp

auto eth1  
iface eth1 inet static
address 10.70.1.1
netmask 255.255.255.0

auto eth2
iface eth2 inet static
address 10.70.2.1
netmask 255.255.255.0

auto eth3
iface eth3 inet static
address 10.70.3.1
netmask 255.255.255.0

Earendil:

auto eth0
iface eth0 inet static
address 10.70.1.2
netmask 255.255.255.0
gateway 10.70.1.1

elwing:

auto eth0
iface eth0 inet static
address 10.70.1.3
netmask 255.255.255.0
gateway 10.70.1.1

Tirion:

auto eth0
iface eth0 inet static
address 10.70.3.3
netmask 255.255.255.0
gateway 10.70.3.1

Valmar:

auto eth0
iface eth0 inet static
address 10.70.3.4
netmask 255.255.255.0
gateway 10.70.3.1

Lindon:

auto eth0
iface eth0 inet static
address 10.70.3.5
netmask 255.255.255.0
gateway 10.70.3.1

Vingilot:

auto eth0
iface eth0 inet static
address 10.70.3.6
netmask 255.255.255.0
gateway 10.70.3.1

Cirdan:

auto eth0
iface eth0 inet static
address 10.70.2.2
netmask 255.255.255.0
gateway 10.70.2.1

Erlond:

auto eth0
iface eth0 inet static
address 10.70.2.3
netmask 255.255.255.0
gateway 10.70.2.1

Maglor:

auto eth0
iface eth0 inet static
address 10.70.2.4
netmask 255.255.255.0
gateway 10.70.2.1

Sirion:

auto eth0
iface eth0 inet static
address 10.70.3.2
netmask 255.255.255.0
gateway 10.70.3.1
```

2. Angin dari luar mulai berhembus ketika Eonwe membuka jalan ke awan NAT. Pastikan jalur WAN di router aktif dan NAT meneruskan trafik keluar bagi seluruh alamat internal sehingga host di dalam dapat mencapai layanan di luar menggunakan IP address.
di Eonwe:
```
apt update && apt install -y iptables
```
```
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.70.0.
0/16
```
```
cat /etc/resolv.conf
```

di semua node selain router:
```
echo nameserver 192.168.122.1 > /etc/resolv.conf
```
```
ping google.com
```

3.	Kabar dari Barat menyapa Timur. Pastikan kelima klien dapat saling berkomunikasi lintas jalur (routing internal via Eonwe berfungsi), lalu pastikan setiap host non-router menambahkan resolver 192.168.122.1 saat interfacenya aktif agar akses paket dari internet tersedia sejak awal.

```
nano /root/.bashrc
```

isinya:
```
# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 is set in /etc/profile, and the default umask is defined in /etc/login.defs. You should not need this unless you want different defaults
# for root. PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ ' umask 022

# You may uncomment the following lines if you want `ls' to be colorized: export LS_OPTIONS='--color=auto' eval "$(dircolors)" alias ls='ls
# $LS_OPTIONS' alias ll='ls $LS_OPTIONS -l' alias l='ls $LS_OPTIONS -lA'
# Note: PS1 is set in /etc/profile, and the default umask is defined
#
# Some more alias to avoid making mistakes: alias rm='rm -i' alias cp='cp -i' alias mv='mv -i'
# in /etc/login.defs. You should not need this unless you want different
# defaults for root.
# PS1='${debian_chroot:+($debian_chroot)} \h:\w\$

# umask 022

# You may uncomment the following lines if you want 'ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "$(dircolors)"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias lr='ls $LS_OPTIONS -lA'
#


# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cpr='cp -i'
# alias mv='mv -i'

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.70.0.0/16
echo nameserver 192.168.122.1 > /etc/resolv.conf

```

4.	Para penjaga nama naik ke menara, di Tirion (ns1/master) bangun zona <xxxx>.com sebagai authoritative dengan SOA yang menunjuk ke ns1.<xxxx>.com dan catatan NS untuk ns1.<xxxx>.com dan ns2.<xxxx>.com. Buat A record untuk ns1.<xxxx>.com dan ns2.<xxxx>.com yang mengarah ke alamat Tirion dan Valmar sesuai glosarium, serta A record apex <xxxx>.com yang mengarah ke alamat Sirion (front door), aktifkan notify dan allow-transfer ke Valmar, set forwarders ke 192.168.122.1. Di Valmar (ns2/slave) tarik zona <xxxx>.com dari Tirion dan pastikan menjawab authoritative. pada seluruh host non-router ubah urutan resolver menjadi IP dari ns1.<xxxx>.com → ns2.<xxxx>.com → 192.168.122.1. Verifikasi query ke apex dan hostname layanan dalam zona dijawab melalui ns1/ns2.

### Tirion:
```
apt-get update
apt-get install bind9 -y
```

```
ln -s /etc/init.d/named /etc/init.d/bind9
```

```
nano /etc/bind/named.conf.local
```
Isinya:
```
zone "K13.com" {
        type master;
        file "/etc/bind/zones/K13.com";
        allow-transfer { 10.70.3.4; };
    also-notify { 10.70.3.4; };
    notify yes;
};
```

```
mkdir /etc/bind/zones
```

```
nano /etc/bind/zone.template
```
isinya:
```
$TTL    604800          ; Waktu cache default (detik)
@       IN      SOA     localhost. root.localhost. (
                        2025100401 ; Serial (format YYYYMMDDXX)
                        604800     ; Refresh (1 minggu)
                        86400      ; Retry (1 hari)
                        2419200    ; Expire (4 minggu)
                        604800 )   ; Negative Cache TTL
;

@       IN      NS      localhost.
@       IN      A       127.0.0.1
```

```
cp /etc/bind/zone.template /etc/bind/zones/K13.com
```

```
nano /etc/bind/zones/K13.com
```
ubah localhostnya, nanti akan diganti seperti ini:
```
$TTL 604800
@   IN  SOA ns1.K13.com. root.K13.com. (
        2025101301 ; Serial (format YYYYMMDDXX)
        3600        ; Refresh (1 jam)
        1800        ; Retry (30 menit)
        1209600     ; Expire (2 minggu)
        86400 )     ; Negative Cache TTL
;

; Name Server (authoritative)
@       IN  NS  ns1.K13.com.
@       IN  NS  ns2.K13.com.

; A records
ns1     IN  A   10.70.3.3       ; Tirion (master)
ns2     IN  A   10.70.3.4       ; Valmar (slave)
@       IN  A   10.70.3.2     ; Apex mengarah ke Sirion
```
cek di console tirion
```
named-checkzone K13.com /etc/bind/zones/K13.com 
```

seharusnya akan mengeluarkan output:
```
zone K13.com/IN: loaded serial 2025100401
OK
```

### Vamar:

```
apt-get update
apt-get install -y bind9 bind9utils dnsutils
```
```
nano /etc/bind/named.conf.options
```

isi:
```
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders { 192.168.122.1; };
    dnssec-validation auto;
    auth-nxdomain no;
    listen-on-v6 { any; };
};

```

```
nano /etc/bind/named.conf.local 
```
isi:
```
zone "K13.com" {
    type slave;
    masters { 10.70.3.3; };           // Tirion (ns1)
    file "/var/cache/bind/K13.com";    // copy zona di ns2
};

```

```
pkill named 2>/dev/null || true
named -c /etc/bind/named.conf
```

```
ls /var/cache/bind/ | grep K13.com
dig @127.0.0.1 K13.com +noall +answer +aa
```
harusnya muncul:
```
K13.com.                604800  IN      A       10.70.3.2

```

### Ke semua client non router

```
echo "nameserver 10.70.3.3" > /etc/resolv.conf
echo "nameserver 10.70.3.4" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

```
```
cat /etc/resolv.conf
```
```
dig k13.com +noall +answer
dig ns1.k13.com +noall +answer
dig ns2.k13.com +noall +answer
```

5.	“Nama memberi arah,” kata Eonwe. Namai semua tokoh (hostname) sesuai glosarium, eonwe, earendil, elwing, cirdan, elrond, maglor, sirion, tirion, valmar, lindon, vingilot, dan verifikasi bahwa setiap host mengenali dan menggunakan hostname tersebut secara system-wide. Buat setiap domain untuk masing masing node sesuai dengan namanya (contoh: eru.<xxxx>.com) dan assign IP masing-masing juga. Lakukan pengecualian untuk node yang bertanggung jawab atas ns1 dan ns2

di semua node (Router juga) kecuali Tirion dan Valmar:

buat file sh
```
nano /root/setup_node.sh 
```
isi file sesuai dengan nodenya

Jalankan:
```
chmod +x /root/setup_node.sh
bash /root/setup_node.sh

```
isi file untuk tiap node
Eonwe:
```
#!/bin/bash
HOSTNAME="eonwe"
IPADDR="10.70.2.4"
DOMAIN="K13.com"

echo "Mengatur hostname dan domain..."
echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

cat > /etc/hosts <<EOF
127.0.0.1   localhost
$IPADDR     $HOSTNAME.$DOMAIN   $HOSTNAME

# DNS Servers
10.70.3.3   ns1.$DOMAIN   ns1
10.70.3.4   ns2.$DOMAIN   ns2

# Semua node lainnya
10.70.3.1   eonwe.$DOMAIN   eonwe
10.70.3.2   sirion.$DOMAIN  sirion
10.70.1.2   earendil.$DOMAIN earendil
10.70.1.3   elwing.$DOMAIN  elwing
10.70.2.2   cirdan.$DOMAIN  cirdan
10.70.2.3   elrond.$DOMAIN  elrond
10.70.2.4   maglor.$DOMAIN  maglor
10.70.3.5   lindon.$DOMAIN  lindon
10.70.3.6   vingilot.$DOMAIN vingilot
EOF

# Resolver DNS
echo "nameserver 10.70.3.3" > /etc/resolv.conf
echo "nameserver 10.70.3.4" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

echo "Selesai konfigurasi untuk $HOSTNAME.$DOMAIN"
echo "Hostname sekarang: $(hostname)"

```
Earendil:
```
#!/bin/bash
HOSTNAME="earendil"
IPADDR="10.70.1.2"
DOMAIN="K13.com"

echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

cat > /etc/hosts <<EOF
127.0.0.1 localhost
$IPADDR $HOSTNAME.$DOMAIN $HOSTNAME

10.70.3.3 ns1.$DOMAIN ns1
10.70.3.4 ns2.$DOMAIN ns2
10.70.3.1 eonwe.$DOMAIN eonwe
10.70.3.2 sirion.$DOMAIN sirion
10.70.1.2 earendil.$DOMAIN earendil
10.70.1.3 elwing.$DOMAIN elwing
10.70.2.2 cirdan.$DOMAIN cirdan
10.70.2.3 elrond.$DOMAIN elrond
10.70.2.4 maglor.$DOMAIN maglor
10.70.3.5 lindon.$DOMAIN lindon
10.70.3.6 vingilot.$DOMAIN vingilot
EOF

echo "nameserver 10.70.3.3" > /etc/resolv.conf
echo "nameserver 10.70.3.4" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

echo "Selesai konfigurasi untuk $HOSTNAME.$DOMAIN"
hostname
```

Elwing:
```
#!/bin/bash
HOSTNAME="elwing"
IPADDR="10.70.1.3"
DOMAIN="K13.com"

echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

cat > /etc/hosts <<EOF
127.0.0.1 localhost
$IPADDR $HOSTNAME.$DOMAIN $HOSTNAME

10.70.3.3 ns1.$DOMAIN ns1
10.70.3.4 ns2.$DOMAIN ns2
10.70.3.1 eonwe.$DOMAIN eonwe
10.70.3.2 sirion.$DOMAIN sirion
10.70.1.2 earendil.$DOMAIN earendil
10.70.1.3 elwing.$DOMAIN elwing
10.70.2.2 cirdan.$DOMAIN cirdan
10.70.2.3 elrond.$DOMAIN elrond
10.70.2.4 maglor.$DOMAIN maglor
10.70.3.5 lindon.$DOMAIN lindon
10.70.3.6 vingilot.$DOMAIN vingilot
EOF

echo "nameserver 10.70.3.3" > /etc/resolv.conf
echo "nameserver 10.70.3.4" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

echo "Selesai konfigurasi untuk $HOSTNAME.$DOMAIN"
hostname

```
Sirion:
```
#!/bin/bash
HOSTNAME="sirion"
IPADDR="10.70.3.2"
DOMAIN="K13.com"

echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

cat > /etc/hosts <<EOF
127.0.0.1 localhost
$IPADDR $HOSTNAME.$DOMAIN $HOSTNAME

10.70.3.3 ns1.$DOMAIN ns1
10.70.3.4 ns2.$DOMAIN ns2
10.70.3.1 eonwe.$DOMAIN eonwe
10.70.3.2 sirion.$DOMAIN sirion
10.70.1.2 earendil.$DOMAIN earendil
10.70.1.3 elwing.$DOMAIN elwing
10.70.2.2 cirdan.$DOMAIN cirdan
10.70.2.3 elrond.$DOMAIN elrond
10.70.2.4 maglor.$DOMAIN maglor
10.70.3.5 lindon.$DOMAIN lindon
10.70.3.6 vingilot.$DOMAIN vingilot
EOF

echo "nameserver 10.70.3.3" > /etc/resolv.conf
echo "nameserver 10.70.3.4" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

echo "Selesai konfigurasi untuk $HOSTNAME.$DOMAIN"
hostname

```

Cirdan:
```
#!/bin/bash
HOSTNAME="cirdan"
IPADDR="10.70.2.2"
DOMAIN="K13.com"

echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

cat > /etc/hosts <<EOF
127.0.0.1 localhost
$IPADDR $HOSTNAME.$DOMAIN $HOSTNAME

10.70.3.3 ns1.$DOMAIN ns1
10.70.3.4 ns2.$DOMAIN ns2
10.70.3.1 eonwe.$DOMAIN eonwe
10.70.3.2 sirion.$DOMAIN sirion
10.70.1.2 earendil.$DOMAIN earendil
10.70.1.3 elwing.$DOMAIN elwing
10.70.2.2 cirdan.$DOMAIN cirdan
10.70.2.3 elrond.$DOMAIN elrond
10.70.2.4 maglor.$DOMAIN maglor
10.70.3.5 lindon.$DOMAIN lindon
10.70.3.6 vingilot.$DOMAIN vingilot
EOF

echo "nameserver 10.70.3.3" > /etc/resolv.conf
echo "nameserver 10.70.3.4" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

echo "Selesai konfigurasi untuk $HOSTNAME.$DOMAIN"
hostname

```

Elrond:
```
#!/bin/bash
HOSTNAME="elrond"
IPADDR="10.70.2.3"
DOMAIN="K13.com"

echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

cat > /etc/hosts <<EOF
127.0.0.1 localhost
$IPADDR $HOSTNAME.$DOMAIN $HOSTNAME

10.70.3.3 ns1.$DOMAIN ns1
10.70.3.4 ns2.$DOMAIN ns2
10.70.3.1 eonwe.$DOMAIN eonwe
10.70.3.2 sirion.$DOMAIN sirion
10.70.1.2 earendil.$DOMAIN earendil
10.70.1.3 elwing.$DOMAIN elwing
10.70.2.2 cirdan.$DOMAIN cirdan
10.70.2.3 elrond.$DOMAIN elrond
10.70.2.4 maglor.$DOMAIN maglor
10.70.3.5 lindon.$DOMAIN lindon
10.70.3.6 vingilot.$DOMAIN vingilot
EOF

echo "nameserver 10.70.3.3" > /etc/resolv.conf
echo "nameserver 10.70.3.4" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

echo "Selesai konfigurasi untuk $HOSTNAME.$DOMAIN"
hostname

```
Maglor
```
#!/bin/bash
HOSTNAME="maglor"
IPADDR="10.70.2.4"
DOMAIN="K13.com"

echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

cat > /etc/hosts <<EOF
127.0.0.1 localhost
$IPADDR $HOSTNAME.$DOMAIN $HOSTNAME

10.70.3.3 ns1.$DOMAIN ns1
10.70.3.4 ns2.$DOMAIN ns2
10.70.3.1 eonwe.$DOMAIN eonwe
10.70.3.2 sirion.$DOMAIN sirion
10.70.1.2 earendil.$DOMAIN earendil
10.70.1.3 elwing.$DOMAIN elwing
10.70.2.2 cirdan.$DOMAIN cirdan
10.70.2.3 elrond.$DOMAIN elrond
10.70.2.4 maglor.$DOMAIN maglor
10.70.3.5 lindon.$DOMAIN lindon
10.70.3.6 vingilot.$DOMAIN vingilot
EOF

echo "nameserver 10.70.3.3" > /etc/resolv.conf
echo "nameserver 10.70.3.4" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

echo "Selesai konfigurasi untuk $HOSTNAME.$DOMAIN"
hostname
```
Lindon:
```
#!/bin/bash
HOSTNAME="lindon"
IPADDR="10.70.3.5"
DOMAIN="K13.com"

echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

cat > /etc/hosts <<EOF
127.0.0.1 localhost
$IPADDR $HOSTNAME.$DOMAIN $HOSTNAME

10.70.3.3 ns1.$DOMAIN ns1
10.70.3.4 ns2.$DOMAIN ns2
10.70.3.1 eonwe.$DOMAIN eonwe
10.70.3.2 sirion.$DOMAIN sirion
10.70.1.2 earendil.$DOMAIN earendil
10.70.1.3 elwing.$DOMAIN elwing
10.70.2.2 cirdan.$DOMAIN cirdan
10.70.2.3 elrond.$DOMAIN elrond
10.70.2.4 maglor.$DOMAIN maglor
10.70.3.5 lindon.$DOMAIN lindon
10.70.3.6 vingilot.$DOMAIN vingilot
EOF

echo "nameserver 10.70.3.3" > /etc/resolv.conf
echo "nameserver 10.70.3.4" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

echo "Selesai konfigurasi untuk $HOSTNAME.$DOMAIN"
hostname

```
Vingilot
```
#!/bin/bash
HOSTNAME="vingilot"
IPADDR="10.70.3.6"
DOMAIN="K13.com"

echo "$HOSTNAME" > /etc/hostname
hostname $HOSTNAME

cat > /etc/hosts <<EOF
127.0.0.1 localhost
$IPADDR $HOSTNAME.$DOMAIN $HOSTNAME

10.70.3.3 ns1.$DOMAIN ns1
10.70.3.4 ns2.$DOMAIN ns2
10.70.3.1 eonwe.$DOMAIN eonwe
10.70.3.2 sirion.$DOMAIN sirion
10.70.1.2 earendil.$DOMAIN earendil
10.70.1.3 elwing.$DOMAIN elwing
10.70.2.2 cirdan.$DOMAIN cirdan
10.70.2.3 elrond.$DOMAIN elrond
10.70.2.4 maglor.$DOMAIN maglor
10.70.3.5 lindon.$DOMAIN lindon
10.70.3.6 vingilot.$DOMAIN vingilot
EOF

echo "nameserver 10.70.3.3" > /etc/resolv.conf
echo "nameserver 10.70.3.4" >> /etc/resolv.conf
echo "nameserver 192.168.122.1" >> /etc/resolv.conf

echo "Selesai konfigurasi untuk $HOSTNAME.$DOMAIN"
hostname

```
Setelah semua jalanin, tes:
```
ping -c3 ns1.K13.com
ping -c3 sirion.K13.com
ping -c3 elrond.K13.com

```

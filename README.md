# Jarkom-Modul-2-2025-K-13

| Nama                   | NRP        |
|-------------------------|------------|
| Ahmad Rabbani Fata     | 5027241046 |
| Maritza Adelia Sucipto | 5027241111 |

Soal 1 - 10
1.	Di tepi Beleriand yang porak-poranda, Eonwe merentangkan tiga jalur: Barat untuk Earendil dan Elwing, Timur untuk Círdan, Elrond, Maglor, serta pelabuhan DMZ bagi Sirion, Tirion, Valmar, Lindon, Vingilot. Tetapkan alamat dan default gateway tiap tokoh sesuai glosarium yang sudah diberikan.
```bash
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
```bash
apt update && apt install -y iptables
```
```
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.70.0.0/16
```
```
cat /etc/resolv.conf
```

di semua node selain router:
```bash
echo nameserver 192.168.122.1 > /etc/resolv.conf
```
```
ping google.com
```

3.	Kabar dari Barat menyapa Timur. Pastikan kelima klien dapat saling berkomunikasi lintas jalur (routing internal via Eonwe berfungsi), lalu pastikan setiap host non-router menambahkan resolver 192.168.122.1 saat interfacenya aktif agar akses paket dari internet tersedia sejak awal.

```bash
nano /root/.bashrc
```

isinya:
```bash
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
```bash
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
```bash
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
```bash
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

```bash
cp /etc/bind/zone.template /etc/bind/zones/K13.com
```

```
nano /etc/bind/zones/K13.com
```
ubah localhostnya, nanti akan diganti seperti ini:
```bash
$TTL    604800          ; Waktu cache default (detik)
@       IN      SOA     ns1.K13.com. root.K13.com. (
                        2025100401      ; Serial (format YYYYMMDDXX)
                        604800          ; Refresh (1 minggu)
                        86400           ; Retry (1 hari)
                        2419200         ; Expire (4 minggu)
                        604800 )        ; Negative Cache TTL
;

@       IN      NS      ns1.K13.com.
@       IN      NS      ns2.K13.com.

; A records
ns1     IN      A       10.70.3.3       ; Tirion (master)
ns2     IN      A       10.70.3.4       ; Valmar (slave)
@       IN      A       10.70.3.2       ; Apex mengarah ke Sirion

```
cek di console tirion
```
named-checkconf
```

lalu jalankan:
```
named-checkzone K13.com /etc/bind/zones/K13.com 
```

seharusnya akan mengeluarkan output:
```bash
zone K13.com/IN: loaded serial 2025100401
OK
```



### Valmar:

```bash
apt-get update
apt-get install -y bind9 bind9utils dnsutils
```
```
nano /etc/bind/named.conf.options
```

isi:
```bash
options {
        directory "/var/cache/bind";

        listen-on { any; };
        listen-on-v6 { any; };

        allow-query { any; };
        recursion yes;

        forwarders { 192.168.122.1; };
        forward only;

        dnssec-validation no;

        auth-nxdomain no;
};
```
Lalu validasi & jalankan:
```bash
named-checkconf
named -g -c /etc/bind/named.conf
pkill named 2>/dev/null || true # pastikan tidak ada proses lama
named -c /etc/bind/named.conf & # start di background
```
Tes dari Valmar (ns2)
```bash
dig @127.0.0.1 K13.com +noall +answer +aa
dig @10.70.3.4 K13.com +noall +answer +aa
dig @10.70.3.4 -x 10.70.3.2 +noall +answer +aa

```
```
nano /etc/bind/named.conf.local 
```
isi:
```bash
zone "K13.com" {
    type slave;
    file "/var/cache/bind/K13.com";    // copy zona di ns2
    masters { 10.70.3.3; };           // Tirion (ns1)
    allow-notify { 10.70.3.3; };
};

```
di Tirion:
```bash
service bind9 restart || (pkill named 2>/dev/null || true; named -c /etc/bind/named.conf)
```
di Valmar:
```bash
pkill named 2>/dev/null || true
named -c /etc/bind/named.conf
```
Lalu jalankan:
```bash
ls /var/cache/bind/ | grep K13.com
dig @127.0.0.1 K13.com +noall +answer +aa
```
harusnya muncul:
```
K13.com.                604800  IN      A       10.70.3.2

```

### Ke semua client non router

```bash
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
```bash
chmod +x /root/setup_node.sh
bash /root/setup_node.sh

```
isi file untuk tiap node
Eonwe:
```bash
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
```bash
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
```bash
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
```bash
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
```bash
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
```bash
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
```bash
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
```bash
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
```bash
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
```bash
ping -c3 ns1.K13.com
ping -c3 sirion.K13.com
ping -c3 elrond.K13.com

```

6.	Lonceng Valmar berdentang mengikuti irama Tirion. Pastikan zone transfer berjalan, Pastikan Valmar (ns2) telah menerima salinan zona terbaru dari Tirion (ns1). Nilai serial SOA di keduanya harus sama

di Valmar cek apakah zone transfer berhasil:
```
ls /var/cache/bind/
```
harus muncul ```file K13.com```

lalu cek serial-nya di Tirion dan Valmar:
```
dig @127.0.0.1 K13.com SOA +noall +answer
```
Contoh Outputnya:
```
K13.com.                604800  IN      SOA     ns1.K13.com. root.K13.com. 2025100401 604800 86400 2419200 604800
```

7.	Peta kota dan pelabuhan dilukis. Sirion sebagai gerbang, Lindon sebagai web statis, Vingilot sebagai web dinamis. Tambahkan pada zona <xxxx>.com A record untuk sirion.<xxxx>.com (IP Sirion), lindon.<xxxx>.com (IP Lindon), dan vingilot.<xxxx>.com (IP Vingilot). Tetapkan CNAME :
-	www.<xxxx>.com → sirion.<xxxx>.com, 
-	static.<xxxx>.com → lindon.<xxxx>.com, dan 
-	app.<xxxx>.com → vingilot.<xxxx>.com. 
Verifikasi dari dua klien berbeda bahwa seluruh hostname tersebut ter-resolve ke tujuan yang benar dan konsisten.

Tirion:
```
nano /etc/bind/zones/K13.com
```
Tambahkan bagian berikut di bawah A records:
```bash
; A records
ns1     IN A 10.70.3.3       ; Tirion (master)
ns2     IN A 10.70.3.4       ; Valmar (slave)
@       IN A 10.70.3.2       ; Apex mengarah ke Sirion

; Tambahan untuk web & gateway
sirion  IN A 10.70.3.2       ; Sirion (gateway / gerbang)
lindon  IN A 10.70.3.5       ; Lindon (web statis)
vingilot IN A 10.70.3.6      ; Vingilot (web dinamis)

; CNAME (alias)
www     IN CNAME sirion.K13.com.
static  IN CNAME lindon.K13.com.
app     IN CNAME vingilot.K13.com.

```
Naikkan 1 angka terakhir di baris serial SOA:
```2025100401  →  2025100402```

Restart Bind di Tirion dan Valmar
```bash
pkill named 2>/dev/null || true
named -c /etc/bind/named.conf
```
Lalu cek apakah file zona sudah ditransfer ulang di Valmar:
```
ls /var/cache/bind/
```

Verifikasi dari dua klien berbeda
misal Eardil dan Elwing
```bash
dig sirion.K13.com +short
dig lindon.K13.com +short
dig vingilot.K13.com +short

dig www.K13.com +short
dig static.K13.com +short
dig app.K13.com +short
```

Outputnya:
```
10.70.3.2
10.70.3.5
10.70.3.6
sirion.K13.com.
10.70.3.2
lindon.K13.com.
10.70.3.5
vingilot.K13.com.
10.70.3.6
```

8.	Setiap jejak harus bisa diikuti. Di Tirion (ns1) deklarasikan satu reverse zone untuk segmen DMZ tempat Sirion, Lindon, Vingilot berada. Di Valmar (ns2) tarik reverse zone tersebut sebagai slave, isi PTR untuk ketiga hostname itu agar pencarian balik IP address mengembalikan hostname yang benar, lalu pastikan query reverse untuk alamat Sirion, Lindon, Vingilot dijawab authoritative.

### Konfigurasi di Tirion (ns1 / master)
Deklarasi reverse zone di /etc/bind/named.conf.local
Tambahkan di bawah zona K13.com:
```bash
zone "3.70.10.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.3.70.10";
    notify yes;
    also-notify { 10.70.3.4; };
    allow-transfer { 10.70.3.4; };
};
```

lalu Buat file zona reverse /etc/bind/zones/db.3.70.10
```bash
$TTL 604800
@   IN  SOA ns1.K13.com. root.K13.com. (
        2025101301 ; Serial
        3600       ; Refresh
        1800       ; Retry
        1209600    ; Expire
        86400 )    ; Negative Cache TTL
;

; Name Servers
@       IN  NS  ns1.K13.com.
@       IN  NS  ns2.K13.com.

; PTR Records
2   IN  PTR  Sirion.K13.com.
5   IN  PTR  Lindon.K13.com.
6   IN  PTR  Vingilot.K13.com.
3   IN  PTR  ns1.K13.com.
4   IN  PTR  ns2.K13.com.
```
Cek & reload BIND
```bash
named-checkzone 3.70.10.in-addr.arpa /etc/bind/zones/db.3.70.10
service bind9 restart
service bind9 status
```
### Konfigurasi di Valmar (ns2 / slave)
Tambahkan zona slave di /etc/bind/named.conf.local
```bash
zone "3.70.10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.3.70.10";
    masters { 10.70.3.3; };
    allow-notify { 10.70.3.3; };
};
```
Reload BIND
```
pkill named 2>/dev/null || true
named -c /etc/bind/named.conf
```
Cek zone transfer di Valmar
```bash
ls -l /var/cache/bind/ # harus ada: K13.com  dan  db.10.70.3 
```
Tes query di Valmar
```
dig -4 @127.0.0.1 K13.com SOA +noall +answer +aa
dig -4 @127.0.0.1 sirion.K13.com +short
dig -4 @127.0.0.1 -x 10.70.3.2 +short
```
Tes dari klien lain (Earendil / Elwing)
```
dig K13.com +short
dig sirion.K13.com +short
dig static.K13.com +short
dig app.K13.com +short
dig -x 10.70.3.2 +short
dig -x 10.70.3.5 +short
dig -x 10.70.3.6 +short
```
Cek sinkronisasi serial

pastikan nilai Serial SOA di Tirion dan Valmar sama:
```
dig -4 @10.70.3.3 K13.com SOA +short
dig -4 @10.70.3.4 K13.com SOA +short
```

9.	Lampion Lindon dinyalakan. Jalankan web statis pada hostname static.<xxxx>.com dan buka folder arsip /annals/ dengan autoindex (directory listing) sehingga isinya dapat ditelusuri. Akses harus dilakukan melalui hostname, bukan IP.

### Lindon

install Apache2
```
apt-get update
apt-get install apache2 -y

```
Buat folder untuk web statis
```
mkdir -p /var/www/static.K13.com/annals
```
Isi folder /annals/ dengan file dummy (buat testing dulu):
```bash
echo "<h2>Arsip Sejarah Lindon</h2>" > /var/www/static.K13.com/annals/index.html
echo "catatan1.txt" > /var/www/static.K13.com/annals/catatan1.txt
echo "catatan2.txt" > /var/www/static.K13.com/annals/catatan2.txt
```
Buat konfigurasi Virtual Host
```
nano /etc/apache2/sites-available/static.K13.com.conf
```
isinya:
```bash
<VirtualHost *:80>
    ServerAdmin webmaster@K13.com
    ServerName static.K13.com
    ServerAlias www.static.K13.com

    DocumentRoot /var/www/static.K13.com

    <Directory /var/www/static.K13.com/annals>
        Options +Indexes
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/static_error.log
    CustomLog ${APACHE_LOG_DIR}/static_access.log combined
</VirtualHost>
```

10.	Vingilot mengisahkan cerita dinamis. Jalankan web dinamis (PHP-FPM) pada hostname app.<xxxx>.com dengan beranda dan halaman about, serta terapkan rewrite sehingga /about berfungsi tanpa akhiran .php. Akses harus dilakukan melalui hostname.

Soal 11 - 20

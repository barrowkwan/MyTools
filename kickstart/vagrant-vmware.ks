
install
text

cdrom

lang en_US.UTF-8
keyboard us

network --onboot yes --device eth0 --bootproto dhcp --noipv6

timezone --utc America/Los Angeles

zerombr
clearpart --all --initlabel
bootloader --location=mbr --append="crashkernel=auto rhgb quiet"

part /boot --fstype ext3 --size=256
part pv.01 --size=1024 --grow 
volgroup vg_root pv.01
logvol swap --fstype swap --name=lv_swap --vgname=vg_root --size=1024
logvol / --fstype ext4 --name=lv_root --vgname=vg_root --size=1024 --grow

authconfig --enableshadow --passalgo=sha512

rootpw --iscrypted $1$dUDXSoA9$/bEOTiK9rmsVgccsYir8W0

selinux --disabled
firewall --disable

skipx

%packages --excludedocs --nobase
@core
openssh-server
openssh-clients
wget
curl
git
man
vim
ntp
systemtap-devel
gcc
gcc-c++
kernel-devel
avahi-libs
glibc-devel
libgomp
mpfr
glibc-headers
libstdc++-devel
cpp
cloog-ppl
kernel-headers
ppl
elfutils-libs
openssl-devel
krb5-devel
zlib-devel
keyutils-libs-devel
libselinux-devel
libcom_err-devel
libsepol-devel
readline-devel
ncurses-devel
autoconf
perl
perl-libs
perl-version
perl-Pod-Simple
perl-Module-Pluggable
perl-Pod-Escapes
%end

%post
/sbin/chkconfig ntpd on
/sbin/service ntpd stop
ntpdate time.nist.gov
/sbin/service ntpd start

/sbin/chkconfig sshd on
/sbin/chkconfig iptables off
/sbin/chkconfig ip6tables off

/usr/sbin/useradd vagrant

/bin/mkdir -m 0700 -p /home/vagrant/.ssh

/bin/cat  >> /home/vagrant/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMuQLIREq+pccclNY+1adubFlp+88bBXlQBx2b5pPxZRhctOwX0zE2ZGTy+OlgnWwHjCxs4g6ugt2XCK/sMGXzdP/jqgIZ9+z/BUENBe2J7XF0tubQ8MJn5SKkRq4/ch98NZjNVYt3ftDBq1bkSidjm09u/wUGF7mD69KgqAU5kUE1nIgr7tKKxMxNgCTRKGO6JS8mv9dw27qXrtm6eluZLzb6pDhukYNzr29qXL6/uv8rBIT+nxVlTeG7LD8INNZXoUaREWKR7eeRDLAa4scPPWy6eXXHZJE9mG9gBrcM86fPRs+WHVyMbKoDAzrsiGsH8S0562MmYTBNQT3lPZqP Barrow Kwan Vagrant Public Key
EOF

/bin/chmod 600 /home/vagrant/.ssh/authorized_keys
/bin/chown -R vagrant:vagrant /home/vagrant/.ssh

/bin/sed -i 's/^\(Defaults.*requiretty\)/#\1/' /etc/sudoers
/bin/echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

/bin/cat << EOF1 > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=dhcp
EOF1

/bin/echo "# Override /lib/udev/rules.d/75-persistent-net-generator.rules" > /etc/udev/rules.d/75-persistent-net-generator.rules

/bin/cat << EOF > /etc/udev/rules.d/70-persistent-net.rules
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{type}=="1", KERNEL=="eth0", NAME="eth0"
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{type}=="1", KERNEL=="eth1", NAME="eth1"
EOF

/usr/bin/yum clean all
/usr/bin/yum makecache

/usr/bin/yum update -y --skip-broken
rm -rf /tmp/*

rm -f /var/log/wtmp /var/log/btmp

history -c
%end

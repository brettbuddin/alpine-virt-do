#!/bin/bash

set -eou pipefail

USER=admin
USER_HOME=/home/$USER

# Create admin user.
addgroup -S $USER
adduser \
    --home $USER_HOME \
    --ingroup wheel admin \
    --shell /bin/bash \
    $USER

sed -i '/%wheel/s/^# //' /etc/sudoers
mkdir -p $USER_HOME/.ssh
touch $USER_HOME/.ssh/authorized_keys
chmod 700 $USER_HOME/.ssh
chmod 600 $USER_HOME/.ssh/authorized_keys
chown -R admin:wheel $USER_HOME/.ssh

touch $USER_HOME/.profile
chown -R admin:wheel $USER_HOME/.profile

cat > $USER_HOME/.profile <<-EOF
export TERM=vt100
EOF

# Configure networking.
cat > /etc/network/interfaces <<-EOF
iface lo inet loopback
iface eth0 inet dhcp
EOF
ln -s networking /etc/init.d/net.lo
ln -s networking /etc/init.d/net.eth0

# Configure sshd.
sed -i "s/.*RSAAuthentication.*/RSAAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/.*AuthorizedKeysFile.*/AuthorizedKeysFile\t\.ssh\/authorized_keys/g" /etc/ssh/sshd_config
sed -i "s/.*PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config

# Create an initialization script that ensures the disk fills all the space
# given to it and fetches information from the DigitalOcean metadata service.
cat > /bin/do-init <<-EOF
#!/bin/sh

resize2fs /dev/vda

wget -T 5 http://169.254.169.254/metadata/v1/hostname    -q -O /etc/hostname
wget -T 5 http://169.254.169.254/metadata/v1/public-keys -q -O $USER_HOME/.ssh/authorized_keys
hostname -F /etc/hostname

rc-update del do-init default
exit 0
EOF
chmod +x /bin/do-init

cat > /etc/init.d/do-init <<-EOF
#!/sbin/openrc-run

depend() {
    need net.eth0
}

command="/bin/do-init"
command_args=""
pidfile="/tmp/do-init.pid"
EOF
chmod +x /etc/init.d/do-init

# Enable services
rc-update add chronyd default
rc-update add crond default
rc-update add do-init default
rc-update add net.eth0 default
rc-update add net.lo boot
rc-update add sshd default

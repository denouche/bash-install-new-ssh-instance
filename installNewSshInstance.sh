# Ask new port
echo "On which port the new ssh instance have to listen to ?"
read port

# Ask ssh suffix
echo "Choose a suffix for new files (ex: if you choose 'external', the new process will be called 'ssh-external')"
read suffix

# Copy configuration file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config-$suffix

sed -r -i "s/#?(Port\s+)22/\1$port/g" /etc/ssh/sshd_config-$suffix
sed -r -i 's/#?(PasswordAuthentication\s+)yes/\1no/g' /etc/ssh/sshd_config-$suffix
sed -r -i 's/#?(PermitRootLogin\s+).*/\1no/g' /etc/ssh/sshd_config-$suffix
sed -r -i "s/#(AuthorizedKeysFile\s+).*/\1.ssh\/authorized_keys-$suffix/g" /etc/ssh/sshd_config-$suffix
sed -r -i "s|#?(PidFile\s+).*|\1/run/sshd-$suffix.pid|g" /etc/ssh/sshd_config-$suffix
echo 'AllowUsers ' >> /etc/ssh/sshd_config-$suffix

# Copy executable
ln -s /usr/sbin/sshd /usr/sbin/sshd-$suffix

# Copy launch executable
cp /etc/init.d/ssh /etc/init.d/ssh-$suffix
sed -r -i "s/(#\s+Provides:\s+)ssh sshd/\1 ssh-$suffix sshd-$suffix/g" /etc/init.d/ssh-$suffix
sed -r -i "s|(/usr/sbin/sshd)|\1-$suffix|g" /etc/init.d/ssh-$suffix
sed -r -i "s|(/run/sshd)\.pid|\1-$suffix.pid|g" /etc/init.d/ssh-$suffix
sed -r -i "s|(/etc/default/ssh)|\1-$suffix|g" /etc/init.d/ssh-$suffix

# copy systemd file
cp /lib/systemd/system/ssh.service /lib/systemd/system/ssh-$suffix.service
sed -r -i "s|(/usr/sbin/sshd)|\1-$suffix|g" /lib/systemd/system/ssh-$suffix.service
sed -r -i "s|(/etc/default/ssh)|\1-$suffix|g" /lib/systemd/system/ssh-$suffix.service
sed -r -i "s/(Alias=sshd).service/\1-$suffix.service/g" /lib/systemd/system/ssh-$suffix.service

# Copy and configure default options
cp /etc/default/ssh /etc/default/ssh-$suffix
sed -i "s|SSHD_OPTS=|SSHD_OPTS=\"-f /etc/ssh/sshd_config-$suffix -o PidFile=/run/sshd-$suffix.pid\"|g" /etc/default/ssh-$suffix

# Start service at boot with systemd
systemctl enable ssh-$suffix

echo "You can configure the authorized keys in %h/.ssh/authorized_keys-$suffix file"
echo "You can configure users allowed to connect in /etc/ssh/sshd_config-$suffix : section AllowUsers"



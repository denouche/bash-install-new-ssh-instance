# Copy configuration file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config-external
echo "On which port ssh external have to listen to ?"
read port
sed -r -i "s/(Port\s+)22/\1$port/g" /etc/ssh/sshd_config-external
sed -r -i 's/#(PasswordAuthentication\s+)yes/\1no/g' /etc/ssh/sshd_config-external
sed -r -i 's/(PermitRootLogin\s+)yes/\1no/g' /etc/ssh/sshd_config-external
sed -r -i 's/#AuthorizedKeysFile\s+%h\/\.ssh\/authorized_keys/AuthorizedKeysFile %h\/\.ssh\/authorized_keys-external/g' /etc/ssh/sshd_config-external
echo 'PidFile /var/run/sshd-external.pid' >> /etc/ssh/sshd_config-external
echo 'AllowUsers ' >> /etc/ssh/sshd_config-external

# Copy executable
ln -s /usr/sbin/sshd /usr/sbin/sshd-external

# Copy launch executable
cp /etc/init.d/ssh /etc/init.d/ssh-external
sed -r -i 's/(#\s+Provides:\s+sshd)/\1-external/g' /etc/init.d/ssh-external
sed -r -i 's/(\/usr\/sbin\/sshd)/\1-external/g' /etc/init.d/ssh-external
sed -r -i 's/(\/var\/run\/sshd)\.pid/\1-external.pid/g' /etc/init.d/ssh-external
sed -r -i 's/(\/etc\/default\/ssh)/\1-external/g' /etc/init.d/ssh-external

# Copy and configure default options
cp /etc/default/ssh /etc/default/ssh-external
sed -i 's/SSHD_OPTS=/SSHD_OPTS="-f \/etc\/ssh\/sshd_config-external -o PidFile=\/var\/run\/sshd-external.pid"/g' /etc/default/ssh-external

# Start service at boot
cd /etc/init.d/
update-rc.d ssh-external defaults 99

echo "You can now start the service using /etc/init.d/ssh-external"
echo "You can configure the authorized keys in %h/.ssh/authorized_keys-external file"
echo "You can configure users allowed to connect in /etc/ssh/sshd_config-external : section AllowUsers"

#!/bin/bash

# Change root password after each start
ROOT_PASSWORD=$(pwgen -s 12 1)

echo "root:$ROOT_PASSWORD" | chpasswd

echo "========================================================================"
echo "You can now connect with the root password : "
echo ""
echo "    $ROOT_PASSWORD"
echo ""
echo "========================================================================"
echo "$ROOT_PASSWORD" > /credentials
chmod 600 /credentials

# Add a user
user=${WORKER_NAME}
userid=${WORKER_UID}
if [ "$user" = "" ]; then
	user="sshguest"
fi
if id -u "$user" >/dev/null 2>&1; then
	echo "$user:$ROOT_PASSWORD" | chpasswd
else
	useradd -m -u $userid -s /bin/bash --home-dir=/home/$user --user-group $user; echo "$user:$ROOT_PASSWORD" | chpasswd
fi

exec /usr/sbin/sshd -D
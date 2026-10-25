#!/bin/bash

# Start SSH server in the background
echo "Starting SSH server..."
/usr/sbin/sshd

# Start Apache in the foreground (this keeps the container running)
echo "Starting Apache..."
exec apachectl -D FOREGROUND

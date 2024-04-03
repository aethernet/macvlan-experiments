#!/bin/bash

sleep 5

PID=""

# Get the PID of the container, loop until it is set
while [ -z "$PID" ]; do
  PID=$(docker inspect --format '{{.State.Pid}}' $(docker ps -qf "name=balena-hello-world"))
  if [ -z "$PID" ]; then
    echo "Waiting for PID to be set..."
    sleep 5  # Wait for 5 seconds before checking again
  fi
done

# Set the firewall rules for the namespaced network
nsenter -t ${PID} -n sh << EOL
NIC=\$(ip addr | grep 'inet 10.0.10' | awk '{print \$NF}')
iptables -A INPUT -i \${NIC} -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -i \${NIC} -j DROP
EOL

balena-idle

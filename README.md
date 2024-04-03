# macvlan-experiments

Playing with a fork of `balena-engine` with macvlan driver set

Warning: this won't work on current `balena-engine` or `balenaos`

This exploration is twofold: 
- confirm that a container can be attached to a `macvlan` (or `ipvlan`) and a `bridge` network at the same time
- confirm we can manipulate the network stack (and especially the fw) of a `macvlan` container from another (properly privileged) container

This project will:
- setup a bridge network with default configuration: `my_bridge`
- setup a macvlan network on 10.0.10.0/24 vlan10: `my_macvlan`
- starts `balena-hello-world`:
  - helloworld nodejs application serving a webpage on port 80 and 8080
  - attached to both `my_macvlan` and `my_bridge` networks
- starts `balena-hello-controls`:
  - privileges container with `procfs` and `balena-socket` labels
  - no network
  - runs a script at start to :
    - find the PID of `balena-hello-world`
    - enter the network namespace of `balena-hello-world` using it's PID
    - find which network interface is on the 10.0.10.0 network
    - set iptablest to ALLOW port 8080 on that interface and DROP everything else

Here's the tests performed on the setup and which confirms hypothesis: 
  - connect from another vlan to the container address (i.e. 10.0.0.3) on port 80 -> denied
  - connect from another vlan to the container address (i.e. 10.0.0.3) on port 8080 -> denied
  - connect from vlan10 to the container address (i.e. 10.0.0.3) on port 80 -> denied
  - connect from vlan10 to the container address (i.e. 10.0.0.3) on port 8080 -> allowed
  - connect from the same network as the host to the host address (i.e. 192.168.1.101) on port 8080 -> allowed
  - connect from the same network as the host to the host address (i.e. 192.168.1.101) on port 80 -> allowed
  - connect from the internet using balena-cloud `public_url` -> allowed
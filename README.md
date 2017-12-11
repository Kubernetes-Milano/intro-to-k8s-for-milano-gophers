# Towards Cloud Native con Kubernetes: i primi passi

This repository contains the files for creating an environment 
used during a hands-on meetup, in collaboration with 
the group "Golang Milano".

Meetup.com event URL: [Golang meetup web page](https://www.meetup.com/Golang-Milano/events/245185761/).

---

## Prerequisites

Before being able to practice with the exercises, you need 
to install the following bits of software into your working machine. 

**N.B. Is highly recommended the use of a Linux machine.**

- **Make**: GNU Make 4.2.1, at least;

- **Virtualbox**: Oracle VM VirtualBox Manager 5.0, at least;

- **Git**: git version 2.13;

- **Packer**:  v1.0, at least;

All the binaries MUST be properly set in your **path**. 


The command for exporting a path is:

```bash

export PATH="${PATH}:/your-path-here-to-packer-binary-for-example"

```

--- 


## Installation 

For the creation of the Kubernetes environment, follow the 
next steps.

The results of this build is virtual machine with a ready to use 
single node Kubernetes cluster.



### The context

You have to clone this repository. Use the following command: 

```bash

git clone ....


```

From the root of the repository, you will see the following files and directories:

```bash 
.
├── files
│   ├── daemon-json.sh
│   ├── k8s.conf
│   ├── kubernetes-repo.sh
│   └── motd
├── http
│   └── ks.cfg
├── iso
├── Makefile
├── provisioners
│   └── ansible
│       └── playbooks
│           └── main.yaml
├── README.md
└── template.json

```
At this point, go to the next session and build the Virtual Machine.

### Build the VM image


To start the building, assuming that all the software packages are
correctly installed, the paths are exported, execute the command:

```bash
# This command will use Packer, from HashiCorp. 
# To learn more, visit the documentation page:
# **https://www.packer.io/docs/index.html**
source .env
make build

```

### What to do when Packer completes

At the moment Packer completes, import the created image into Virtualbox.
Then, set the port-forwarding as an additional rule to the 
default NAT created network. 

***N.B***
The destination port MUST be the integer 22.  
As source port use one that is not conflicting 
with the existing exposed ports on your local machine.

### How to log in the running Virtual Machine?

After configured the NAT port-forwarding, you can use the 
the following credentials to log in the machine:

```bash

# Username: root
# Password: changeme
export EXPOSED_PORT="2222"; ssh root@localhost -p ${EXPOSED_PORT}

```
**As soon as possibile, following the first login 
change the root user password and optionally add your 
SSH key to the system.**

## References

In this section, you will find some of good to have a look references:

- [Packer documentation](https://www.packer.io/docs/index.html);

- [VirtualBox documentation](https://www.virtualbox.org/wiki/Documentation);

    - [1.14. Importing and exporting virtual machines](https://www.virtualbox.org/manual/ch01.html#configbasics);
    
    - [6.3.1. Configuring port forwarding with NAT](https://www.virtualbox.org/manual/ch06.html#natforward);
    
- [Docker documentation](https://docs.docker.com/v17.03/);

    - [How to create a container with a Dockerfile](https://docs.docker.com/v17.03/get-started/part2/#define-a-container-with-a-dockerfile);
    
    - [Docker for beginners](https://docker-curriculum.com/);
    
- [Kubernetes documentation](https://kubernetes.io/docs/home/);

    - [How to create a stateless app through using a Deployment YAML manifest](https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/).

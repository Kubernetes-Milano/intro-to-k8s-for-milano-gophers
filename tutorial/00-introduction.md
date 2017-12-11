# Introduction

You are here to start experimenting with Kubernetes. This is
a powerful tool and it requires time for being well understood.
As the Kubernetes project continuously evolves, a complete comprehension
requires full dedication.

The best approach for learning Kubernetes is starting with easy things.
At the beginning, it is most useful to understand and know the objects of
core part of Kubernetes. After that, with one step at a time you will deep dive
into Kubernetes details. For example, you will install it, configure and
personalize the orchestration system to satisfy your needs.

In the following sections you will find references about how to proceed
in this practical introductory session with Kubernetes; starting with
some considerations about the creation of a container to its final
manifest specification and deployment in K8s system.

## How to create a private Docker Container Registry

As the first step let's create a DCR for saving the
freshly created by ourself a Docker image. Indeed, building Docker
images and creating container is not enough. We have to save them
for all the future references in our deployments.

At this moment log in the system (virtual machine) using your
credentials and instantiate a Docker Container Registry (DCR).

The DCR will be installed with basic configuration details.
Here the purpose is not configuration of the tool. The focus here
is to clear what are the parts involved into the main ops process.

```bash

mkdir -p /opt/dcr/registry

docker run -d -p 6000:5000 \
       --restart=always \
       --name registry \
       -v /opt/dcr/registry:/var/lib/registry \
       registry:2

```

### Test the registry

To create the DCR server we used a container image `registry:2`.
This image in first place is downloaded by Docker locally. And as
soon as possible is instantiated to create a running container.

At this moment, let's download an image from Docker Hub, for example,
and then push it to our newly create registry named `registry`.

```bash
# 1. Pull Nginx container image

docker pull nginx:alpine

#2. Tag the downloaded image, this is necessary for being
#   able to push the image to the local private registry

docker tag nginx:alpine localhost:6000/nginx

#3. Push the software container image to the previously create DCR

docker push localhost:6000/nginx

#4. Clean the garbage

docker image remove nginx:alpine
docker image remove localhost:6000/nginx:alpine


#5. Pull the image from your private registry

docker pull localhost:6000/nginx:alpine

# If the pulling task started you are done!

```

### What about DCR on different cloud providers?

Try to think about running a private registry on cloud
providers like AWS, Azure and Google Cloud Platform.

Happy Kubesting!

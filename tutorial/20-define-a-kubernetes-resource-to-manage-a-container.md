# Define a Kubernetes object that manages your container 

## (expected time ~20/30min)

Before continuing, verify that: you have a ready to use DCR and that 
you pushed your container to registry.

Once the image is saved inside the registry, continue.

### Namespaces

An important Kubernetes objects are the `[namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)`.

These improve the kubernetes cluster resource sharing and isolation.
For example, the same physical cluster can be used for testing, QA, 
and production environments.

By default if you do not specify explicitly a namespace the k8s system
will allocate all object to share the default namespace.

Another important namespace is that of `kube-system`. This namespace
is used by Kubernetes to allocate resources for cluster services.

Follows an example for namespace definition through a *ServiceAccount*
resource.

```yaml

apiVersion: v1
# This resource creates automatically a token
# The token is used for internal authentication and authorization
kind: ServiceAccount
metadata:
  namespace: elk-dev
  name: elasticsearch

```


### Services

Connectivity between components is an important feature. Kubernetes
services abstracts from IPs and makes possible to use mnemonic names
consistently around the all manifests.

```yaml
# This service exposes an ingress for Elasticsearch cluster
apiVersion: v1
kind: Service
metadata:
  namespace: elk-dev
  name: elasticsearch
  labels:
    component: elasticsearch
    role: client
spec:
  selector:
    component: elasticsearch
    role: client
  ports:
  - name: http
    port: 9200
    protocol: TCP

---

# This service implements the Elasticsearch masters
# service discovery and inter master node communication
apiVersion: v1
kind: Service
metadata:
  namespace: elk-dev
  name: elasticsearch-discovery
  labels:
    component: elasticsearch
    role: master
spec:
  selector:
    component: elasticsearch
    role: master
  ports:
  - name: transport
    port: 9300
    protocol: TCP


```

### ReplicationControllers

The most basic controller is that of ReplicationController.
Its main responsibility is to check that the desired number of container
instances for service are correctly running.

Below you will find all the ReplicationControllers for creating a
complete and self consistent Elasticsearch cluster. The model of the
cluster makes possible the horizontal scaling of all components.
(Elasticsearch offers different types of nodes: master, data and client)


```yaml

apiVersion: v1
kind: ReplicationController
metadata:
  name: es-master
  namespace: elk-dev
  labels:
    component: elasticsearch
    role: master
spec:
  replicas: 3
  template:
    metadata:
      labels:
        component: elasticsearch
        role: master
    spec:
      serviceAccount: elasticsearch
      containers:
      - name: es-master
        securityContext:
          capabilities:
            add:
              - IPC_LOCK
        image: es-k8s:0
        imagePullPolicy: IfNotPresent
        args: ["-Des.cluster.name=testing-cluster",
               "-Des.node.master=true",
               "-Des.node.data=false",
               "-Des.index.number_of_shards=1",
               "-Des.index.number_of_replicas=1",
               "-Des.bootstrap.mlockall='true'",
               "-Des.discovery.zen.ping.multicast.enabled='false'",
               "-Des.discovery.zen.minimum_master_nodes=3",
               "-Des.discovery.zen.master_election.ignore_non_master_pings='true'",
               "-Des.discovery.zen.no_master_block='write'",
               "-Des.gateway.recover_after_nodes=2",
               "-Des.gateway.expected_nodes=2",
               "-Des.gateway.recover_after_time=3m",
               "-Des.path.repo='/usr/share/elasticsearch/data/backups/'",
               "-Des.discovery.zen.ping.unicast.hosts=elasticsearch-discovery"]
        env:
        - name: KUBERNETES_CA_CERTIFICATE_FILE
          value: /var/run/secrets/kubernetes/kubelet.crt
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name:  MAX_LOCKED_MEMORY
          value: unlimited
        - name: ES_HEAP_SIZE
          value: 1g
        - name: ES_JAVA_OPTS 
          value: -Xms1g -Xmx1g
        ports:
        - containerPort: 9300
          name: transport
          protocol: TCP
        volumeMounts:
        - mountPath: /usr/share/elasticsearch/data
          name: nfs-es
      volumes:
        - name: nfs-es
          persistentVolumeClaim:
            claimName: nfs-es

---

apiVersion: v1
kind: ReplicationController
metadata:
  name: es-client
  namespace: elk-dev
  labels:
    component: elasticsearch
    role: client
spec:
  replicas: 1
  template:
    metadata:
      labels:
        component: elasticsearch
        role: client
    spec:
      serviceAccount: elasticsearch
      containers:
      - name: es-client
        securityContext:
          capabilities:
            add:
              - IPC_LOCK
        image: es-k8s:0
        imagePullPolicy: IfNotPresent
        args: ["-Des.cluster.name=testing-cluster",
               "-Des.node.master=false",
               "-Des.node.data=false",
               "-Des.index.number_of_shards=1",
               "-Des.index.number_of_replicas=1",
               "-Des.bootstrap.mlockall='true'",
               "-Des.discovery.zen.ping.multicast.enabled='false'",
               "-Des.discovery.zen.minimum_master_nodes=3",
               "-Des.discovery.zen.master_election.ignore_non_master_pings='true'",
               "-Des.discovery.zen.no_master_block='write'",
               "-Des.gateway.recover_after_nodes=2",
               "-Des.gateway.expected_nodes=2",
               "-Des.gateway.recover_after_time=3m",
               "-Des.path.repo='/usr/share/elasticsearch/data/backups/'", 
               "-Des.discovery.zen.ping.unicast.hosts=elasticsearch-discovery"] 
        env:
        - name: KUBERNETES_CA_CERTIFICATE_FILE
          value: /var/run/secrets/kubernetes/kubelet.crt
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name:  MAX_LOCKED_MEMORY
          value: unlimited
        - name: ES_HEAP_SIZE
          value: 1g
        - name: ES_JAVA_OPTS 
          value: -Xms1g -Xmx1g
        ports:
        - containerPort: 9200
          name: http
          protocol: TCP
        - containerPort: 9300
          name: transport
          protocol: TCP

--- 


apiVersion: v1
kind: ReplicationController
metadata:
  name: es-data
  namespace: elk-dev
  labels:
    component: elasticsearch
    role: data
spec:
  replicas: 1
  template:
    metadata:
      labels:
        component: elasticsearch
        role: data
    spec:
      serviceAccount: elasticsearch
      containers:
      - name: es-data
        securityContext:
          capabilities:
            add:
              - IPC_LOCK
        image: es-k8s:0
        resources:
          limits: 
            memory: 2Gi
          requests:
            memory: 2Gi
        imagePullPolicy: IfNotPresent
        args: ["-Des.cluster.name=testing-cluster",
               "-Des.node.master=true",
               "-Des.node.data=true",
               "-Des.index.number_of_shards=1",
               "-Des.index.number_of_replicas=1",
               "-Des.bootstrap.mlockall='true'",
               "-Des.discovery.zen.ping.multicast.enabled='false'",
               "-Des.discovery.zen.minimum_master_nodes=1",
               "-Des.discovery.zen.master_election.ignore_non_master_pings='true'",
               "-Des.discovery.zen.no_master_block=all",
               "-Des.gateway.recover_after_nodes=1",
               "-Des.gateway.expected_nodes=1",
               "-Des.gateway.recover_after_time=3m",
               "-Des.path.repo=/usr/share/",
               "-Des.discovery.zen.ping.unicast.hosts=elasticsearch-discovery"
           ]
        env:
        - name: KUBERNETES_CA_CERTIFICATE_FILE
          value: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        - name:  MAX_LOCKED_MEMORY
          value: unlimited
        - name: ES_HEAP_SIZE
          value: 1g
        - name: ES_JAVA_OPTS 
          value: -Xms2g -Xmx2g
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        ports:
        - containerPort: 9300
          name: transport
          protocol: TCP
        - containerPort: 9200
          name: http
          protocol: TCP
       volumeMounts:
        - mountPath: /usr/share/elasticsearch/data
          name: nfs-es
      volumes:
        - name: nfs-es
          persistentVolumeClaim:
            claimName: nfs-es

```

### Persistent Volumes

Ops in love with Kubernetes appreciate a lot the levels of abstraction
Kubernetes offers. In this section you can see how is possible 
to abstract from the the physical storage. In this case the storage type
is the good classic NFS service.


```yaml

apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: elk-dev
  name: nfs-es
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 192.168.100.22
    path: "/usr/share/elasticsearch/data"

```

### Persistent Volume Claims

Allocating all the data capacity to a working cluster is useless. 
Approach the cloud philosophy: demand something when you really need it.

Think about claims as logical volumes. They can grow up and down with ease.

N.B. In case of NFS take care about the total claiming size of data.
To provision big partitions on NFS can take very long time.

```yaml

kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  namespace: elk-dev
  name: nfs-es
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 2Gi

```

### Define the Kubernetes resources manifests for your example app

For starting to deal with Kubernetes resources may be useful to replicate
the up exposed manifests. Starting from there, create your manifests
for your own container ready for orchestration with Kubernetes.

Happy Kubesting!
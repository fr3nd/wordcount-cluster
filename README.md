# Wordcount in Docker swarm

## Objective

Given a *large* text file containing text lines in any real world language, use *docker-machine* to spin up hosts running a number of containers that process the input file in a distributed way using a map-reduce algorithm. 

The objective is to count the number of appearances of each word in the given input file, ideally ordered by number of appearances.

## Requirements

* [Docker](http://www.docker.com/)
* [Docker Machine](https://docs.docker.com/machine/)
* [GNU parallel](https://www.gnu.org/software/parallel/)

The current solution has been tested on Ubuntu 15.10, using Docker 1.11.2, Docker Machine 0.7.0 and GNU Parallel 20141022. Other software versions will probably work too.

## Solution

To solve this problem I've prioritized simplicity over a fully featured solution. One of reasons why I adopted this approach is the lack of a good Internet connection on my current location. 

I've decided to use [Docker Swarm](https://www.docker.com/products/docker-swarm) as a clustering solution because of its simplicity, the integration with Docker and easy of use. The initial problem didn't require other more complex solutions with more features.

The *map-reduce* wordcount program has been written in python and it has its own github repository and Docker Hub automated build:

* https://github.com/fr3nd/wordcount
* https://hub.docker.com/r/fr3nd/wordcount/

The cluster creation and cluster destroy scripts have been created in Bash. Some *glue* components and the *wordcount* script have been written in Bash too.

GNU Parallel is used to allow parallel launch of the wordcount processes in the cluster. 

GNU Split is used to split the input files into smaller pieces so they can be processed in parallel for the different map processes.

For testing purposes I've used a total  of 13 classic English books from [Project Gutenberg](https://www.gutenberg.org/)

## How to use it

### Cluster creation

First of all the cluster needs to be created and initialized. To simplify this operation, the script `start-cluster.sh` is provided. This script does the following:

1. Check for initial requirements
2. Using Docker Machine, create the Swarm manager node
3. Using Docker Machine, create all Swarm worker nodes and connect them to the manager
4. Download the fr3nd/wordcount Docker image in every worker node

### Wordcount

`wordcount.sh` script to inject the text files to the cluster to start processing them. It reads from *STDIN* the text to be processed and it sends it to the cluster:

1. Check for initial requirements
2. Split text into smaller chunks of data (defined in SPLIT_LINES)
3. Send in parallel the splitted data to the cluster. Each chunk of text will be sent to a random cluster node to be processed by the map.py python program. There will be a maximum of MAX_MAP_PROCS processes.
4. All the combined outputs from the map.py will be sorted.
5. The sorted output will be passed to a different process executing the reduce.py python script.
6. The final output will be sorted by number of appearances.

### Cluster destroy

A `stop-cluster.sh` script to destroy the cluster is also provided.

1. Remove the Docker Swarm manager node
2. Remove all Docker Swarm worker nodes

### Config

A simple config file is provided where some parameters can be tweaked to adapt the execution to different environments:

```
# Number of workers in the cluster
WORKERS=2
# Number of map processes in the cluster
MAX_MAP_PROCS=4
# get a new token with docker run --rm swarm create
SWARM_TOKEN=2f4ba1c163c0907679f037cd2d85e49e
# Driver to be used on docker machine
DOCKER_MACHINE_DRIVER=virtualbox
# Split files every SPLIT_LINES lines
SPLIT_LINES=20000
```

## Example execution

### Cluster creation

```
 $ ./start-cluster.sh
*** Creating Swarm manager...
Running pre-create checks...
Creating machine...
(manager) Copying /home/fr3nd/.docker/machine/cache/boot2docker.iso to /home/fr3nd/.docker/machine/machines/manager/boot2docker.iso...
(manager) Creating VirtualBox VM...
(manager) Creating SSH key...
(manager) Starting the VM...
(manager) Check network to re-create if needed...
(manager) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env manager
*** Configuring Swarm manager...
Unable to find image 'swarm:latest' locally
latest: Pulling from library/swarm
1e61bbec5d24: Pull complete
8c7b2f6b74da: Pull complete
245a8db4f1e1: Pull complete
Digest: sha256:661f2e4c9470e7f6238cebf603bcf5700c8b948894ac9e35f2cf6f63dcda723a
Status: Downloaded newer image for swarm:latest
1e376454893ab3323529d65d7e25304bb695ce5219431f34dbeff5ea889cfc2f
*** Creating Swarm worker1...
Running pre-create checks...
Creating machine...
(worker1) Copying /home/fr3nd/.docker/machine/cache/boot2docker.iso to /home/fr3nd/.docker/machine/machines/worker1/boot2docker.iso...
(worker1) Creating VirtualBox VM...
(worker1) Creating SSH key...
(worker1) Starting the VM...
(worker1) Check network to re-create if needed...
(worker1) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env worker1
*** Configuring Swarm worker1...
Unable to find image 'swarm:latest' locally
latest: Pulling from library/swarm
1e61bbec5d24: Pull complete
8c7b2f6b74da: Pull complete
245a8db4f1e1: Pull complete
Digest: sha256:661f2e4c9470e7f6238cebf603bcf5700c8b948894ac9e35f2cf6f63dcda723a
Status: Downloaded newer image for swarm:latest
59220ed6cffbaf313b02aa83e94ce622bcac0e6450292001b02edef07b9f6779
*** Creating Swarm worker2...
Running pre-create checks...
Creating machine...
(worker2) Copying /home/fr3nd/.docker/machine/cache/boot2docker.iso to /home/fr3nd/.docker/machine/machines/worker2/boot2docker.iso...
(worker2) Creating VirtualBox VM...
(worker2) Creating SSH key...
(worker2) Starting the VM...
(worker2) Check network to re-create if needed...
(worker2) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env worker2
*** Configuring Swarm worker2...
Unable to find image 'swarm:latest' locally
latest: Pulling from library/swarm
1e61bbec5d24: Pull complete
8c7b2f6b74da: Pull complete
245a8db4f1e1: Pull complete
Digest: sha256:661f2e4c9470e7f6238cebf603bcf5700c8b948894ac9e35f2cf6f63dcda723a
Status: Downloaded newer image for swarm:latest
4e5ed8b0eb0e8f461cff01e067cc1b2212a6f049ef6fc401134dcda5f1f1fe3e
worker2: Pulling fr3nd/wordcount:latest... : downloaded
worker1: Pulling fr3nd/wordcount:latest... : downloaded
```

### Wordcount

```
$ cat books/* | ./wordcount.sh | head
the 73725
and 49674
of 37386
to 37038
a 28291
i 25537
in 22682
it 17850
that 17547
was 16828
```

### Cluster destroy

```
$  ./stop-cluster.sh
*** Removing Swarm manager...
About to remove manager
Successfully removed manager
*** Removing Swarm worker1...
About to remove worker1
Successfully removed worker1
*** Removing Swarm worker2...
About to remove worker2
Successfully removed worker2
```
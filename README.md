## Joblib in the cloud demo setup

### Useful links

* [docker-distributed](https://github.com/ogrisel/docker-distributed)
* [carina-rackspace](https://getcarina.com/docs/)


### Carina installation steps

* Create an account on Carina
* Download the carina CLI tool following
[this page](https://getcarina.com/docs/getting-started/getting-started-carina-cli/):
```
$ mkdir ~/carina
$ cd ~/carina
$ curl -L https://download.getcarina.com/carina/latest/$(uname -s)/$(uname
-m)/carina -o carina
$ chmod u+x carina
```
* Add the following lines to your environment `~/.bashrc` for carina usage:
```
export PATH=~/carina:$PATH
export CARINA_USERNAME=<your_email>
export CARINA_APIKEY=<your_apikey>
```
The API key can be retrieved from the account management on the web interface.
Reload the environment file:
```
$ . ~/.bashrc
```
* Create a cluster (this can take a moment):
```
$ carina create --wait joblibCluster
ClusterName         Flavor              Nodes               AutoScale           Status
joblibCluster       container1-4G       1                   false               active
```
* Check the cluster was successfuly created:
```
$ carina ls
```
* One can follow the create of the cluster the following url:
https://app.getcarina.com/app/clusters
* If the cluster creation succeeded, connect to the cluster:
```
$ eval $(carina env joblibCluster)
```

### Docker Version Manager installation (dvm)

* Download the dvm:
```
$ curl -sL https://download.getcarina.com/dvm/latest/install.sh | sh
```
* Then add the following to your `~/.bashrc`:
```
source /home/aabadie/.dvm/dvm.sh
```
* Reload your environment:
```
$ . ~/.bashrc
```
* Configure the docker client:
```
$ dvm use
```
* Check the docker container running on the cluster just created:
```
$ docker info
```

### Configure parallel application

* Install docker compose:
```
$ pip install docker-compose
```
* Start container
```
$ docker run --rm -ti ubuntu bash
```
* List available docker containers:
```
$ docker ps
```
* Run bash in existing container (identified by <name>)
```
$ docker exec --rm -ti <name> bash
```
* Docker images


### Ipyparallel example

Start ipcluster with n workers
```
$ ipcluster start --n 5
```

```python
import time
from ipyparallel import Client
from ipyparallel.joblib import register
from joblib import parallel_backend, Parallel, delayed

# Setup ipyparallel backend
register()
dview = Client()[:]
# Start the job
with parallel_backend("ipyparallel", view=dview):
    Parallel(n_jobs=20, verbose=50)(delayed(time.sleep)(1) for i in range(10))
```


















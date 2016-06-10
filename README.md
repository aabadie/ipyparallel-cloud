## Joblib with ipyparallel parallel backend

This demo is based on the following tools:
* [joblib](https://pythonhosted.org/joblib/)
* Parallel backend of joblib is based on
[ipyparallel](https://ipyparallel.readthedocs.io/en/latest/)
* [Carina](https://getcarina.com/) hosts the cloud
* Applications run in [Docker](https://www.docker.com/) containers thanks to
  [docker-compose](https://docs.docker.com/compose/)
* Examples are based on [Scikit-Learn](http://scikit-learn.org/stable/)


### Local ipyparallel setup

1 .Start ipcluster with n workers
```
$ ipcluster start --n 5
```
2. Run the following script
```python
import time
from ipyparallel import Client
from ipyparallel.joblib import register
from joblib import parallel_backend, Parallel, delayed

# Setup ipyparallel backend
register()
# Start the job
with parallel_backend("ipyparallel"):
    Parallel(n_jobs=20, verbose=50)(delayed(time.sleep)(1) for i in range(10))
```

### ipyparallel in the cloud setup

The setup is based on [Carina](https://getcarina.com/) cloud provider and
[Docker](https://www.docker.com/) application containers.

#### Carina installation steps

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

#### Docker Version Manager installation (dvm)

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

#### Install remaining required packages

* Docker compose:
```
$ pip install docker-compose
```

* This repository
```
$ git clone https://github.com/aabadie/ipyparallel-cloud
```

#### Start the demo

* Create a cluster (this can take a moment):
```
$ carina create --wait joblib-cluster
ClusterName         Flavor              Nodes               AutoScale           Status
joblib-cluster       container1-4G       1                   false               active
```
* Check the cluster was successfuly created:
```
$ carina ls
```
* One can follow the create of the cluster the following url:
https://app.getcarina.com/app/clusters
* If the cluster creation succeeded, connect to the cluster:
```
$ eval $(carina env joblib-cluster)
```

* Configure the docker client:
```
$ dvm use
```
* Check the docker container running on the cluster just created:
```
$ docker info
```

* Start the containers
```
$ docker-compose up -d
$ docker-compose scale engine=2
```

* Check the IP of the notebook container using:
```
$ docker ps
```

* When it will work, I hope the notebook will be available at
__http://\[notebook_url\]:8000__

#### Clean-up everything when done

```
$ docker-compose down
$ carina rm joblib-cluster
$ dvm deactivate
```

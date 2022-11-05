# Usage of ArgoCD Image Updater Scaler

## Document explains usage of CronJob which will do Scale Up or Scale Down for specific release time

#### The code structure looks like as following

* manifests
    * `sclaer-manifest.yaml` - File contains, `ServiceAccount`, `ClusterRole`, `ClusterRoleBinding` and `CronJob` kubernetes objects. CronJob `argoimagescaler` object will deploy `us-central1-docker.pkg.dev/company-images/company/argoimagescaler` docker image (Image can be created from `Dockerfile` file) to kubernetes with `scheduled-autoscaler-service-account` service account. With this service account it will get access to `argocd` namespace with grant to execute `kubectl scale deployment` command.
    * `secret.yaml` - File contains `Secret` object with 4 keys which will be like as argument for `scaler.sh` script. By names we can understand what these keys will do. `SCALE_DOWN_POD_COUNT` is integer for scale down arogcd image updater deployment (Default is `0`). `SCALE_UP_POD_COUNT` is integer for scale up arogcd image updater deployment (Default is `1`). `SCALE_UP_TIME` (Default value by `24` hours time range in `EST` is `09`) and `SCALE_DOWN_TIME` (Default value by `24` hours time range in `EST` is `16`) variables defines release time range for ArgoCD Image updater.
* `Dockerfile` - From this file we can create image and push to some registry (Like as entrypoint will be executed `./scaler.sh` script with arguments from environment variables). Create image will be used by `sclaer-manifest.yaml` file inside of `CronJob` object. Image get these environment variables `SCALE_DOWN_POD_COUNT`, `SCALE_UP_POD_COUNT`, `SCALE_UP_TIME` and `SCALE_DOWN_TIME`. `CronJob` will override these environment variables from `secret.yaml` file. 
* `scaler.sh` - Script get 4 arguments to comare time range and do scale up or scale down of `argocd-image-updater` deployment inside of the `argocd` namespace

#### We can create, push and apply manifests with the following commands

```bash
$ export image_with_version='us-central1-docker.pkg.dev/company-images/company/argoimagescaler:v22'
$ docker build -t $image_with_version . && docker push $image_with_version
$ kubectl apply -f manifests/secret.yaml
$ cat manifests/scaler-manifest.yaml | envsubst > scaler-manifest.yaml
$ kubectl apply -f scaler-manifest.yaml && rm -rf scaler-manifest.yaml
```

**Note:** Don't forget change base64 encoded values inside of the `manifests/secret.yaml` file to your own `date/time` and scale `Up/Down` count needs.

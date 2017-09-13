# csi-local-volume-release
CSI local Volume Release for Cloud Foundry that follows protocol specified by Container Storage Interface, it packages a [csi-localdriver](https://github.com/jeffpak/local-node-plugin/tree/bd75d5f64c8ab6cd351d190451ecd2685df71ba), a [csi-localcontroller](https://github.com/jeffpak/local-controller-plugin/tree/f4d1f789816da1690f440b23444653b3ee9d3702) and a [csi-broker](https://github.com/cloudfoundry/csibroker) for consumption by a volman-enabled Cloud Foundry deployment.

# Deploying to Bosh-Lite

## Pre-requisites

1. Install and start [BOSH-Lite](https://github.com/cloudfoundry/bosh-lite), following its [document](https://bosh.io/docs/bosh-lite).

2. Install bosh v2 according to this [document](https://bosh.io/docs/cli-v2.html).

## Deploy csi-local-volume-release using cf-deployment

1. Get cf-deployment, setup cloud-config and upload stemcell.

```bash
cd ~/workspace/
git clone https://github.com/cloudfoundry/cf-deployment.git
cd cf-deployment
bosh -e vbox update-cloud-config ./bosh-lite/cloud-config.yml
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
```

2. Get csi-local-volume-release, create a bosh release and upload it.

```bash
cd ~/workspace/
git clone https://github.com/cloudfoundry/csi-local-volume-release.git
cd csi-local-volume-release
bosh create-release
bosh -e vbox upload-release
```

3. Deploy csi-local-volume-release with cf

```bash
cd ~/workspace/
bosh -e vbox -d cf deploy ./cf-deployment/cf-deployment.yml --vars-store ./cf-deployment/deployment-vars.yml -o ./operations/enable-csi-local-plugin-bosh-lite.yml -v system_domain=bosh-lite.com
```

## Register local-broker

```bash
cd ~/workspace/cf-deployment
# login with cf
cf_password=`cat deployment-vars.yml |grep cf_admin_password|awk '{print $2}'`
cf api api.bosh-lite.com
cf auth admin ${cf_password}

# optionaly delete previous broker:
cf delete-service-broker csilocalfs-broker
broker_password=`cat deployment-vars.yml |grep csi-localbroker-password|awk '{print $2}'`
cf create-service-broker csilocalfs-broker csi-localbroker ${broker_password} http://csi-localbroker.bosh-lite.com
cf enable-service-access csilocalfs-broker
```

## Deploy pora and test volume services

```bash
cd ~/workspace/csi-local-volume-release
pushd ./src/code.cloudfoundry.org/persi-acceptance-tests/
cf create-service csilocalfs free pora-volume-instance -c {"name":"csi-local-storage","volume_capabilities":[{"mount":{}}]} 
cf push pora -f ./assets/pora/manifest.yml -p ./assets/pora/ --no-start

cf bind-service pora pora-volume-instance
cf start pora
popd
```

> ####Bind Parameters####
> * **mount:** By default, volumes are mounted into the application container in an arbitrarily named folder under /var/vcap/data.  If you prefer to mount your directory to some specific path where your application expects it, you can control the container mount path by specifying the `mount` option.  The resulting bind command would look something like 
> ``` cf bind-service pora pora-volume-instance -c '{"mount":"/my/path"}'```

# Troubleshooting
If you have trouble getting this release to operate properly, try consulting the [Volume Services Troubleshooting Page](https://github.com/cloudfoundry-incubator/volman/blob/master/TROUBLESHOOTING.md)

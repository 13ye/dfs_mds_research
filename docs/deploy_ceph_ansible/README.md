# deploy ceph by ansible

## About docker registry
start a docker registry locally
[doc](https://docs.docker.com/registry/)
```bash
myip=192.168.5.172
docker run -d -p 5000:5000 --restart=always --name registry registry:2
docker image tag ub_ceph_prod:v17.1.0 $myip:5000/ceph/ub_ceph:v17.1.0
docker push $myip:5000/ceph/ub_ceph:v17.1.0
```

### set insecure registry for nodes would like to pull images from the registry
[doc](https://docs.docker.com/registry/insecure/)
```
#edit /etc/docker/daemon.json add:'"insecure-registries" : ["192.168.5.172:5000"],', and restart docker service
systemctl daemon-reload
systemctl restart docker
```

### test pull from another node
`docker pull $myip:5000/ceph/ub_ceph:v17.1.0`


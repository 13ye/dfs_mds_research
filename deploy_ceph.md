## cephadm
[doc](https://docs.ceph.com/en/latest/cephadm/install/#cephadm-deployment-scenarios)
*Remember to replace the version to v17.1.0 as below*
`curl --silent --remote-name --location https://github.com/ceph/ceph/raw/v17.1.0/src/cephadm/cephadm`

## build ceph inside container ubuntu_20
# ceph can be mannually built in docker as follows
```bash
docker run -itd --name ub_ceph --network=host ubuntu:20.04
docker exec -it ub_ceph /bin/bash
apt update && apt -y install sudo git
git clone https://github.com/ceph/ceph -b v17.1.0 ceph_17
cd ceph && git submodule update --init --recursive
./install-deps.sh
# then build
./do_cmake.sh #-DCMAKE_BUILD_TYPE=RelWithDebInfo
cd build
# may take 2hours with good network, if stuck by npm, try
# `build/src/pybind/mgr/dashboard/frontend/node-env/bin/npm config registry ...`
time ninja -j32
ninja install
export PYTHONPATH=/usr/local/lib/python3.8/dist-packages/:/usr/local/lib/python3/dist-packages/:$PYTHONPATH
```



## start mon
[doc](https://docs.ceph.com/en/latest/cephadm/install/#deployment-in-an-isolated-environment)
```bash
docker run -d -p 5000:5000 --restart=always --name registry registry:2
# first build container ub_ceph, which has built and installed ceph v17.1.0
docker run -itd --name ub_ceph_1 --network=host ub_ceph:v17.1.0
cephadm --image 192.168.5.172:5000/ceph/ceph bootstrap --mon-ip 192.168.5.172
```


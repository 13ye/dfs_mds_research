## mannaully install
[doc](https://docs.ceph.com/en/latest/install/manual-deployment/)

## build ceph inside container ubuntu_20
ceph can be mannually built in docker as follows
- [] TODO: Dockerfile for ceph_17
```bash
docker run -itd --name ub_ceph --network=host ubuntu:20.04
docker exec -it ub_ceph /bin/bash
git clone https://github.com/ceph/ceph -b v17.1.0 ceph_17
cd ceph_17 && git submodule update --init --recursive
# change to tsinghua source
apt update
./install-deps.sh
# then build
./do_cmake.sh -DCMAKE_BUILD_TYPE=RelWithDebInfo
cd build
# may take 0.5hours with good network(npm registry), if stuck by npm, try
# `build/src/pybind/mgr/dashboard/frontend/node-env/bin/npm config registry ...`
time ninja -j32
ninja install
export PYTHONPATH=/usr/local/lib/python3.8/dist-packages/:/usr/local/lib/python3/dist-packages/:$PYTHONPATH
```

## start mon
refer to: [start_mon.md](./start_mon.md)

## deploy osd
refer to: [prepare_osd.md](./prepare_osd.md)

## add mds
refer to: [add_mds.md](./add_mds.md)

## mount fs
refer to: [mount_fs.md](./mount_fs.md)

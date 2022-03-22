# Test Small File Access Ops For **FUSE POSIX DFS**

Machine Configuration: ubuntu18.04.5LTS64C128GB2TBNVMe1000Mbits

1. [seaweedfs](https://github.com/chrislusf/seaweedfs) refer to [filer_doc](https://github.com/chrislusf/seaweedfs/wiki/Directories-and-Files)
2. [ceph](https://github.com/ceph/ceph) [ceph_fs_doc](https://docs.ceph.com/en/latest/install/manual-deployment/)

prepare weed and ceph respectively:
1. prepare weed binary: `wget https://github.com/chrislusf/seaweedfs/releases/download/2.95/linux_amd64.tar.gz -O weed_linux_amd64.tar.gz && tar -C /usr/local/bin/ -vxzf weed_linux_amd64.tar.gz`
2. prepare ceph: ceph release size is huge (library>20GB, binary>20GB), can mannually build in docker as follows:
```bash
docker run -itd --name ub_ceph ubuntu:18.04
docker exec -it ub_ceph /bin/bash
git clone https://github.com/ceph/ceph -b v17.1.0
cd ceph && git submodule update --init --recursive
./install-deps.sh
# then build
./do_cmake.sh
cd build
# may take 2hours with good network
ninja -j 8
# then install:
ninja install
```


## weed test
```bash
mkdir -p /tmp/weed_vol1
weed server -dir=/tmp/weed_vol1 -filer -volume
# take this node ip as 192.168.15.172
export ip_weed="192.168.15.172"
# change to another physics node!!! test connection
echo "123abcd" > file_1 && curl -F "filename=@file_1" "http://$ip_weed:8888/path/to/sources/"
curl "http://$ip_weed:8888/path/to/sources/file_1"
# mount fs folder as filesystem
mkdir -p /tmp/weed_mnt1
weed mount -filer=$ip_weed:8888 -dir=/tmp/weed_mnt1
# then you can use mounted path as local fileSystem
cp ./oper_files.sh /tmp/weed_mnt1
cd /tmp/weed_mnt1
time ./oper_files.sh write
time ./oper_files.sh lsstat
time ./oper_files.sh du_sh
time ./oper_files.sh read
time ./oper_files.sh remove
```
result:
----------------------------
| dfs | iter | item | time |
----------------------------
| seaweedfs | 262144 | write| 0.0s |
----------------------------



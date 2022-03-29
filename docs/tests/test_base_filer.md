# Test Small File Access Ops For **FUSE POSIX DFS**

Machine Configuration: ubuntu18.04.5LTS64C128GB2TBNVMe1000Mbits

1. [seaweedfs](https://github.com/chrislusf/seaweedfs) refer to [filer_doc](https://github.com/chrislusf/seaweedfs/wiki/Directories-and-Files)
2. [ceph](https://github.com/ceph/ceph) refer to [ceph_fs_doc](https://docs.ceph.com/en/latest/install/manual-deployment/)
3. TODO: [miniofs](https://github.com/minio/minfs) refer to

prepare weed and ceph respectively:
1. prepare weed binary: `curl -L https://github.com/chrislusf/seaweedfs/releases/download/2.95/linux_amd64.tar.gz -o weed_linux_amd64.tar.gz && tar -C /usr/local/bin/ -vxzf weed_linux_amd64.tar.gz`
2. prepare ceph: ceph release size is huge (library>10GB, binary>20GB), deploy as: [deploy ceph](../deploy_ceph/deploy_ceph.md)

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
cp ./scripts/oper_files.sh /tmp/weed_mnt1
cd /tmp/weed_mnt1
time ./oper_files.sh write
time ./oper_files.sh lsstat
time ./oper_files.sh du_sh
time ./oper_files.sh read
time ./oper_files.sh remove
```
bench result:
|    dfs    |  iter  | item | time |
|-----------|--------|------|------|
| seaweedfs | 262144 | write | 13min25.80s |
| seaweedfs | 262144 | lsstat | 51.686s |
| seaweedfs | 262144 | du_sh | 25.072s |
| seaweedfs | 262144 | read | 6min3.31s |
| seaweedfs | 262144 | remove | 5.307s |

## local test
```bash
mkdir -p /tmp/local_mnt1
cp ./scripts/oper_files.sh /tmp/local_mnt1
cd /tmp/local_mnt1
time ./oper_files.sh write
time ./oper_files.sh lsstat
time ./oper_files.sh du_sh
time ./oper_files.sh read
time ./oper_files.sh remove
```
bench result:
|    dfs    |  iter  | item | time |
|-----------|--------|------|------|
| local | 262144 | write | 6.995s |
| local | 262144 | lsstat | 1.621s |
| local | 262144 | du_sh | 0.467s |
| local | 262144 | read | 1.529s |
| local | 262144 | remove | 1.396s |


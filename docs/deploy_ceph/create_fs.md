# create ceph fs docs
[doc](https://docs.ceph.com/en/latest/cephfs/createfs/)

## in monitor-1
```bash
docker exec -it ceph_mon1 /bin/zsh
ceph osd pool create cephfs_data 8 8
ceph osd pool create cephfs_metadata 8 8
ceph fs new ceph_fs1 cephfs_metadata cephfs_data
```

## check fs created
`ceph fs ls`
`ceph mds stat`

## using FUSE to mount
```bash
# create user name foo of all access
# sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.foo.keyring --gen-key -n client.foo --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
# using client.admin, because of permission management
ceph-fuse -n client.admin -m 192.168.5.172:6789 /mnt/mycephfs --keyring /etc/ceph/ceph.client.admin.keyring2  -c /etc/ceph/ceph.conf2
```

## mount fs where has installed ceph
```bash
# mount -t ceph {device-string}={path-to-mounted} {mount-point} -o {key-value-args} {other-args}
# cephuser and secret is cephx, can get admin user by `ceph auth get client.admin`
# `ceph fsid` to get fsid
mount.ceph admin@0f615ea4-439f-44ba-a3e9-39da8dbc45da.ceph_fs1=/ /mnt/mycephfs -o mon_addr=192.168.5.172:6789,secret=AQAZVz1i9PYWHxAAz0/GgjKTpHO5/xOu/gSj5A==
```


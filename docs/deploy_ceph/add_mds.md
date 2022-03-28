## on monitor first
```
docker exec -it ceph_mon1 /bin/zsh
```

## create mds data dir
```bash
id="mds2"
cluster="ceph"
mkdir -p /var/lib/ceph/mds/$cluster-$id
ceph-authtool --create-keyring /var/lib/ceph/mds/$cluster-$id/keyring --gen-key -n mds.$id
ceph auth add mds.$id osd "allow rwx" mds "allow *" mon "allow profile mds" -i /var/lib/ceph/mds/$cluster-$id/keyring
## append to ceph.conf:
cat << EOF >> /etc/ceph/ceph.conf
[mds.$id]
host = $id
EOF
```

# inside container which already install ceph
```bash
## change to mds container
docker run -itd --name=ceph_mds2 --network=host ub_ceph_prod:v17.1.0
docker exec -it ceph_mds2 /bin/zsh
id="mds2"
cluster="ceph"
mkdir -p /var/lib/ceph/mds/$cluster-$id
adduser ceph
chown -R ceph:ceph /var/lib/ceph/
ceph-mds --cluster $cluster -i $id -m 192.168.5.172:6789 -d
```

## verify mds on monitor:
`ceph mds stat`
`ceph fs dump`


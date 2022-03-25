# inside container which already install ceph
```bash
docker run -itd --name=ceph_mds1 --network=host ub_ceph_prod:v17.1.0
docker exec -it ceph_mds1 /bin/zsh
```

## create mds data dir
```bash
id="mds1"
cluster="ceph"
mkdir -p /var/lib/ceph/mds/$cluster-$id
```

## create keyring
```bash
ceph-authtool --create-keyring /var/lib/ceph/mds/$cluster-$id/keyring --gen-key -n mds.$id
ceph auth add mds.$id osd "allow rwx" mds "allow *" mon "allow profile mds" -i /var/lib/ceph/mds/$cluster-$id/keyring
```

## create a ceph.conf and add:
[mds.{id}]
host = {id}

## start mds:
```bash
# ceph-mds --cluster ceph -i $id -m {mon-node1-ip}:{mon-port}
ceph-mds --cluster ceph -i $id -m 192.168.5.172:6789
```

## verify mds on monitor:
`ceph fs dump`

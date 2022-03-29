## prepare storage device
parted device from NVMe /dev/sdb: "/dev/sdb1/" "/dev/sdb2/" "/dev/sdb3/" "/dev/sdb4/"

# inside container which already install ceph
```bash
docker run -itd --name=ceph_osd1 --privileged --network=host ub_ceph_prod:v17.1.0
docker run -itd --name=ceph_osd2 --privileged --network=host ub_ceph_prod:v17.1.0
docker exec -it ceph_osd1 /bin/zsh
```

## prepare keyring
1. copy /var/lib/ceph/bootstrap-osd/ceph.keyring from monitor node (mon-node1) to /etc/ceph/ceph.keyring on osd node (osd-node1)
2. copy /etc/ceph/ceph.conf from monitor node (mon-node1) to /etc/ceph/ceph.conf on osd node (osd-node1)

## prepare&avtivate filestore osd (fail in container)
```bash
# sudo ceph-volume lvm create --filestore --data /dev/sdb1 --journal /dev/sdb2
# sudo ceph-volume lvm list
```

## if failed above, do as follows to start an osd
```bash
DEV="sdb1"
UUID=$(uuidgen)
OSD_SECRET=$(ceph-authtool --gen-print-key)
ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | \
   ceph osd new $UUID -i - \
   -n client.bootstrap-osd)
mkdir -p /var/lib/ceph/osd/ceph-$ID
mkfs.xfs /dev/$DEV
mount /dev/$DEV /var/lib/ceph/osd/ceph-$ID
ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-$ID/keyring \
     --name osd.$ID --add-key $OSD_SECRET
ceph-osd -i $ID --mkfs --osd-uuid $UUID
adduser ceph
chown -R ceph:ceph /var/lib/ceph/osd/ceph-$ID
```

## start osd
`ceph-osd -i $ID --osd-uuid $UUID -d`

# verify monitor:
`ceph -s`


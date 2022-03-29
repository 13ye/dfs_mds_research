# inside container which already install ceph
```bash
docker run -itd --name=ceph_mon1 --network=host ub_ceph_prod:v17.1.0
docker exec -it ceph_mon1 /bin/zsh
```

## create config
```bash
# set variable
mon_name=mon-node1
mon_ip=192.168.5.171
fsid=`uuidgen`
# start
mkdir /etc/ceph
cat << EOF > /etc/ceph/ceph.conf
[global]
fsid = $fsid
mon initial members = $mon_name
mon host = $mon_ip
public network = 192.168.5.0/24
auth cluster required = cephx
auth service required = cephx
auth client required = cephx
osd journal size = 1024
osd pool default size = 1
osd pool default min size = 1
osd pool default pg num = 32
osd pool default pgp num = 32
osd crush chooseleaf type = 1
EOF
```

## create auth keyrings:
```bash
sudo ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
mkdir -p /var/lib/ceph/bootstrap-osd/
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
adduser ceph
sudo chown ceph:ceph /tmp/ceph.mon.keyring
```

## set monmap
replace uuid, hostname, ip-address:
```bash
monmaptool --create --add $mon_name $mon_ip --fsid $fsid /tmp/monmap
chown ceph:ceph /var/lib/ceph/
sudo -u ceph mkdir -p /var/lib/ceph/mon/ceph-$mon_name
sudo -u ceph ceph-mon --cluster ceph --mkfs -i $mon_name --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
```

## start mgr
```bash
name=mgr1
mkdir -p /var/lib/ceph/mgr/ceph-$name
ceph auth get-or-create mgr.$name mon 'allow profile mgr' osd 'allow *' mds 'allow *' > /var/lib/ceph/mgr/ceph-$name/keyring
ceph-mgr -i $name -d
```

## start monitor:
```bash
mkdir -p /var/log/ceph
sudo chown ceph:ceph /var/log/ceph
ceph-mon --id=$mon_name -d
```

## verify monitor:
`ceph -s`


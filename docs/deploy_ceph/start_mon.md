# inside container which already install ceph

## create config
```bash
mkdir /etc/ceph
cat << EOF > /etc/ceph/ceph.conf
[global]
fsid = `uuidgen`
mon initial members = mon-node1
mon host = 192.168.5.172
public network = 192.168.5.0/24
auth cluster required = cephx
auth service required = cephx
auth client required = cephx
osd journal size = 1024
osd pool default size = 3
osd pool default min size = 2
osd pool default pg num = 333
osd pool default pgp num = 333
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
monmaptool --create --add {hostname} {ip-address} --fsid {uuid} /tmp/monmap
chown ceph:ceph /var/lib/ceph/
sudo -u ceph mkdir -p /var/lib/ceph/mon/ceph-mon-node1
sudo -u ceph ceph-mon --cluster ceph --mkfs -i mon-node1 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
```

## start monitor:
`ceph-mon --id=mon-node1 -d`

## verify monitor:
`ceph -s`

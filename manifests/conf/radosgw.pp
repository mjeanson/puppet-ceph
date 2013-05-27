define ceph::conf::radosgw (
) {

  concat::fragment { "ceph-radosgw-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '80',
    content => template('ceph/ceph.conf-radosgw.erb'),
  }

}

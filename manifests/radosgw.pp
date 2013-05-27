# Configure a ceph radosgw
#
# == Name
#   This resource's name is the radosgw's id and must be numeric.
# == Parameters
# [*radosgw_data*] Base path for radosgw data. Data will be put in a radosgw.$id folder.
#   Optional. Defaults to '/var/lib/ceph/radosgw.
#
# == Dependencies
#
# none
#
# == Authors
#
#  Sébastien Han sebastien.han@enovance.com
#  François Charlier francois.charlier@enovance.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#

define ceph::radosgw (
  $radosgw_data = '/var/lib/ceph/radosgw',
) {

  include 'ceph::package'
  include 'ceph::conf'
  include 'ceph::params'

  ceph::conf::radosgw { $name : }

  Package['ceph'] -> Ceph::Key <<| title == 'admin' |>>
  ensure_packages( [ 'radosgw', ] )

  $radosgw_data_expanded = "${radosgw_data}/ceph-radosgw.gateway"

  file { $radosgw_data_expanded:
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
  }

  exec { 'ceph-radosgw-keyring':
    command =>"ceph auth get-or-create client.radosgw.gateway osd 'allow rwx' mon 'allow r' > ${radosgw_data_expanded}/keyring",
    creates => "${radosgw_data_expanded}/keyring",
    before  => Service['ceph-radosgw.gateway'],
    require => [ Package['ceph'], Ceph::Key['admin'] ],
  }

  #FIXME: Does the upstart provider support parameters?
  service { "ceph-radosgw.gateway":
    ensure   => running,
    provider => $::ceph::params::service_provider,
    start    => "service ceph start id=radosgw.gateway",
    stop     => "service ceph stop id=radosgw.gateway",
    status   => "service ceph status id=radosgw.gateway",
    require  => Exec['ceph-radosgw-keyring'],
  }
}

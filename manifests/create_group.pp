# @summary 
#    User defines resource to create unix groups
#
# Create unix groups
# 
# @param gid
#    Numeric group id
#
# @param ensure
#    Ensure if group is present or absent. Valid values are 'present' or 'absent'.
#
define sshkeymgmt::create_group (
  $gid,
  $ensure = Enum['present', 'absent']) {

  $group = $title

  group { $group:
    ensure => $ensure,
    gid    => $gid;
  }
}

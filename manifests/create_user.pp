# @summary 
#    User defined resource to create unix users
#
# Create unix users
# 
# @param uid
#    Numeric uid 
#
# @param gid
#    Numeric group id
#
# @param homedir
#    Home directory of the user. If empty it will be created from '/home' and the username
#
# @param comment
#    Comment describing the user
#
# @param shell
#    The Unix shell foer the user
# 
# @param password
# The password to be set
#
# @param ensure
#    Ensure if the user is present or absent. Valid values are 'present' or 'absent'.
#
# @param groups
# additional groups the user should belong to
# 
# @param sshkeys
#    ssh keys to be added to the users authorized_keys file
# 
define sshkeymgmt::create_user (
  $uid,
  $gid,
  $homedir     = '',
  $comment  = '',
  $shell    = '/bin/bash',
  $password = '!!',
  $ensure   = Enum['present', 'absent'],
  $groups   = [],
  $sshkeys  = []) {

  $user = $title

  if ($homedir == '') {
    $myhome = "/home/${user}"
  } else {
    $myhome = $homedir
  }

  validate_array($sshkeys)

  user { $user:
    ensure     => $ensure,
    gid        => $gid,
    comment    => $comment,
    shell      => $shell,
    home       => $myhome,
    password   => $password,
    managehome => true,
    groups     => $groups,
    uid        => $uid;
  }

  file { "${myhome}/.ssh":
    ensure  => directory,
    require => User[$user],
    owner   => $uid,
    group   => $gid,
    mode    => '0755';
  }

  if (empty($sshkeys) == false) {
    $myfile = "${myhome}/.ssh/authorized_keys"

    concat::fragment { "${uid}-${gid}-auth":
      target  => $myfile,
      content => epp('sshkeymgmt/authorized_keys.epp', {'sshkeys' => $sshkeys}),
    }
  }
}

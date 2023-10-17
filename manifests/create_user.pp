# @summary 
#    User defined resource to create unix users
#
# Create Unix users
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
#    The password to be set
#
# @param ensure
#    Ensure if the user is present or absent. Valid values are 'present' or 'absent'.
#
# @param groups
#    additional groups the user should belong to
# 
# @param sshkeys
#    ssh keys to be added to the users authorized_keys file
# 
define sshkeymgmt::create_user (
  Integer $uid,
  Integer $gid,
  Optional[String] $homedir         = undef,
  Optional[String] $comment         = undef,
  String $shell                     = '/bin/bash',
  String $password                  = '!!',               #lint:ignore:security_password_in_code
  Enum['present', 'absent'] $ensure = 'present',
  Array $groups                     = [],
  Array $sshkeys                    = [],
) {
  $user = $title

  $myhome = $homedir ? {
    undef   => "/home/${user}",
    ''      => "/home/${user}",
    default => $homedir,
  }

  $_comment = $comment ? {
    undef   => '',
    default => $comment,
  }

  if ($sshkeymgmt::authorized_keys_base_dir == '') or ($sshkeymgmt::authorized_keys_base_dir == undef) {
    $mysshkeydir = "${myhome}/.ssh"
  } else {
    $mysshkeydir = $sshkeymgmt::authorized_keys_base_dir
  }

  ensure_resource('user', $user, {
      ensure     => $ensure,
      gid        => $gid,
      comment    => $_comment,
      shell      => $shell,
      home       => $myhome,
      password   => $password,
      managehome => true,
      groups     => $groups,
      uid        => $uid,
  })

  if ($sshkeymgmt::authorized_keys_base_dir == '') or ($sshkeymgmt::authorized_keys_base_dir == undef) {
    file { $mysshkeydir:
      ensure  => directory,
      require => User[$user],
      owner   => $uid,
      group   => $gid,
      mode    => '0755';
    }
  }

  if (empty($sshkeys) == false) {
    if ($sshkeymgmt::authorized_keys_base_dir == '') or ($sshkeymgmt::authorized_keys_base_dir == undef) {
      $myfile = "${myhome}/.ssh/authorized_keys"
    } else {
      $myfile = "${sshkeymgmt::authorized_keys_base_dir}/${user}.authorized_keys"
    }

    concat::fragment { "${uid}-${gid}-auth":
      target  => $myfile,
      content => epp('sshkeymgmt/authorized_keys.epp', { 'sshkeys' => $sshkeys }),
    }
  }
}

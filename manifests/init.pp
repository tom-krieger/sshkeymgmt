# @summary 
#    Rollout ssh keys, Unix groups and Unix users
#
# Create Unix users and Unix groups and roll out the ssh keys of the users. 
# Groups of users can be defined and rolled out.
# A user is regarded as a user group with only one member.
#
# @param users
#    Hash with all defined Unix users
#
# @param groups
#    Hash with all defined Unix groups
#
# @param ssh_key_groups
#    Group of users to deploy on a host together with their aah keys
#
# @param authorized_keys_base_dir
#    Base directory where to place ssh authorized keys files. Set this parameter if authorized keys files should not be located in user's 
#    home directory
#
# @param authorized_keys_owner
#    This parameter must be set if authorized_keys_base_dir is not empty. This parameter sets the owner of the authorized keys file.
#
# @param authorized_keys_group
#    This parameter must be set if authorized_keys_base_dir is not empty. This paremeter sets the group of the authorized keys file.
#
# @param authorized_keys_permissions
#    This parameter must be set if authorized_keys_base_dir is not empty. This parameter sets the file permissions of the 
#    authorized keys file.
#
# @param authorized_keys_base_dir_permissions
#    The permissions of the directory containing the ssh kex files if not stored within the user's home directory.
#
# @example
#   include sshkeymgmt
class sshkeymgmt(
  Hash $users ,
  Hash $groups,
  Hash $ssh_key_groups,
  String $authorized_keys_base_dir             = '',
  String $authorized_keys_owner                = '',
  String $authorized_keys_group                = '',
  String $authorized_keys_permissions          = '',
  String $authorized_keys_base_dir_permissions = '',
) {

  if(empty($users) ) {
    notify{'No users defined': }
  }

  if(empty($ssh_key_groups)) {
    notify{'No ssh key groups defined': }
  }

  if ($authorized_keys_base_dir != '') {

    if(empty($authorized_keys_owner) or empty($authorized_keys_group) or
      empty($authorized_keys_permissions) or empty($authorized_keys_base_dir_permissions)) {
      fail(translate('authorized_keys_owner, authorized_keys_group, authorized_keys_base_dir_permissions and authorized_keys_permissions must be set as well!')) #lint:ignore:140chars
    }

    file{$authorized_keys_base_dir:
      ensure => directory,
      owner  => $authorized_keys_owner,
      group  => $authorized_keys_group,
      mode   => $authorized_keys_base_dir_permissions,
    }
  }

  $groups.each | $group, $group_data | {
    group { $group:
      ensure => $group_data['ensure'],
      gid    => $group_data['gid'];
    }
  }

  create_resources('sshkeymgmt::add_users', $ssh_key_groups)
}

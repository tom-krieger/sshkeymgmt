# @summary
#    Resource add_user
#
# Add users together with their ssh keys to the local uasers on an Unix host
#
# @param ssh_users
#    List of users
#
define sshkeymgmt::add_users(
  Array $ssh_users
) {
  if(empty($ssh_users)) {
    notify{"No ssh users in group ${title}": }
  }

  if ($sshkeymgmt::authorized_keys_base_dir != '') {
    $myowner = $sshkeymgmt::authorized_keys_owner
    $mygroup = $sshkeymgmt::authorized_keys_group
    $mymode = $sshkeymgmt::authorized_keys_permissions
  }

  $ssh_users.each |String $ssh_user| {
    $user_data_hash = $sshkeymgmt::users.filter |$items| { $items[0] == $ssh_user }

    if(empty($user_data_hash)) {
      notify{"No user data for ${ssh_user} found. Ignoring this user": }
    } else {
      if ($sshkeymgmt::authorized_keys_base_dir == '') {
        $myfile = "${user_data_hash[$ssh_user]['homedir']}/.ssh/authorized_keys"
        $myowner = $user_data_hash[$ssh_user]['uid']
        $mygroup = $user_data_hash[$ssh_user]['gid']
        $mymode = '0755'
      } else {
        $myfile = "${sshkeymgmt::authorized_keys_base_dir}/${ssh_user}.authorized_keys"
      }

      if(! defined(Concat[$myfile]) ) {
        notify{"File ${myfile}": }
        notice("File ${myfile}")
        concat { $myfile:
          ensure         => present,
          warn           => true,
          ensure_newline => true,
          owner          => $myowner,
          group          => $mygroup,
          mode           => $mymode
        }

        create_resources('sshkeymgmt::create_user', $user_data_hash )
      }
    }
  }
}

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

  $ssh_users.each |String $ssh_user| {
    $user_data_hash = $sshkeymgmt::users.filter |$items| { $items[0] == $ssh_user }

    if(empty($user_data_hash)) {
      notify{"No user data for ${ssh_user} found. Ignoring this user": }
    } else {
      $homedir = "${user_data_hash[$ssh_user]['homedir']}/.ssh/authorized_keys"

      if(! defined(Concat[$homedir]) ) {
        concat { $homedir:
          ensure         => present,
          warn           => true,
          ensure_newline => true,
          owner          => 'root',
          group          => 'root',
          mode           => '0644';
        }

        create_resources('sshkeymgmt::create_user', $user_data_hash )
      }
    }
  }
}

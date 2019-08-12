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
# @example
#   include sshkeymgmt
class sshkeymgmt(
  Hash $users ,
  Hash $groups,
  Hash $ssh_key_groups
) {

  if(empty($users) ) {
    notify{'No users defined': }
  }

  if(empty($ssh_key_groups)) {
    notify{'No ssh key groups defined': }
  }

  create_resources('sshkeymgmt::create_group', $groups)

  create_resources('sshkeymgmt::add_users', $ssh_key_groups)
}

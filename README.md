# sshkeymgmt

## Table of Contents

1. [Module description](#module-description)
2. [Setup - The basics of getting started with sshkeymgmt](#setup)
    * [What sshkeymgmt affects](#what-sshkeymgmt-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with sshkeymgmt](#beginning-with-sshkeymgmt)
3. [Usage](#usage)
4. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Changelog](#changelog)
8. [Contributors](#contributors)

## Module description

Sshkeymgmt module is for managing Unix groups and Unix users together with their ssh keys. The module is focused on deploying users in groups. Groups e. g. can be departemens or teams (e. g. system administrators) within your organisation. As a group can consist of one member as well the module is not limited to deploy users and ssh keys in groups.

Users used in ssh key groups which are not defined are simply ignored. A notification is printed to inform about that.

> Please make sure to configure your ssh daemon accordingly to the location the ssh authorized_keys files will be located.

## Setup

### What sshkeymgmt affects

Sshkeymgmt adds, modifies or deletes Unix users and Unix groups on your systems. As it is run with super user privileges it can affect any user on your systems.

### Setup Requirements

sshkeymgmt needs puppetlab stdlib and puppetlab concat to work.

### Beginning with sshkeymgmt

The most basic setup you could achieve with this module looks something like this:

```puppet
include '::sshkeymgmt'
```

or

```puppet
class { '::sshkeymgmt': }
```

If there are no Unix users, no Unix groups or no ssh key groups the module will print a notification only.

## Usage

Configuration for the class can be done either by Hiera or by writing the configuration directly into the class statement.

### Example Hiera data

Configuration of users, groups and ssh key groups can be distributed over different Hiera files. You can for example have all Unix user and group definitions in your most common Hiera file. The ssh groups can be defined in the most recent Hiera file describing the node. Using Hiera reduces coding effort for class usage to

```puppet
include '::sshkeymgmt'
````

or

```puppet
class { 'sshkeymgmt': }
```

#### Example common.yaml

```puppet
---
sshkeymgmt::groups:
  test1:
    gid: 5001
    ensure: present
  test2:
    gid: 5002
    ensure: present
  test3:
    gid: 5003
    ensure: present

sshkeymgmt::users:
  test1:
    ensure: present
    gid: 5001
    uid: 5001
    homedir: '/home/test1'
    sshkeys:
      - ssh-rsa AAAA ... Test1
      - ssh-rsa AAAA ... Test5
  test2:
    ensure: present
    gid: 5002
    uid: 5002
    homedir: '/home/test2'
    sshkeys:
      - ssh-rsa AAAA ... Test2
  test3:
    ensure: present
    gid: 5002
    uid: 5003
    homedir: '/home/test3'
    sshkeys:
      - ssh-rsa AAAA ...Test3
  test4:
    ensure: present
    gid: 5004
    uid: 5004
    homedir: '/home/test4'
    sshkeys:
      - ssh-rsa AAAA ... Test4
```

#### Example node1.yaml

The ssh keys and Unix users can be grouped by teams or departments or whatever groups you want to define.

```puppet
---
sshkeymgmt::ssh_key_groups:
  ops:
    ssh_users:
      - test1
      - test2
  dba:
    ssh_users:
      - test3
      - test2
```

### Class usage example

The users, groups and ssh key groups can be defined in Puppet code as well.

```puppet
$groups = {
  'test1' => {
    gid => 5001,
    ensure => present
  }
}

$users = {
  'test1' => {
    ensure => present,
    gid => 5001,
    uid => 5001,
    homedir => '/home/test1',
    sshkeys => ['ssh-rsa AAAA ... Test1', 'ssh-rsa AAAA ... Test5']
  }
}

$sshkeygroups = {
  'ssh1': => {
    'ssh_users' => ['test1', 'test2']
  }  
}

class { '::sshkeymgmt':
  users => $users,
  groups => $groups,
  ssh_key_groups => $sshkeygroups
}
```

## Reference

See [REFERENCE.md](https://github.com/tom-krieger/sshkeymgmt/blob/master/REFERENCE.md)

## Limitations

This module has been tested on several Unix platforms, and no issues have been identified. But this module does not care about the *sshd* configuration. Please make sure the ssh authorized_keys files are stored in the location the *sshd* is expecting.

For an extensive list of supported operating systems, see [metadata.json](https://github.com/tom-krieger/sshkeymgmt/blob/master/metadata.json)

## Development

Contributions are welcome in any form, pull requests, and issues should be filed via GitHub.

Please add acceptance tests for your code as well. There's a script *acc_tests.sh* which runs the tests for CentOS 7 and Ubuntu 18.04.

## Changelog

See [CHANGELOG.md](https://github.com/tom-krieger/sshkeymgmt/blob/master/CHANGELOG.md)

## Contributors

require 'spec_helper_acceptance'

pp_alt_ssh_dir = <<-PUPPETCODE
    class { sshkeymgmt:
      users => {
        test1 => {
          ensure => present,
          gid => 5001,
          uid => 5001,
          homedir => '/home/test1',
          sshkeys => ['ssh-rsa AAAA...Hot Test1'],
        },
        test2 => {
          ensure  => present,
          gid  => 5002,
          uid  => 5002,
          homedir  => '/home/test2',
          sshkeys => ['ssh-rsa AAAA...pnd Test2'],
        },
      },
      groups => {
        test1 => {
          gid => 5001,
          ensure => present,
        },
        test2 => {
          gid => 5002,
          ensure => present,
        },
      },
      ssh_key_groups => {
        ssh1 => {
          ssh_users => ['test1', 'test2'],
        },
      },
      authorized_keys_base_dir => '/tmp/test',
      authorized_keys_owner => 'root',
      authorized_keys_group => 'root',
      authorized_keys_permissions => '0644',
      authorized_keys_base_dir_permissions => '0755',
    }
PUPPETCODE

pp_ssh_dir_in_user_home = <<-PUPPETCODE
    class { sshkeymgmt:
      users => {
        test1 => {
          ensure => present,
          gid => 5001,
          uid => 5001,
          homedir => '/home/test1',
          sshkeys => ['ssh-rsa AAAA...Hot Test1'],
        },
        test2 => {
          ensure  => present,
          gid  => 5002,
          uid  => 5002,
          homedir  => '/home/test2',
          sshkeys => ['ssh-rsa AAAA...pnd Test2'],
        },
      },
      groups => {
        test1 => {
          gid => 5001,
          ensure => present,
        },
        test2 => {
          gid => 5002,
          ensure => present,
        },
      },
      ssh_key_groups => {
        ssh1 => {
          ssh_users => ['test1', 'test2'],
        },
      },
      authorized_keys_base_dir => '',
      authorized_keys_owner => '',
      authorized_keys_group => '',
      authorized_keys_permissions => '',
      authorized_keys_base_dir_permissions => '',
    }
PUPPETCODE

# @summary: Helper function to run common functionality of MOTD acceptance tests.
#           Applies the manifest twice, if not windows checks for file against expected contents.
#           If a Debian dynamic test bool is given as true, executes a test for that platform.
# @param [string]  pp:                  Class MOTD definition to be tested
# @param [string]  expected_contain:    Expected contents of the MOTD file to be compared
# @param [string]  filename:            MOTD file to be tested
def test_sshkeys(pp, expected_contain, filename)
  idempotent_apply(pp)

  return unless os[:family] != 'windows'
  expect(file(filename)).to be_file
  expect(file(filename)).to contain expected_contain
end

describe 'Message ssh keys' do
  context 'when alternate ssh dir is used for ssh keys user test1' do
    it do
      test_sshkeys(pp_alt_ssh_dir, "ssh-rsa AAAA...Hot Test1", '/tmp/test/test1.authorized_keys')
    end
  end

  context 'when alternate ssh dir is used for ssh keys user test2' do
    it do
      test_sshkeys(pp_alt_ssh_dir, "ssh-rsa AAAA...pnd Test2", '/tmp/test/test2.authorized_keys')
    end
  end

  context 'when alternate ssh dir is used for ssh keys group entry test1' do
    it do
      test_sshkeys(pp_alt_ssh_dir, 'test1:x:5001:', '/etc/group')
    end
  end

  context 'when alternate ssh dir is used for ssh keys group entry test2' do
    it do
      test_sshkeys(pp_alt_ssh_dir, 'test2:x:5002:', '/etc/group')
    end
  end

  context 'when ssh keys reside within user home dir user test1' do
    it do
      test_sshkeys(pp_ssh_dir_in_user_home, "ssh-rsa AAAA...Hot Test1", '/home/test1/.ssh/authorized_keys')
    end
  end

  context 'when ssh keys reside within user home dir user test2' do
    it do
      test_sshkeys(pp_ssh_dir_in_user_home, "ssh-rsa AAAA...pnd Test2", '/home/test2/.ssh/authorized_keys')
    end
  end

  context 'when ssh keys reside within user home dir group entry test1' do
    it do
      test_sshkeys(pp_alt_ssh_dir, 'test1:x:5001:', '/etc/group')
    end
  end

  context 'when ssh keys reside within user home dir group entry test2' do
    it do
      test_sshkeys(pp_alt_ssh_dir, 'test2:x:5002:', '/etc/group')
    end
  end
end

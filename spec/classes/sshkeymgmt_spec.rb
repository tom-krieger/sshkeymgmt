require 'spec_helper'
require 'pp'

describe 'sshkeymgmt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os} with wrong parameters" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'users' => {
            'test1' => {
              'ensure' => 'present',
              'gid' => 5001,
              'uid' => 5001,
              'homedir' => '/home/test1',
              'sshkeys' => ['ssh-rsa AAAA...Hot Test1'],
            },
            'test2' => {
              'ensure' => 'present',
              'gid' => 5002,
              'uid' => 5002,
              'homedir' => '/home/test2',
              'sshkeys' => ['ssh-rsa AAAA...pnd Test2'],
            },
            'test4' => {
              'ensure' => 'absent',
              'gid' => 5002,
              'uid' => 5002,
            },
          },
          'groups' => {
            'test1' => {
              'gid' => 5001,
              'ensure' => 'present',
            },
            'test2' => {
              'gid' => 5002,
              'ensure' => 'present',
            },
          },
          'ssh_key_groups' => {
            'ssh1' => {
              'ssh_users' => ['test1', 'test2'],
            },
          },
          'authorized_keys_base_dir' => '/tmp/test',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{authorized_keys_owner, authorized_keys_group, authorized_keys_base_dir_permissions and authorized_keys_permissions must be set as well}) }
    end

    context "on #{os} with alternate ssh directory" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'users' => {
            'test1' => {
              'ensure' => 'present',
              'gid' => 5001,
              'uid' => 5001,
              'homedir' => '/home/test1',
              'sshkeys' => ['ssh-rsa AAAA...Hot Test1'],
            },
            'test2' => {
              'ensure' => 'present',
              'gid' => 5002,
              'uid' => 5002,
              'homedir' => '/home/test2',
              'sshkeys' => ['ssh-rsa AAAA...pnd Test2'],
            },
            'test4' => {
              'ensure' => 'absent',
              'gid' => 5002,
              'uid' => 5002,
            },
          },
          'groups' => {
            'test1' => {
              'gid' => 5001,
              'ensure' => 'present',
            },
            'test2' => {
              'gid' => 5002,
              'ensure' => 'present',
            },
          },
          'ssh_key_groups' => {
            'ssh1' => {
              'ssh_users' => ['test1', 'test2'],
            },
          },
          'authorized_keys_base_dir' => '/tmp/test',
          'authorized_keys_owner' => 'root',
          'authorized_keys_group' => 'root',
          'authorized_keys_permissions' => '0644',
          'authorized_keys_base_dir_permissions' => '0755',
        }
      end

      it { is_expected.to compile }

      it do
        if ENV['DEBUG']
          pp catalogue.resources
        end

        is_expected.to contain_file('/tmp/test')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_concat('/tmp/test/test1.authorized_keys')
          .with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_concat('/tmp/test/test2.authorized_keys')
          .with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )

        is_expected.to contain_group('test1')
          .with(
            'ensure' => 'present',
            'gid' => '5001',
          )

        is_expected.to contain_group('test2')
          .with(
            'ensure' => 'present',
            'gid' => '5002',
          )
      end
    end # end context

    context "on #{os} with home directory" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'users' => {
            'test1' => {
              'ensure' => 'present',
              'gid' => 5001,
              'uid' => 5001,
              'homedir' => '/home/test1',
              'sshkeys' => ['ssh-rsa AAAA...Hot Test1'],
            },
            'test2' => {
              'ensure' => 'present',
              'gid' => 5002,
              'uid' => 5002,
              'homedir' => '/home/test2',
              'sshkeys' => ['ssh-rsa AAAA...pnd Test2'],
            },
            'test4' => {
              'ensure' => 'absent',
              'gid' => 5002,
              'uid' => 5002,
            },
          },
          'groups' => {
            'test1' => {
              'gid' => 5001,
              'ensure' => 'present',
            },
            'test2' => {
              'gid' => 5002,
              'ensure' => 'present',
            },
          },
          'ssh_key_groups' => {
            'ssh1' => {
              'ssh_users' => ['test1', 'test2'],
            },
          },
          'authorized_keys_base_dir' => '',
          'authorized_keys_owner' => '',
          'authorized_keys_group' => '',
          'authorized_keys_permissions' => '',
          'authorized_keys_base_dir_permissions' => '',
        }
      end

      it { is_expected.to compile }

      it do
        if ENV['DEBUG']
          pp catalogue.resources
        end

        is_expected.to contain_file('/home/test1/.ssh')
          .with(
            'ensure'  => 'directory',
            'owner'   => 5001,
            'group'   => 5001,
            'mode'    => '0755',
          )
          .that_requires('User[test1]')

        is_expected.to contain_file('/home/test2/.ssh')
          .with(
            'ensure'  => 'directory',
            'owner'   => 5002,
            'group'   => 5002,
            'mode'    => '0755',
          )
          .that_requires('User[test2]')

        is_expected.to contain_concat('/home/test1/.ssh/authorized_keys')
          .with(
            'ensure' => 'present',
            'owner'  => '5001',
            'group'  => '5001',
            'mode'   => '0644',
          )

        is_expected.to contain_concat('/home/test2/.ssh/authorized_keys')
          .with(
            'ensure' => 'present',
            'owner'  => '5002',
            'group'  => '5002',
            'mode'   => '0644',
          )

        is_expected.to contain_user('test1')
          .with(
            'ensure'     => 'present',
            'gid'        => 5001,
            'home'       => '/home/test1',
            'managehome' => true,
            'uid'        => 5001,
          )

        is_expected.to contain_user('test2')
          .with(
            'ensure'     => 'present',
            'gid'        => 5002,
            'home'       => '/home/test2',
            'managehome' => true,
            'uid'        => 5002,
          )

        is_expected.to contain_group('test1')
          .with(
            'ensure' => 'present',
            'gid' => '5001',
          )

        is_expected.to contain_group('test2')
          .with(
            'ensure' => 'present',
            'gid' => '5002',
          )

        is_expected.to contain_sshkeymgmt__create_user('test1')
        is_expected.to contain_sshkeymgmt__create_user('test2')
        is_expected.to contain_sshkeymgmt__add_users('ssh1')

        is_expected.to contain_concat__fragment('5001-5001-auth')
          .with(
            'target' => '/home/test1/.ssh/authorized_keys',
          )

        is_expected.to contain_concat__fragment('5002-5002-auth')
          .with(
            'target' => '/home/test2/.ssh/authorized_keys',
          )
      end
    end # end context

    context "on #{os} with home directory without defined ssh directory" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'users' => {
            'test1' => {
              'ensure' => 'present',
              'gid' => 5001,
              'uid' => 5001,
              'homedir' => '/home/test1',
              'sshkeys' => ['ssh-rsa AAAA...Hot Test1'],
            },
            'test2' => {
              'ensure' => 'present',
              'gid' => 5002,
              'uid' => 5002,
              'homedir' => '/home/test2',
              'sshkeys' => ['ssh-rsa AAAA...pnd Test2'],
            },
            'test4' => {
              'ensure' => 'absent',
              'gid' => 5002,
              'uid' => 5002,
            },
          },
          'groups' => {
            'test1' => {
              'gid' => 5001,
              'ensure' => 'present',
            },
            'test2' => {
              'gid' => 5002,
              'ensure' => 'present',
            },
          },
          'ssh_key_groups' => {
            'ssh1' => {
              'ssh_users' => ['test1', 'test2'],
            },
          },
        }
      end

      it { is_expected.to compile }

      it do
        if ENV['DEBUG']
          pp catalogue.resources
        end

        is_expected.to contain_file('/home/test1/.ssh')
          .with(
            'ensure'  => 'directory',
            'owner'   => 5001,
            'group'   => 5001,
            'mode'    => '0755',
          )
          .that_requires('User[test1]')

        is_expected.to contain_file('/home/test2/.ssh')
          .with(
            'ensure'  => 'directory',
            'owner'   => 5002,
            'group'   => 5002,
            'mode'    => '0755',
          )
          .that_requires('User[test2]')

        is_expected.to contain_concat('/home/test1/.ssh/authorized_keys')
          .with(
            'ensure' => 'present',
            'owner'  => '5001',
            'group'  => '5001',
            'mode'   => '0644',
          )

        is_expected.to contain_concat('/home/test2/.ssh/authorized_keys')
          .with(
            'ensure' => 'present',
            'owner'  => '5002',
            'group'  => '5002',
            'mode'   => '0644',
          )

        is_expected.to contain_user('test1')
          .with(
            'ensure'     => 'present',
            'gid'        => 5001,
            'home'       => '/home/test1',
            'managehome' => true,
            'uid'        => 5001,
          )

        is_expected.to contain_user('test2')
          .with(
            'ensure'     => 'present',
            'gid'        => 5002,
            'home'       => '/home/test2',
            'managehome' => true,
            'uid'        => 5002,
          )

        is_expected.to contain_group('test1')
          .with(
            'ensure' => 'present',
            'gid' => '5001',
          )

        is_expected.to contain_group('test2')
          .with(
            'ensure' => 'present',
            'gid' => '5002',
          )

        is_expected.to contain_sshkeymgmt__create_user('test1')
        is_expected.to contain_sshkeymgmt__create_user('test2')
        is_expected.to contain_sshkeymgmt__add_users('ssh1')

        is_expected.to contain_concat__fragment('5001-5001-auth')
          .with(
            'target' => '/home/test1/.ssh/authorized_keys',
          )

        is_expected.to contain_concat__fragment('5002-5002-auth')
          .with(
            'target' => '/home/test2/.ssh/authorized_keys',
          )
      end
    end # end context
  end
end

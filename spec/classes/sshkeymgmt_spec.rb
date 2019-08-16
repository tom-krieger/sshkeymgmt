require 'spec_helper'
require 'pp'

describe 'sshkeymgmt' do
  on_supported_os.each do |os, os_facts|
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
        }
      end

      it { is_expected.to compile }

      it do
        if ENV['DEBUG']
          pp catalogue.resources
        end

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
        }
      end

      it { is_expected.to compile }

      it do
        if ENV['DEBUG']
          pp catalogue.resources
        end

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
  end
end

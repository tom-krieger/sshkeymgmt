require 'spec_helper_acceptance'
require 'net/ssh'
require 'ed25519'
require 'bcrypt_pbkdf'

pp_alt_ssh_dir = <<-PUPPETCODE
    class { sshkeymgmt:
      users => {
        test1 => {
          ensure => present,
          gid => 5001,
          uid => 5001,
          homedir => '/home/test1',
          sshkeys => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4MIqCcU/96b+WFtnpAdOvL3g9czpdgxx7DLfpRfDOGn0wkASnaudEmDmjHPnBupVFUcKf9LE8aom/Ol+SLRh4wcEcVIFsKlAp81HlxGpe0UoXHk4hDiwjIkoV0KsoK20LgxAtaqQ2ADI629gvv5UzyY1URuku3CFi31z2dVPF5KMonn6VnlfVwdaW57Zv82FkMdN3RpkTgAZvEiDZ27ppfRkW6fTLxmGGjr84njElS6dVN3A8jxOJDBaNhkQbMaiKBAVudsv7voWUErDTcJuAifLPmyQqVi8H4Ir9KWLNSKHzyAd1OuGEUCEkSpR99yi211mpwC9gfNquCH0RFawwfPz8trWnI2gnqclMZIAsJEPKVLeoAA07zQijQtS2fv099gcpgowEzdOmPUBOIrXNJBWkkZFIAMyrwkRS5YGE0br9Ng5c6cJkxEjPbtEzcPpY/djpa0DeMf0f1vzYP0TC5dq2VaWxBvpoo45Rws53EFOA2RNOMrjZDs26BniTuBo7ZBhrqT9+k/fhVULwj4C3VERoYD6197ul2k2c1GywS7AAPmycLqfqiq37jVUQpa/FWTJIPOWHMUyeS7r5q6TCLLutCkIAqx5SXoqatbDS5+hC+3Muix5aXXViLqJmNHraSxt0PvOOqHmtfMkptHBvkR82rEbZc/5cvzQrSXJWcQ== test1'],
        },
        test2 => {
          ensure  => present,
          gid  => 5002,
          uid  => 5002,
          homedir  => '/home/test2',
          sshkeys => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiAVyIfbd+EG9sx4Dez+jFhcK2RHPHfWUmFR6VB1Dv0B2nmU3bnmQCdhxDHJ5v5RUvU7IGOWAyLNjuOCiXnlTK0zWj8jWxE2oivdQuiF16zCLnx/G1tQ0jWOfJNn/KHFxbyjfGxjwplVvLFayEL9Bck2IT1s91kI9lovz14uCpgzHMjmh77gMipB0O9QKMnWVz9tnDK2eZ0SK30ujd//vr5XXb7I0Rrs4MIyWuH03OzY+CrMETJENcZ69BnQOCNXqOK8A78MqGCe659vz7tbllh5dmjh4nHxPJe41ajjAbmDrbfDWSfuhFXukgfFPkmOWpcZGsT2pY0O3UoZjA6/mGtReR8IU0VHCarCj2GCfrnr7JpPsPS2oYHC7xFOM+Ig3DZYeLXehq5ydbgC87p6n5mdQaZcnkSwd/yiKlJp9XZC8/X5AV5N8RMP2w7cNAymgZ6HrS8Zegm0KPKSqHuT8P7ARRdmh+v/Wfb85XTos80ZpEV+lPD8PYc9/Y+MWtddOes8HGycggT+ut7s042QcIF7Ln+TqZBqeydFMR8EPvrZdL5OdZuFzu2BniJ2PG5WJyrReX+1YfEpGorsuJ78+gcB1+/zA38kxekImRoUuJ5lh7/VCTxVCGe4ZO7EVtkQYQbpquMZwJ5FuTznFhxwjjhtsLJMNowEoqQ257gfefqQ== test2'],
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
          sshkeys => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4MIqCcU/96b+WFtnpAdOvL3g9czpdgxx7DLfpRfDOGn0wkASnaudEmDmjHPnBupVFUcKf9LE8aom/Ol+SLRh4wcEcVIFsKlAp81HlxGpe0UoXHk4hDiwjIkoV0KsoK20LgxAtaqQ2ADI629gvv5UzyY1URuku3CFi31z2dVPF5KMonn6VnlfVwdaW57Zv82FkMdN3RpkTgAZvEiDZ27ppfRkW6fTLxmGGjr84njElS6dVN3A8jxOJDBaNhkQbMaiKBAVudsv7voWUErDTcJuAifLPmyQqVi8H4Ir9KWLNSKHzyAd1OuGEUCEkSpR99yi211mpwC9gfNquCH0RFawwfPz8trWnI2gnqclMZIAsJEPKVLeoAA07zQijQtS2fv099gcpgowEzdOmPUBOIrXNJBWkkZFIAMyrwkRS5YGE0br9Ng5c6cJkxEjPbtEzcPpY/djpa0DeMf0f1vzYP0TC5dq2VaWxBvpoo45Rws53EFOA2RNOMrjZDs26BniTuBo7ZBhrqT9+k/fhVULwj4C3VERoYD6197ul2k2c1GywS7AAPmycLqfqiq37jVUQpa/FWTJIPOWHMUyeS7r5q6TCLLutCkIAqx5SXoqatbDS5+hC+3Muix5aXXViLqJmNHraSxt0PvOOqHmtfMkptHBvkR82rEbZc/5cvzQrSXJWcQ== test1'],
        },
        test2 => {
          ensure  => present,
          gid  => 5002,
          uid  => 5002,
          homedir  => '/home/test2',
          sshkeys => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiAVyIfbd+EG9sx4Dez+jFhcK2RHPHfWUmFR6VB1Dv0B2nmU3bnmQCdhxDHJ5v5RUvU7IGOWAyLNjuOCiXnlTK0zWj8jWxE2oivdQuiF16zCLnx/G1tQ0jWOfJNn/KHFxbyjfGxjwplVvLFayEL9Bck2IT1s91kI9lovz14uCpgzHMjmh77gMipB0O9QKMnWVz9tnDK2eZ0SK30ujd//vr5XXb7I0Rrs4MIyWuH03OzY+CrMETJENcZ69BnQOCNXqOK8A78MqGCe659vz7tbllh5dmjh4nHxPJe41ajjAbmDrbfDWSfuhFXukgfFPkmOWpcZGsT2pY0O3UoZjA6/mGtReR8IU0VHCarCj2GCfrnr7JpPsPS2oYHC7xFOM+Ig3DZYeLXehq5ydbgC87p6n5mdQaZcnkSwd/yiKlJp9XZC8/X5AV5N8RMP2w7cNAymgZ6HrS8Zegm0KPKSqHuT8P7ARRdmh+v/Wfb85XTos80ZpEV+lPD8PYc9/Y+MWtddOes8HGycggT+ut7s042QcIF7Ln+TqZBqeydFMR8EPvrZdL5OdZuFzu2BniJ2PG5WJyrReX+1YfEpGorsuJ78+gcB1+/zA38kxekImRoUuJ5lh7/VCTxVCGe4ZO7EVtkQYQbpquMZwJ5FuTznFhxwjjhtsLJMNowEoqQ257gfefqQ== test2'],
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

hosts = read_hosts_ssh_ports
users = ['test1', 'test2']
keydir = File.join(Dir.pwd, 'spec', 'fixtures', 'keys')
keys = ["#{keydir}/id_rsa_test1", "#{keydir}/id_rsa_test2"]

describe 'Manage ssh keys' do
  context 'when alternate ssh dir is used for ssh keys user test1' do
    it do
      test_sshkeys(pp_alt_ssh_dir, 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4MIqCcU/96b+WFtnpAdOvL3g9czpdgxx7DLfpRfDOGn0wkASnaudEmDmjHPnBupVFUcKf9LE8aom/Ol+SLRh4wcEcVIFsKlAp81HlxGpe0UoXHk4hDiwjIkoV0KsoK20LgxAtaqQ2ADI629gvv5UzyY1URuku3CFi31z2dVPF5KMonn6VnlfVwdaW57Zv82FkMdN3RpkTgAZvEiDZ27ppfRkW6fTLxmGGjr84njElS6dVN3A8jxOJDBaNhkQbMaiKBAVudsv7voWUErDTcJuAifLPmyQqVi8H4Ir9KWLNSKHzyAd1OuGEUCEkSpR99yi211mpwC9gfNquCH0RFawwfPz8trWnI2gnqclMZIAsJEPKVLeoAA07zQijQtS2fv099gcpgowEzdOmPUBOIrXNJBWkkZFIAMyrwkRS5YGE0br9Ng5c6cJkxEjPbtEzcPpY/djpa0DeMf0f1vzYP0TC5dq2VaWxBvpoo45Rws53EFOA2RNOMrjZDs26BniTuBo7ZBhrqT9+k/fhVULwj4C3VERoYD6197ul2k2c1GywS7AAPmycLqfqiq37jVUQpa/FWTJIPOWHMUyeS7r5q6TCLLutCkIAqx5SXoqatbDS5+hC+3Muix5aXXViLqJmNHraSxt0PvOOqHmtfMkptHBvkR82rEbZc/5cvzQrSXJWcQ== test1', '/tmp/test/test1.authorized_keys')
    end
  end

  context 'when alternate ssh dir is used for ssh keys user test2' do
    it do
      test_sshkeys(pp_alt_ssh_dir, 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiAVyIfbd+EG9sx4Dez+jFhcK2RHPHfWUmFR6VB1Dv0B2nmU3bnmQCdhxDHJ5v5RUvU7IGOWAyLNjuOCiXnlTK0zWj8jWxE2oivdQuiF16zCLnx/G1tQ0jWOfJNn/KHFxbyjfGxjwplVvLFayEL9Bck2IT1s91kI9lovz14uCpgzHMjmh77gMipB0O9QKMnWVz9tnDK2eZ0SK30ujd//vr5XXb7I0Rrs4MIyWuH03OzY+CrMETJENcZ69BnQOCNXqOK8A78MqGCe659vz7tbllh5dmjh4nHxPJe41ajjAbmDrbfDWSfuhFXukgfFPkmOWpcZGsT2pY0O3UoZjA6/mGtReR8IU0VHCarCj2GCfrnr7JpPsPS2oYHC7xFOM+Ig3DZYeLXehq5ydbgC87p6n5mdQaZcnkSwd/yiKlJp9XZC8/X5AV5N8RMP2w7cNAymgZ6HrS8Zegm0KPKSqHuT8P7ARRdmh+v/Wfb85XTos80ZpEV+lPD8PYc9/Y+MWtddOes8HGycggT+ut7s042QcIF7Ln+TqZBqeydFMR8EPvrZdL5OdZuFzu2BniJ2PG5WJyrReX+1YfEpGorsuJ78+gcB1+/zA38kxekImRoUuJ5lh7/VCTxVCGe4ZO7EVtkQYQbpquMZwJ5FuTznFhxwjjhtsLJMNowEoqQ257gfefqQ== test2', '/tmp/test/test2.authorized_keys')
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
      test_sshkeys(pp_ssh_dir_in_user_home, 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4MIqCcU/96b+WFtnpAdOvL3g9czpdgxx7DLfpRfDOGn0wkASnaudEmDmjHPnBupVFUcKf9LE8aom/Ol+SLRh4wcEcVIFsKlAp81HlxGpe0UoXHk4hDiwjIkoV0KsoK20LgxAtaqQ2ADI629gvv5UzyY1URuku3CFi31z2dVPF5KMonn6VnlfVwdaW57Zv82FkMdN3RpkTgAZvEiDZ27ppfRkW6fTLxmGGjr84njElS6dVN3A8jxOJDBaNhkQbMaiKBAVudsv7voWUErDTcJuAifLPmyQqVi8H4Ir9KWLNSKHzyAd1OuGEUCEkSpR99yi211mpwC9gfNquCH0RFawwfPz8trWnI2gnqclMZIAsJEPKVLeoAA07zQijQtS2fv099gcpgowEzdOmPUBOIrXNJBWkkZFIAMyrwkRS5YGE0br9Ng5c6cJkxEjPbtEzcPpY/djpa0DeMf0f1vzYP0TC5dq2VaWxBvpoo45Rws53EFOA2RNOMrjZDs26BniTuBo7ZBhrqT9+k/fhVULwj4C3VERoYD6197ul2k2c1GywS7AAPmycLqfqiq37jVUQpa/FWTJIPOWHMUyeS7r5q6TCLLutCkIAqx5SXoqatbDS5+hC+3Muix5aXXViLqJmNHraSxt0PvOOqHmtfMkptHBvkR82rEbZc/5cvzQrSXJWcQ== test1', '/home/test1/.ssh/authorized_keys')
    end
  end

  context 'when ssh keys reside within user home dir user test2' do
    it do
      test_sshkeys(pp_ssh_dir_in_user_home, 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiAVyIfbd+EG9sx4Dez+jFhcK2RHPHfWUmFR6VB1Dv0B2nmU3bnmQCdhxDHJ5v5RUvU7IGOWAyLNjuOCiXnlTK0zWj8jWxE2oivdQuiF16zCLnx/G1tQ0jWOfJNn/KHFxbyjfGxjwplVvLFayEL9Bck2IT1s91kI9lovz14uCpgzHMjmh77gMipB0O9QKMnWVz9tnDK2eZ0SK30ujd//vr5XXb7I0Rrs4MIyWuH03OzY+CrMETJENcZ69BnQOCNXqOK8A78MqGCe659vz7tbllh5dmjh4nHxPJe41ajjAbmDrbfDWSfuhFXukgfFPkmOWpcZGsT2pY0O3UoZjA6/mGtReR8IU0VHCarCj2GCfrnr7JpPsPS2oYHC7xFOM+Ig3DZYeLXehq5ydbgC87p6n5mdQaZcnkSwd/yiKlJp9XZC8/X5AV5N8RMP2w7cNAymgZ6HrS8Zegm0KPKSqHuT8P7ARRdmh+v/Wfb85XTos80ZpEV+lPD8PYc9/Y+MWtddOes8HGycggT+ut7s042QcIF7Ln+TqZBqeydFMR8EPvrZdL5OdZuFzu2BniJ2PG5WJyrReX+1YfEpGorsuJ78+gcB1+/zA38kxekImRoUuJ5lh7/VCTxVCGe4ZO7EVtkQYQbpquMZwJ5FuTznFhxwjjhtsLJMNowEoqQ257gfefqQ== test2', '/home/test2/.ssh/authorized_keys')
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

  context 'ssh login with keys installed' do
    it do
      hosts.each do |data|
        users.each do |user|
          host = data['host']
          port = data['port']
          puts "login to ‘#{user}@#{host}:#{port}"
          connect_by_ssh(host, port, user, keys)
        end
      end
    end
  end
end

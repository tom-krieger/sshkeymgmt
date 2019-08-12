require 'spec_helper'

describe 'sshkeymgmt' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'users' => {},
          'groups' => {},
          'ssh_key_groups' => {},
        }
      end

      it { is_expected.to compile }
    end
  end
end

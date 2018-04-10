require 'spec_helper'

describe 'openntp' do
  let(:title) { 'openntp' }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      case facts[:kernel]
      when 'Linux'
        let(:config_file) { '/etc/openntpd/ntpd.conf' }
      else
        let(:config_file) { '/usr/local/etc/ntpd.conf' }
      end
      let(:facts) { facts }

      describe 'by default' do
        shared_examples 'a default setup' do
          it { should contain_package('openntpd').with_ensure('installed') }
          it { should contain_service('openntpd').with_ensure('running').with_enable(true) }
          it { should contain_file(config_file) }
          it { should contain_file(config_file).with_ensure('file') }
          it { should contain_file(config_file).with_owner('root') }
          it { should contain_file(config_file).without_content(/listen on/) }
          it { should contain_file(config_file).with_content(/server 0.pool.ntp.org/) }
          it { should contain_file(config_file).with_content(/server 1.pool.ntp.org/) }
          it { should contain_file(config_file).with_content(/server 2.pool.ntp.org/) }
          it { should contain_file(config_file).with_content(/server 3.pool.ntp.org/) }
        end
      end

      describe 'with listen on any interface' do
        let(:params) { {:listen => '*'} }

        it { should contain_file(config_file).with_content(/listen on */) }
      end

      describe 'with listen on localhost only' do
        let(:params) { {:listen => '127.0.0.1'} }

        it { should contain_file(config_file).with_content(/listen on 127.0.0.1/) }
      end

      describe 'with custom server' do
        let(:params) { {:server => ['ntp.example.org']} }

        it { should contain_file(config_file).with_content(/server ntp.example.org/) }
        it { should contain_file(config_file).without_content(/server 0.debian.pool.ntp.org/) }
      end

      describe 'with custom template file' do
        let(:params) { {:template => 'openntp/ntpd.conf.erb'} }

        it { should contain_file(config_file) }
      end

      describe 'disable service' do
        let(:params) { {:enable => false} }

        it { should contain_file(config_file) }
        it { should contain_package('openntpd').with_ensure('present') }
        it { should contain_service('openntpd').with_ensure('false').with_enable(false) }
      end
    end
  end
end

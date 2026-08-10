# frozen_string_literal: true

require 'spec_helper'

describe 'grafana' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with default values' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('grafana') }
        it { is_expected.to contain_class('grafana::install').that_comes_before('Class[grafana::config]') }
        it { is_expected.to contain_class('grafana::config').that_notifies('Class[grafana::service]') }
        it { is_expected.to contain_class('grafana::service') }
      end

      context 'with parameter install_method is set to package' do
        let(:params) do
          {
            install_method: 'package',
            version: '11.0.0',
          }
        end

        case facts[:os]['family']
        when 'Debian'
          download_location = '/tmp/grafana.deb'

          describe 'use archive to fetch the package to a temporary location' do
            it do
              expect(subject).to contain_archive('/tmp/grafana.deb').with_source(
                'https://dl.grafana.com/oss/release/grafana_11.0.0_amd64.deb',
              )
            end

            it { is_expected.to contain_archive('/tmp/grafana.deb').that_comes_before('Package[grafana]') }
          end

          describe 'install dependencies first' do
            it { is_expected.to contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_provider('dpkg') }
            it { is_expected.to contain_package('grafana').with_source(download_location) }
          end
        when 'RedHat'
          describe 'install dependencies first' do
            it { is_expected.to contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_provider('rpm') }
          end
        end
      end

      context 'with some plugins passed in' do
        let(:params) do
          {
            plugins:
            {
              'grafana-wizzle' => { 'ensure' => 'present' },
              'grafana-woozle' => { 'ensure' => 'absent' },
              'grafana-plugin' => { 'ensure' => 'present', 'repo' => 'https://nexus.company.com/grafana/plugins' },
              'grafana-plugin-url' => { 'ensure' => 'present', 'plugin_url' => 'https://grafana.com/api/plugins/grafana-simple-json-datasource/versions/latest/download' },
            },
          }
        end

        it { is_expected.to contain_grafana_plugin('grafana-wizzle').with(ensure: 'present') }
        it { is_expected.to contain_grafana_plugin('grafana-woozle').with(ensure: 'absent').that_notifies('Class[grafana::service]') }

        describe 'install plugin with plugin repo' do
          it { is_expected.to contain_grafana_plugin('grafana-plugin').with(ensure: 'present', repo: 'https://nexus.company.com/grafana/plugins') }
        end

        describe 'install plugin with plugin url' do
          it { is_expected.to contain_grafana_plugin('grafana-plugin-url').with(ensure: 'present', plugin_url: 'https://grafana.com/api/plugins/grafana-simple-json-datasource/versions/latest/download') }
        end
      end

      context 'with parameter install_method is set to repo' do
        let(:params) do
          {
            install_method: 'repo',
          }
        end

        case facts[:os]['family']
        when 'Debian'
          describe 'install apt repo dependencies first' do
            it { is_expected.to contain_class('apt') }
            it { is_expected.to contain_apt__source('grafana').with(release: 'stable', repos: 'main', location: 'https://apt.grafana.com') }
            it { is_expected.to contain_apt__source('grafana').that_comes_before('Package[grafana]') }
          end

          describe 'install dependencies first' do
            it { is_expected.to contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('installed') }
          end
        when 'RedHat'
          describe 'yum repo dependencies first' do
            it { is_expected.to contain_yumrepo('grafana-stable').with(baseurl: 'https://rpm.grafana.com', gpgkey: 'https://packages.grafana.com/gpg.key', enabled: 1) }
            it { is_expected.to contain_yumrepo('grafana-stable').that_comes_before('Package[grafana]') }
          end

          describe 'install dependencies first' do
            it { is_expected.to contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('installed') }
          end
        end
      end

      context 'with parameter install_method is set to repo and manage_package_repo is set to false' do
        let(:params) do
          {
            install_method: 'repo',
            manage_package_repo: false,
            version: 'present',
          }
        end

        case facts[:os]['family']
        when 'Debian'
          describe 'install dependencies first' do
            it { is_expected.to contain_package('libfontconfig1').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('present') }
          end
        when 'RedHat'
          describe 'install dependencies first' do
            it { is_expected.to contain_package('fontconfig').with_ensure('present').that_comes_before('Package[grafana]') }
          end

          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('present') }
          end
        when 'Archlinux'
          describe 'install the package' do
            it { is_expected.to contain_package('grafana').with_ensure('present') }
          end
        end
      end

      context 'with parameter install_method is set to archive' do
        let(:params) do
          {
            install_method: 'archive',
            version: '11.0.0',
          }
        end

        install_dir    = '/usr/share/grafana'
        service_config = '/usr/share/grafana/conf/custom.ini'
        archive_source = 'https://dl.grafana.com/oss/release/grafana-11.0.0.linux-amd64.tar.gz'

        describe 'extract archive to install_dir' do
          it { is_expected.to contain_archive('/tmp/grafana.tar.gz').with_ensure('present') }
          it { is_expected.to contain_archive('/tmp/grafana.tar.gz').with_source(archive_source) }
          it { is_expected.to contain_archive('/tmp/grafana.tar.gz').with_extract_path(install_dir) }
        end

        describe 'create grafana user' do
          it { is_expected.to contain_user('grafana').with_ensure('present').with_home(install_dir) }
          it { is_expected.to contain_user('grafana').that_comes_before('File[/usr/share/grafana]') }
        end

        case facts[:os]['family']
        when 'Archlinux', 'Debian', 'RedHat'
          describe 'create data_dir' do
            it { is_expected.to contain_file('/var/lib/grafana').with_ensure('directory') }
          end
        when 'FreeBSD'
          describe 'create data_dir' do
            it { is_expected.to contain_file('/var/db/grafana').with_ensure('directory') }
          end
        end

        describe 'manage install_dir' do
          it { is_expected.to contain_file(install_dir).with_ensure('directory') }
          it { is_expected.to contain_file(install_dir).with_group('grafana').with_owner('grafana') }
        end

        describe 'configure grafana' do
          it { is_expected.to contain_file(service_config).with_ensure('file') }
        end

        describe 'run grafana as service' do
          it { is_expected.to contain_service('grafana').with_ensure('running').with_provider('base') }
          it { is_expected.to contain_service('grafana').with_hasrestart(false).with_hasstatus(false) }
        end

        context 'when user already defined' do
          let(:pre_condition) do
            'user{"grafana":
              ensure => present,
            }'
          end

          describe 'do NOT create grafana user' do
            it { is_expected.not_to contain_user('grafana').with_ensure('present').with_home(install_dir) }
          end
        end

        context 'when service already defined' do
          let(:pre_condition) do
            'service{"grafana":
              ensure     => running,
              name       => "grafana-server",
              hasrestart => true,
              hasstatus  => true,
            }'
          end

          describe 'do NOT run service' do
            it { is_expected.not_to contain_service('grafana').with_hasrestart(false).with_hasstatus(false) }
          end
        end
      end

      context 'with cfg unset' do
        it { is_expected.to contain_file('grafana.ini').with_content("# This file is managed by Puppet, any changes will be overwritten\n\n") }
      end

      context 'with cfg' do
        let(:cfg_hash) do
          {
            'app_mode' => 'production',
            'section' => {
              'string' => 'production',
              'number' => 8080,
              'boolean' => false,
              'empty' => '',
            },
          }
        end

        let(:cfg_toml) do
          # Using variable here to workaround formatters stripping trailing
          # spaces in the heredoc below
          empty = ''
          <<~CONTEXT
            # This file is managed by Puppet, any changes will be overwritten

            app_mode = production

            [section]
            boolean = false
            empty = #{empty}
            number = 8080
            string = production
          CONTEXT
        end

        context 'when Hash' do
          let(:params) { { cfg: cfg_hash } }

          it { is_expected.to contain_file('grafana.ini').with_content(cfg_toml) }
        end

        context 'when Sensitive[Hash]' do
          let(:params) { { cfg: sensitive(cfg_hash) } }

          it { is_expected.to contain_file('grafana.ini').with_content(sensitive(cfg_toml)) }
        end
      end

      context 'with ldap_cfg' do
        let(:ldap_hash) do
          {
            'servers' => [
              {
                'host' => 'server1a server1b',
                'use_ssl' => true,
                'search_filter' => '(sAMAccountName=%s)',
                'search_base_dns' => ['dc=domain1,dc=com'],
                'attributes' => {
                  'name' => 'givenName',
                  'surname' => 'sn',
                  'username' => 'sAMAccountName',
                  'member_of' => 'memberOf',
                  'email' => 'mail',
                },
                'group_mappings' => [
                  {
                    'group_dn' => 'cn=grafana_viewers,ou=groups,dc=domain1,dc=com',
                    'org_role' => 'Viewer',
                  },
                ],
              },
              {
                'host' => 'server2a server2b',
                'use_ssl' => true,
                'search_filter' => '(sAMAccountName=%s)',
                'search_base_dns' => ['dc=domain2,dc=com'],
                'attributes' => {
                  'name' => 'givenName',
                  'surname' => 'sn',
                  'username' => 'sAMAccountName',
                  'member_of' => 'memberOf',
                  'email' => 'mail',
                },
                'group_mappings' => [
                  {
                    'group_dn' => 'cn=grafana_admins,ou=groups,dc=domain2,dc=com',
                    'org_role' => 'Admin',
                    'grafana_admin' => true,
                  },
                ],
              },
            ],
          }
        end

        let(:ldap_toml) do
          <<~CONTEXT
            [[servers]]
            host = "server1a server1b"
            search_base_dns = ["dc=domain1,dc=com"]
            search_filter = "(sAMAccountName=%s)"
            use_ssl = true
            [servers.attributes]
            email = "mail"
            member_of = "memberOf"
            name = "givenName"
            surname = "sn"
            username = "sAMAccountName"
            [[servers.group_mappings]]
            group_dn = "cn=grafana_viewers,ou=groups,dc=domain1,dc=com"
            org_role = "Viewer"
            [[servers]]
            host = "server2a server2b"
            search_base_dns = ["dc=domain2,dc=com"]
            search_filter = "(sAMAccountName=%s)"
            use_ssl = true
            [servers.attributes]
            email = "mail"
            member_of = "memberOf"
            name = "givenName"
            surname = "sn"
            username = "sAMAccountName"
            [[servers.group_mappings]]
            grafana_admin = true
            group_dn = "cn=grafana_admins,ou=groups,dc=domain2,dc=com"
            org_role = "Admin"
          CONTEXT
        end

        context 'when Hash' do
          let(:params) { { ldap_cfg: ldap_hash } }

          it { is_expected.to contain_file('/etc/grafana/ldap.toml').with_content(ldap_toml) }
        end

        context 'when Sensitive[Hash]' do
          let(:params) { { ldap_cfg: sensitive(ldap_hash) } }

          it { is_expected.to contain_file('/etc/grafana/ldap.toml').with_content(sensitive(ldap_toml)) }
        end
      end

      context 'provisioning_dashboards defined' do
        let(:params) do
          {
            version: '11.0.0',
            provisioning_dashboards: {
              apiVersion: 1,
              providers: [
                {
                  name: 'default',
                  orgId: 1,
                  folder: '',
                  type: 'file',
                  disableDeletion: true,
                  options: {
                    path: '/var/lib/grafana/dashboards',
                    puppetsource: 'puppet:///modules/my_custom_module/dashboards',
                  },
                },
              ],
            },
          }
        end

        it do
          expect(subject).to contain_file('/var/lib/grafana/dashboards').with(
            ensure: 'directory',
            owner: 'grafana',
            group: 'grafana',
            mode: '0750',
            recurse: true,
            purge: true,
            source: 'puppet:///modules/my_custom_module/dashboards',
          )
        end

        context 'without puppetsource defined' do
          let(:params) do
            {
              version: '11.0.0',
              provisioning_dashboards: {
                apiVersion: 1,
                providers: [
                  {
                    name: 'default',
                    orgId: 1,
                    folder: '',
                    type: 'file',
                    disableDeletion: true,
                    options: {
                      path: '/var/lib/grafana/dashboards',
                    },
                  },
                ],
              },
            }
          end

          it { is_expected.not_to contain_file('/var/lib/grafana/dashboards') }
        end
      end

      context 'provisioning_datasources defined' do
        let(:params) do
          {
            version: '11.0.0',
            provisioning_datasources: {
              apiVersion: 1,
              datasources: [
                {
                  name: 'Prometheus',
                  type: 'prometheus',
                  access: 'proxy',
                  url: 'http://localhost:9090/',
                  isDefault: true,
                },
              ],
            },
          }
        end

        it do
          puppetprovisioned_datasources_path = case facts[:os]['family']
                                               when 'FreeBSD'
                                                 '/usr/local/etc/grafana/provisioning/datasources/puppetprovisioned.yaml'
                                               else
                                                 '/etc/grafana/provisioning/datasources/puppetprovisioned.yaml'
                                               end

          expect(subject).to contain_file(puppetprovisioned_datasources_path).with(
            ensure: 'file',
            owner: 'grafana',
            group: 'grafana',
            mode: '0640',
          )
        end
      end

      context 'sysconfig environment variables' do
        let(:params) do
          {
            install_method: 'repo',
            sysconfig: { http_proxy: 'http://proxy.example.com/' },
          }
        end

        case facts[:os]['family']
        when 'Debian'
          describe 'Add the environment variable to the config file' do
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_context('/files/etc/default/grafana-server') }
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_changes(['set http_proxy http://proxy.example.com/']) }
          end
        when 'RedHat'
          describe 'Add the environment variable to the config file' do
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_context('/files/etc/sysconfig/grafana-server') }
            it { is_expected.to contain_augeas('sysconfig/grafana-server').with_changes(['set http_proxy http://proxy.example.com/']) }
          end
        end
      end
    end
  end
end

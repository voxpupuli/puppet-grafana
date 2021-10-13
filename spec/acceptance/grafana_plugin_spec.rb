# frozen_string_literal: true

require 'spec_helper_acceptance'

supported_versions.each do |grafana_version|
  describe "grafana_plugin with Grafana version #{grafana_version}" do
    context 'create plugin resource' do
      it 'runs successfully' do
        pp = <<-EOS
        class { 'grafana':
          version => "#{grafana_version}"
        }
        include grafana::validator
        grafana_plugin { 'grafana-simple-json-datasource': }
        EOS
        prepare_host

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'has the plugin' do
        shell('grafana-cli plugins ls') do |r|
          expect(r.stdout).to match(%r{grafana-simple-json-datasource})
        end
      end
    end

    context 'create plugin resource with repo' do
      it 'runs successfully' do
        pp = <<-EOS
        class { 'grafana':
          version => "#{grafana_version}"
        }
        include grafana::validator
        grafana_plugin { 'grafana-simple-json-datasource':
          ensure => present,
          repo   => 'https://nexus.company.com/grafana/plugins',
        }
        EOS
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'has the plugin' do
        shell('grafana-cli plugins ls') do |r|
          expect(r.stdout).to match(%r{grafana-simple-json-datasource})
        end
      end
    end

    context 'create plugin resource with url' do
      it 'runs successfully' do
        # Reset and reinstall the same plugin by URL
        shell('grafana-cli plugins uninstall grafana-simple-json-datasource')
        pp = <<-EOS
        class { 'grafana':
          version => "#{grafana_version}"
        }
        include grafana::validator
        grafana_plugin { 'grafana-simple-json-datasource':
          ensure     => 'present',
          plugin_url => 'https://grafana.com/api/plugins/grafana-simple-json-datasource/versions/latest/download',
        }
        EOS
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'has the plugin' do
        shell('grafana-cli plugins ls') do |r|
          expect(r.stdout).to match(%r{grafana-simple-json-datasource})
        end
      end
    end

    context 'destroy plugin resource' do
      it 'runs successfully' do
        pp = <<-EOS
        class { 'grafana':
          version => "#{grafana_version}"
        }
        include grafana::validator
        grafana_plugin { 'grafana-simple-json-datasource':
          ensure => absent,
        }
        EOS
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'does not have the plugin' do
        shell('grafana-cli plugins ls') do |r|
          expect(r.stdout).not_to match(%r{grafana-simple-json-datasource})
        end
      end
    end

    context 'grafana plugins' do
      it 'installs specific version' do
        pp = <<-EOS
        class { 'grafana':
          version => "#{grafana_version}"
        }

        package { 'grafana-simple-json-datasource':
          ensure   => '1.4.0',
          provider => 'grafana',
        }
        EOS
        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'does have the plugin with specific version' do
        shell('grafana-cli plugins ls') do |r|
          expect(r.stdout).to match(%r{grafana-simple-json-datasource})
          expect(r.stdout).to match(%r{1\.4\.0})
        end
      end

      describe service('grafana-server') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end
  end
end

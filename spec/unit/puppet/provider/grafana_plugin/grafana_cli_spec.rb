# frozen_string_literal: true

require 'spec_helper'

provider_class = Puppet::Type.type(:grafana_plugin).provider(:grafana_cli)
describe provider_class do
  let(:provider_file) do
    File.expand_path('../../../../../lib/puppet/provider/grafana_plugin/grafana_cli.rb', __dir__)
  end

  let(:resource) do
    Puppet::Type::Grafana_plugin.new(
      name: 'grafana-wizzle',
    )
  end
  let(:provider) { provider_class.new(resource) }

  describe '#instances' do
    let(:plugins_ls_two) do
      <<~PLUGINS
        installed plugins:
        grafana-simple-json-datasource @ 1.3.4
        jdbranham-diagram-panel @ 1.4.0

        Restart grafana after installing plugins . <service grafana-server restart>
      PLUGINS
    end
    let(:plugins_ls_none) do
      <<~PLUGINS

        Restart grafana after installing plugins . <service grafana-server restart>

      PLUGINS
    end

    it 'has the correct names' do
      allow(provider_class).to receive(:grafana_cli).with('plugins', 'ls').and_return(plugins_ls_two)
      instances = provider_class.instances
      expect(instances.map(&:name)).to match_array(%w[grafana-simple-json-datasource jdbranham-diagram-panel])
      expect(instances.find { |plugin| plugin.name == 'grafana-simple-json-datasource' }.ensure).to eq('1.3.4')
      expect(provider_class).to have_received(:grafana_cli).once
    end

    it 'does not match if there are no plugins' do
      allow(provider_class).to receive(:grafana_cli).with('plugins', 'ls').and_return(plugins_ls_none)
      expect(provider_class.instances.size).to eq(0)
      expect(provider.exists?).to eq(false)
      expect(provider_class).to have_received(:grafana_cli).twice
    end

    it 'normalizes trailing whitespace in plugin versions' do
      plugins_ls_with_whitespace = "installed plugins:\ngrafana-simple-json-datasource @ 1.3.4   \n"
      allow(provider_class).to receive(:grafana_cli).with('plugins', 'ls').and_return(plugins_ls_with_whitespace)

      instances = provider_class.instances
      expect(instances.find { |plugin| plugin.name == 'grafana-simple-json-datasource' }.ensure).to eq('1.3.4')
    end

    it 'parses plugin version when grafana adds extra trailing metadata' do
      plugins_ls_with_metadata = "installed plugins:\nvertamedia-clickhouse-datasource @ 3.4.8 (unsigned)\n"
      allow(provider_class).to receive(:grafana_cli).with('plugins', 'ls').and_return(plugins_ls_with_metadata)

      instances = provider_class.instances
      expect(instances.find { |plugin| plugin.name == 'vertamedia-clickhouse-datasource' }.ensure).to eq('3.4.8')
    end

    it 'parses plugin lines with leading whitespace' do
      plugins_ls_with_indent = "installed plugins:\n  vertamedia-clickhouse-datasource @ 3.4.8\n"
      allow(provider_class).to receive(:grafana_cli).with('plugins', 'ls').and_return(plugins_ls_with_indent)

      instances = provider_class.instances
      expect(instances.find { |plugin| plugin.name == 'vertamedia-clickhouse-datasource' }.ensure).to eq('3.4.8')
    end
  end

  describe '#exists?' do
    let(:resource) do
      Puppet::Type::Grafana_plugin.new(
        name: 'grafana-wizzle',
        ensure: '1.4.0',
      )
    end

    it 'matches when installed version has trailing whitespace' do
      provider.instance_variable_set(:@property_hash, ensure: "1.4.0\r")
      expect(provider.exists?).to eq(true)
    end

    it 'matches desired version when property hash is present but list reports version' do
      provider.instance_variable_set(:@property_hash, ensure: :present)
      allow(provider_class).to receive(:all_plugins).and_return('grafana-wizzle' => '1.4.0')
      expect(provider.exists?).to eq(true)
    end
  end

  it '#create' do
    allow(provider).to receive(:grafana_cli)
    provider.create
    expect(provider).to have_received(:grafana_cli).with('plugins', 'install', 'grafana-wizzle')
  end

  describe '#create with version in ensure' do
    let(:resource) do
      Puppet::Type::Grafana_plugin.new(
        name: 'grafana-wizzle',
        ensure: '1.4.0',
      )
    end

    it 'installs specific plugin version' do
      allow(provider).to receive(:grafana_cli)
      provider.create
      expect(provider).to have_received(:grafana_cli).with('plugins', 'install', 'grafana-wizzle', '1.4.0')
    end
  end

  it '#destroy' do
    allow(provider).to receive(:grafana_cli)
    provider.destroy
    expect(provider).to have_received(:grafana_cli).with('plugins', 'uninstall', 'grafana-wizzle')
  end

  describe 'create with repo' do
    let(:resource) do
      Puppet::Type::Grafana_plugin.new(
        name: 'grafana-plugin',
        repo: 'https://nexus.company.com/grafana/plugins',
      )
    end

    it '#create with repo' do
      allow(provider).to receive(:grafana_cli)
      provider.create
      expect(provider).to have_received(:grafana_cli).with('--repo', 'https://nexus.company.com/grafana/plugins', 'plugins', 'install', 'grafana-plugin')
    end
  end

  describe 'create with repo and version in ensure' do
    let(:resource) do
      Puppet::Type::Grafana_plugin.new(
        name: 'grafana-plugin',
        repo: 'https://nexus.company.com/grafana/plugins',
        ensure: '1.4.0',
      )
    end

    it 'installs specific version from repo' do
      allow(provider).to receive(:grafana_cli)
      provider.create
      expect(provider).to have_received(:grafana_cli).with('--repo', 'https://nexus.company.com/grafana/plugins', 'plugins', 'install', 'grafana-plugin', '1.4.0')
    end
  end

  describe 'create with plugin url' do
    let(:resource) do
      Puppet::Type::Grafana_plugin.new(
        name: 'grafana-simple-json-datasource',
        plugin_url: 'https://grafana.com/api/plugins/grafana-simple-json-datasource/versions/latest/download',
      )
    end

    it '#create with plugin url' do
      allow(provider).to receive(:grafana_cli)
      provider.create
      expect(provider).to have_received(:grafana_cli).with('--pluginUrl', 'https://grafana.com/api/plugins/grafana-simple-json-datasource/versions/latest/download', 'plugins', 'install', 'grafana-simple-json-datasource')
    end
  end

  describe 'provider suitability' do
    it 'is suitable when grafana-cli is unavailable' do
      allow(Puppet::Util).to receive(:which).and_call_original
      allow(Puppet::Util).to receive(:which).with('grafana-cli').and_return(nil)

      load provider_file

      expect(Puppet::Type.type(:grafana_plugin).provider(:grafana_cli).suitable?).to be(true)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
describe Puppet::Type.type(:grafana_plugin) do
  let(:plugin) do
    Puppet::Type.type(:grafana_plugin).new(name: 'grafana-whatsit')
  end

  it 'accepts a plugin name' do
    plugin[:name] = 'plugin-name'
    expect(plugin[:name]).to eq('plugin-name')
  end

  it 'requires a name' do
    expect do
      Puppet::Type.type(:grafana_plugin).new({})
    end.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'accepts a plugin repo' do
    plugin[:repo] = 'https://nexus.company.com/grafana/plugins'
    expect(plugin[:repo]).to eq('https://nexus.company.com/grafana/plugins')
  end

  it 'accepts a plugin url' do
    plugin[:plugin_url] = 'https://grafana.com/api/plugins/grafana-simple-json-datasource/versions/latest/download'
    expect(plugin[:plugin_url]).to eq('https://grafana.com/api/plugins/grafana-simple-json-datasource/versions/latest/download')
  end

  it 'accepts ensure as version' do
    plugin[:ensure] = '1.4.0'
    expect(plugin[:ensure]).to eq('1.4.0')
  end

  describe 'custom ensure behavior' do
    it 'retrieves installed version from provider' do
      plugin[:ensure] = '1.4.0'
      provider = instance_double(Puppet::Type.type(:grafana_plugin).provider(:grafana_cli), installed_version: '1.4.0')
      allow(plugin).to receive(:provider).and_return(provider)

      expect(plugin.property(:ensure).retrieve).to eq('1.4.0')
    end

    it 'retrieves absent when no installed version is found' do
      provider = instance_double(Puppet::Type.type(:grafana_plugin).provider(:grafana_cli), installed_version: nil)
      allow(plugin).to receive(:provider).and_return(provider)

      expect(plugin.property(:ensure).retrieve).to eq(:absent)
    end

    it 'treats ensure present as in sync when any version is installed' do
      plugin[:ensure] = :present
      expect(plugin.property(:ensure).insync?('3.4.8')).to be(true)
    end

    it 'treats ensure version as not in sync when current value is present symbol' do
      plugin[:ensure] = '1.4.0'
      expect(plugin.property(:ensure).insync?(:present)).to be(false)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:grafana_team) do
  let(:gteam) do
    described_class.new(
      name: 'foo',
      grafana_url: 'http://example.com',
      grafana_user: 'admin',
      grafana_password: 'admin',
      home_dashboard_folder: 'bar',
      home_dashboard: 'foo_dashboard',
      organization: 'foo_organization',
    )
  end

  context 'when setting parameters' do
    it "fails if grafana_url isn't HTTP-based" do
      expect do
        described_class.new name: 'foo', grafana_url: 'example.com', content: '{}', ensure: :present
      end.to raise_error(Puppet::Error, %r{not a valid URL})
    end

    it 'accepts valid parameters' do
      expect(gteam[:name]).to eq('foo')
      expect(gteam[:grafana_user]).to eq('admin')
      expect(gteam[:grafana_password]).to eq('admin')
      expect(gteam[:grafana_url]).to eq('http://example.com')
      expect(gteam[:home_dashboard_folder]).to eq('bar')
      expect(gteam[:home_dashboard]).to eq('foo_dashboard')
      expect(gteam[:organization]).to eq('foo_organization')
    end

    it 'autorequires the grafana-server for proper ordering' do
      catalog = Puppet::Resource::Catalog.new
      service = Puppet::Type.type(:service).new(name: 'grafana-server')
      catalog.add_resource service
      catalog.add_resource gteam

      relationship = gteam.autorequire.find do |rel|
        (rel.source.to_s == 'Service[grafana-server]') && (rel.target.to_s == gteam.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end

    it 'does not autorequire the service it is not managed' do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource gteam
      expect(gteam.autorequire).to be_empty
    end

    it 'autorequires grafana_conn_validator' do
      catalog = Puppet::Resource::Catalog.new
      validator = Puppet::Type.type(:grafana_conn_validator).new(name: 'grafana')
      catalog.add_resource validator
      catalog.add_resource gteam

      relationship = gteam.autorequire.find do |rel|
        (rel.source.to_s == 'Grafana_conn_validator[grafana]') && (rel.target.to_s == gteam.to_s)
      end
      expect(relationship).to be_a Puppet::Relationship
    end
  end

  context 'when grafana_password is marked sensitive' do
    it 'marks the grafana_password parameter sensitive and does not warn' do
      logs = []
      team = nil
      Puppet::Util::Log.with_destination(Puppet::Test::LogCollector.new(logs)) do
        team = described_class.new(
          name: 'foo', grafana_url: 'http://example.com', grafana_password: 'admin',
          sensitive_parameters: [:grafana_password]
        )
      end

      expect(team.parameter(:grafana_password).sensitive).to be true
      expect(team[:grafana_password]).to eq('admin')
      expect(logs.map(&:message)).not_to include(match(%r{Unable to mark}))
    end

    it 'does not mark the grafana_password parameter sensitive when not requested' do
      team = described_class.new(name: 'foo', grafana_url: 'http://example.com', grafana_password: 'admin')

      expect(team.parameter(:grafana_password).sensitive).to be_falsey
    end
  end
end

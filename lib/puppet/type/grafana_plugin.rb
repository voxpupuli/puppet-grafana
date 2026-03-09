# frozen_string_literal: true

Puppet::Type.newtype(:grafana_plugin) do
  desc <<~DESC
    manages grafana plugins

    @example Install a grafana plugin
     grafana_plugin { 'grafana-simple-json-datasource': }

    @example Install a grafana plugin from different repo
     grafana_plugin { 'grafana-simple-json-datasource':
       ensure => 'present',
       repo   => 'https://nexus.company.com/grafana/plugins',
     }

    @example Install a grafana plugin from a plugin url
     grafana_plugin { 'grafana-example-custom-plugin':
       ensure     => 'present',
       plugin_url => 'https://github.com/example/example-custom-plugin/zipball/v1.0.0'
     }

    @example Install a specific version of a grafana plugin
     grafana_plugin { 'grafana-simple-json-datasource':
       ensure => '1.4.0',
     }

    @example Uninstall a grafana plugin
     grafana_plugin { 'grafana-simple-json-datasource':
       ensure => 'absent',
     }

    @example Show resources
     $ puppet resource grafana_plugin
  DESC

  newproperty(:ensure) do
    desc 'Whether the plugin should be present, absent, or pinned to a specific version.'

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    newvalue(%r{^\d[0-9A-Za-z.+-]*$}) do
      provider.create
    end

    def retrieve
      version = provider.installed_version
      return :absent if version.nil? || version.empty?

      version
    end

    def insync?(is)
      desired = should.is_a?(Array) ? should.first : should

      return is != :absent if desired == :present
      return is == :absent if desired == :absent

      is.to_s.strip == desired.to_s.strip
    end
  end

  newparam(:name, namevar: true) do
    desc 'The name of the plugin to enable'
    newvalues(%r{^\S+$})
  end

  newparam(:repo) do
    desc 'The URL of an internal plugin server'
    validate do |value|
      raise ArgumentError, format('%s is not a valid URL', value) unless value =~ %r{^https?://}
    end
  end

  newparam(:plugin_url) do
    desc 'Full url to the plugin zip file'
    validate do |value|
      raise ArgumentError, format('%s is not a valid URL', value) unless value =~ %r{^https?://}
    end
  end
end

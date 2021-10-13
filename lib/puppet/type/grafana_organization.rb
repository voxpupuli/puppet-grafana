Puppet::Type.newtype(:grafana_organization) do
  @doc = 'Manage organizations in Grafana'

  ensurable

  newparam(:name, namevar: true) do
    desc 'The name of the organization.'

    validate do |value|
      raise ArgumentError, format('Unable to modify default organization') if value == 'Main Org.'
    end
  end

  newparam(:grafana_api_path) do
    desc 'The absolute path to the API endpoint'
    defaultto '/api'

    validate do |value|
      unless value =~ %r{^/.*/?api$}
        raise ArgumentError, format('%s is not a valid API path', value)
      end
    end
  end

  newparam(:grafana_url) do
    desc 'The URL of the Grafana server'
    defaultto ''

    validate do |value|
      unless value =~ %r{^https?://}
        raise ArgumentError, format('%s is not a valid URL', value)
      end
    end
  end

  newparam(:grafana_user) do
    desc 'The username for the Grafana server'
  end

  newparam(:grafana_password) do
    desc 'The password for the Grafana server'
  end

  newproperty(:id) do
    desc 'The ID of the organization'
  end

  newproperty(:address) do
    desc 'Additional JSON data to configure the organization address (optional)'

    validate do |value|
      unless value.nil? || value.is_a?(Hash)
        raise ArgumentError, 'address should be a Hash!'
      end
    end
  end
  autorequire(:service) do
    'grafana-server'
  end

  autorequire(:grafana_conn_validator) do
    'grafana'
  end
end

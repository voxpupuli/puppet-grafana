# frozen_string_literal: true

Puppet::Type.type(:grafana_plugin).provide(:grafana_cli) do
  has_command(:grafana_cli, 'grafana-cli') do
    is_optional
  end

  defaultfor feature: :posix

  mk_resource_methods

  def self.parse_plugin_line(line)
    return nil unless line.include?('@')

    name, raw_version = line.strip.split(%r{\s+@\s+}, 2)
    return nil if name.nil? || raw_version.nil?

    version = raw_version.strip.split(%r{\s+}, 2).first
    return nil if version.nil? || version.empty?

    [name, version]
  end

  def self.all_plugins
    plugins = {}
    output = begin
      grafana_cli('plugins', 'ls')
    rescue Puppet::Error, Puppet::ExecutionFailure => e
      Puppet.debug("Unable to query grafana plugins: #{e.message}")
      nil
    end
    return plugins if output.nil?

    output.split(%r{\n}).each do |line|
      parsed = parse_plugin_line(line)
      next unless parsed

      name, version = parsed
      Puppet.debug("Found grafana plugin #{name} #{version}")
      plugins[name] = version
    end
    plugins
  end

  def self.instances
    resources = []
    all_plugins.each do |name, version|
      plugin = {
        ensure: version,
        name: name,
      }
      resources << new(plugin) if plugin[:name]
    end
    resources
  end

  def self.prefetch(resources)
    plugins = instances
    resources.each_key do |name|
      if (provider = plugins.find { |plugin| plugin.name == name })
        resources[name].provider = provider
      end
    end
  end

  def installed_version
    version = @property_hash[:ensure]
    normalized = version.to_s.strip
    return normalized unless normalized.empty? || normalized == 'present' || normalized == 'absent'

    detected = self.class.all_plugins[resource[:name]]
    detected&.to_s&.strip
  end

  def exists?
    version = installed_version
    return false if version.nil? || version.empty?

    return true if resource[:ensure] == :present

    version == resource[:ensure].to_s.strip
  end

  def create
    version = resource[:ensure] unless resource[:ensure].is_a?(Symbol)

    cmd = ['plugins', 'install', resource[:name]]
    if resource[:repo]
      cmd.unshift('--repo', resource[:repo])
    elsif resource[:plugin_url]
      cmd.unshift('--pluginUrl', resource[:plugin_url])
    end
    cmd << version if version
    begin
      grafana_cli(*cmd)
    rescue Puppet::Error, Puppet::ExecutionFailure => e
      Puppet.debug("Unable to install grafana plugin #{resource[:name]}: #{e.message}")
      return
    end

    @property_hash[:ensure] = version || :present
  end

  def destroy
    begin
      grafana_cli('plugins', 'uninstall', resource[:name])
    rescue Puppet::Error, Puppet::ExecutionFailure => e
      Puppet.debug("Unable to uninstall grafana plugin #{resource[:name]}: #{e.message}")
      return
    end

    @property_hash[:ensure] = :absent
  end
end

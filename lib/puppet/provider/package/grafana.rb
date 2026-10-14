# frozen_string_literal: true

require 'puppet/provider/package'

Puppet::Type.type(:package).provide :grafana, parent: Puppet::Provider::Package do
  desc 'This provider only handles grafana plugins.'

  has_feature :installable, :install_options, :uninstallable, :upgradeable, :versionable

  has_command(:grafana, 'grafana') do
    is_optional
  end

  def self.parse_plugin_line(line)
    return nil unless line.include?('@')

    name, raw_version = line.strip.split(%r{\s+@\s+}, 2)
    return nil if name.nil? || raw_version.nil?

    version = raw_version.strip.split(%r{\s+}, 2).first
    return nil if version.nil? || version.empty?

    [name, version]
  end

  def self.pluginslist
    plugins = {}
    if command(:grafana)
      grafana('cli', 'plugins', 'ls').split(%r{\n}).each do |line|
        parsed = parse_plugin_line(line)
        next unless parsed

        name, version = parsed
        Puppet.debug("Found grafana plugin #{name} #{version}")
        plugins[name] = version
      end
    else
      Puppet.debug('No grafana_cli command found')
    end
    plugins
  end

  def self.instances
    pluginslist.map do |k, v|
      new(name: k, ensure: v, provider: 'grafana')
    end
  end

  def query
    plugins = self.class.pluginslist

    if plugins.key?(resource[:name])
      { ensure: plugins[resource[:name]], name: resource[:name] }
    else
      { ensure: :absent, name: resource[:name] }
    end
  end

  def latest
    output = begin
      grafana('cli', 'plugins', 'list-versions', resource[:name])
    rescue Puppet::Error, Puppet::ExecutionFailure => e
      Puppet.debug("Unable to query grafana plugin versions for #{resource[:name]}: #{e.message}")
      nil
    end
    return nil if output.nil?

    output.lines.first&.strip
  end

  def update
    plugins = self.class.pluginslist

    if plugins.key?(resource[:name])
      cmd = %w[plugins update]
      cmd << install_options if resource[:install_options]
      cmd << resource[:name]
      begin
        grafana('cli', *cmd)
      rescue Puppet::Error, Puppet::ExecutionFailure => e
        Puppet.debug("Unable to update grafana plugin #{resource[:name]}: #{e.message}")
      end
    else
      install
    end
  end

  def install
    cmd = %w[plugins install]
    cmd << install_options if resource[:install_options]
    cmd << resource[:name]
    cmd << resource[:ensure] unless resource[:ensure].is_a? Symbol

    begin
      grafana('cli', *cmd)
    rescue Puppet::Error, Puppet::ExecutionFailure => e
      Puppet.debug("Unable to install grafana plugin #{resource[:name]}: #{e.message}")
    end
  end

  def install_options
    join_options(resource[:install_options])
  end

  def uninstall
    if command(:grafana)
      grafana('cli', 'plugins', 'uninstall', resource[:name])
    else
      Puppet.debug("No grafana_cli command found, unable to uninstall grafana plugin #{resource[:name]}")
    end
  end
end

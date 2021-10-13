# frozen_string_literal: true

require 'puppet/provider/package'

Puppet::Type.type(:package).provide :grafana, parent: Puppet::Provider::Package do
  desc 'This provider only handles grafana plugins.'

  has_feature :installable, :install_options, :uninstallable, :upgradeable, :versionable

  has_command(:grafana_cli, 'grafana-cli') do
    is_optional
  end

  def self.pluginslist
    plugins = {}

    grafana_cli('plugins', 'ls').split(%r{\n}).each do |line|
      next unless line =~ %r{^(\S+)\s+@\s+((?:\d\.).+)\s*$}

      name = Regexp.last_match(1)
      version = Regexp.last_match(2)
      plugins[name] = version
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
    grafana_cli('plugins', 'list-versions', resource[:name]).lines.first.strip
  end

  def update
    cmd = %w[plugins update]
    cmd << install_options if resource[:install_options]
    cmd << resource[:name]

    grafana_cli(*cmd)
  end

  def install
    cmd = %w[plugins install]
    cmd << install_options if resource[:install_options]
    cmd << resource[:name]
    cmd << resource[:ensure] unless resource[:ensure].is_a? Symbol

    grafana_cli(*cmd)
  end

  def install_options
    join_options(resource[:install_options])
  end

  def uninstall
    grafana_cli('plugins', 'uninstall', resource[:name])
  end
end

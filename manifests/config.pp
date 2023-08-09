# @summary Manage grafana configuration
#
# @api private
class grafana::config {
  if $grafana::cfg =~ Sensitive {
    $cfg = $grafana::cfg.unwrap
    $cfg_content = Sensitive(template('grafana/config.ini.erb'))
  } else {
    $cfg = $grafana::cfg
    $cfg_content = template('grafana/config.ini.erb')
  }

  case $grafana::install_method {
    'docker': {
      if $grafana::container_cfg {
        $myprovision = false

        file { 'grafana.ini':
          ensure  => file,
          path    => $grafana::cfg_location,
          content => $cfg_content,
          owner   => 'grafana',
          group   => 'grafana',
          notify  => Class['grafana::service'],
        }
      }
    }
    'package','repo': {
      $myprovision = true

      file { 'grafana.ini':
        ensure  => file,
        path    => $grafana::cfg_location,
        content => $cfg_content,
        owner   => 'root',
        group   => 'grafana',
        notify  => Class['grafana::service'],
      }

      $sysconfig = $grafana::sysconfig
      $sysconfig_location = $grafana::sysconfig_location

      if $sysconfig_location and $sysconfig {
        $changes = $sysconfig.map |$key, $value| { "set ${key} ${value}" }

        augeas { 'sysconfig/grafana-server':
          context => "/files${sysconfig_location}",
          changes => $changes,
          notify  => Class['grafana::service'],
        }
      }

      file { "${grafana::data_dir}/plugins":
        ensure => directory,
        owner  => 'grafana',
        group  => 'grafana',
        mode   => '0750',
      }
    }
    'archive': {
      $myprovision = true

      file { "${grafana::install_dir}/conf/custom.ini":
        ensure  => file,
        content => $cfg_content,
        owner   => 'grafana',
        group   => 'grafana',
        notify  => Class['grafana::service'],
      }

      file { [$grafana::data_dir, "${grafana::data_dir}/plugins"]:
        ensure => directory,
        owner  => 'grafana',
        group  => 'grafana',
        mode   => '0750',
      }
    }
    default: {
      fail("Installation method ${grafana::install_method} not supported")
    }
  }

  if $grafana::ldap_cfg {
    # the additional \n after to_toml()` are not required. In the past the data was generated with the toml gem
    # (not the toml-rb gem)
    # That added the newline. To cause a tinier diff during the migration, we add it here as well.
    if $grafana::ldap_cfg =~ Sensitive {
      $ldap_cfg = $grafana::ldap_cfg.unwrap
      $ldap_cfg_toml = Sensitive($ldap_cfg.flatten.map |$data| { "${stdlib::to_toml($data)}\n" })
    } else {
      $ldap_cfg_toml = $grafana::ldap_cfg.flatten.map |$data| { "${stdlib::to_toml($data)}\n" }
    }

    file { '/etc/grafana/ldap.toml':
      ensure  => file,
      content => $ldap_cfg_toml.join("\n"),
      owner   => 'grafana',
      group   => 'grafana',
      notify  => Class['grafana::service'],
    }
  }

  # If grafana version is > 5.0.0, and the install method is package,
  # repo, or archive, then use the provisioning feature. Dashboards
  # and datasources are placed in
  # /etc/grafana/provisioning/[dashboards|datasources] by default.
  # --dashboards--
  if ((versioncmp($grafana::version, '5.0.0') >= 0) and ($myprovision)) {
    $pdashboards = $grafana::provisioning_dashboards
    if (length($pdashboards) >= 1 ) {
      $dashboardpaths = flatten(grafana::deep_find_and_remove('options', $pdashboards))
      # template uses:
      #   - pdashboards
      file { $grafana::provisioning_dashboards_file:
        ensure  => file,
        owner   => 'grafana',
        group   => 'grafana',
        mode    => '0640',
        content => epp('grafana/pdashboards.yaml.epp'),
        notify  => Class['grafana::service'],
      }
      # Loop over all providers, extract the paths and create
      # directories for each path of dashboards.
      $dashboardpaths.each | Integer $index, Hash $options | {
        if ('path' in $options) {
          # get sub paths of 'path' and create subdirs if necessary
          $subpaths = grafana::get_sub_paths($options['path'])
          if ($grafana::create_subdirs_provisioning and (length($subpaths) >= 1)) {
            file { $subpaths :
              ensure => directory,
              before => File[$options['path']],
            }
          }

          if $options['puppetsource'] {
            file { $options['path'] :
              ensure       => directory,
              owner        => 'grafana',
              group        => 'grafana',
              mode         => '0750',
              recurse      => true,
              purge        => true,
              source       => $options['puppetsource'],
              sourceselect => 'all',
            }
          }
        }
      }
    }

    # --datasources--
    $pdatasources = $grafana::provisioning_datasources
    if (length($pdatasources) >= 1) {
      # template uses:
      #   - pdatasources
      file { $grafana::provisioning_datasources_file:
        ensure    => file,
        owner     => 'grafana',
        group     => 'grafana',
        mode      => '0640',
        show_diff => false,
        content   => epp('grafana/pdatasources.yaml.epp'),
        notify    => Class['grafana::service'],
      }
    }
  }
}

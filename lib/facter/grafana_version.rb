# frozen_string_literal: true

Facter.add(:grafana_version) do
  confine { Facter::Util::Resolution.which('grafana-server') }

  setcode do
    version_path = '/usr/share/grafana/VERSION'
    File.read(version_path).strip if File.exist?(version_path)
  end
end

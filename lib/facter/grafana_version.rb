# frozen_string_literal: true

Facter.add(:grafana_version) do
  version_path = '/usr/share/grafana/VERSION'
  confine { File.exist?(version_path) }

  setcode do
    File.read(version_path).strip
  end
end

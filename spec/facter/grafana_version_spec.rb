# frozen_string_literal: true

require 'facter'

describe 'grafana_version' do
  before do
    Facter.clear
    allow(Facter::Util::Resolution).to receive(:which).with('grafana-server').and_return('/usr/sbin/grafana-server')
  end

  context 'when VERSION file exists' do
    it 'returns the version from the VERSION file' do
      version = '1.2.3'
      version_path = '/usr/share/grafana/VERSION'

      allow(File).to receive(:exist?).with(version_path).and_return(true)
      allow(File).to receive(:read).with(version_path).and_return(version)

      expect(Facter.fact(:grafana_version).value).to eq(version.strip)
    end
  end

  context 'when VERSION file does not exist' do
    it 'returns nil' do
      allow(File).to receive(:exist?).with('/usr/share/grafana/VERSION').and_return(false)

      expect(Facter.fact(:grafana_version).value).to be_nil
    end
  end
end

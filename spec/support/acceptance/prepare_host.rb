# frozen_string_literal: true

def prepare_host
  cleanup_script = <<-SHELL
  puppet resource package grafana ensure=purged
  puppet resource service grafana-service ensure=stopped enable=false
  rm -rf /var/lib/grafana /etc/grafana
  SHELL

  shell(cleanup_script)
end

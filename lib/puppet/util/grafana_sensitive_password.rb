# frozen_string_literal: true

module Puppet
  module Util
    # Mixin for grafana_* types whose only sensitive parameter is grafana_password.
    #
    # Puppet::Type#set_sensitive_parameters warns when a sensitive_parameters
    # entry resolves to a Puppet::Parameter (as opposed to a Puppet::Property),
    # since it can't auto-redact it. Marking the parameter sensitive here, then
    # forwarding the rest of the list to super, avoids that warning.
    module GrafanaSensitivePassword
      def set_sensitive_parameters(sensitive_parameters) # rubocop:disable Naming/AccessorMethodName
        parameter(:grafana_password).sensitive = true if sensitive_parameters.include?(:grafana_password)
        super(sensitive_parameters - [:grafana_password])
      end
    end
  end
end

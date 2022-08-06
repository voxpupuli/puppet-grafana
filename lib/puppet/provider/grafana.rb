# frozen_string_literal: true

#    Copyright 2015 Mirantis, Inc.
#
require 'json'
require 'net/http'

class Puppet::Provider::Grafana < Puppet::Provider
  # Helper methods
  def grafana_host
    @grafana_host ||= URI.parse(resource[:grafana_url]).host
    @grafana_host
  end

  def grafana_port
    @grafana_port ||= URI.parse(resource[:grafana_url]).port
    @grafana_port
  end

  def grafana_scheme
    @grafana_scheme ||= URI.parse(resource[:grafana_url]).scheme
    @grafana_scheme
  end

  # Return a Net::HTTP::Response object
  def send_request(operation = 'GET', path = '', data = nil, search_path = {})
    request = nil

    encoded_path = path.split('/').map { |p| URI.encode_www_form_component(p) }.join('/')
    encoded_search = URI.encode_www_form(search_path)

    uri = URI.parse format('%s://%s:%d%s?%s', grafana_scheme, grafana_host, grafana_port, encoded_path, encoded_search)

    case operation.upcase
    when 'POST'
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = data.to_json
    when 'PUT'
      request = Net::HTTP::Put.new(uri.request_uri)
      request.body = data.to_json
    when 'GET'
      request = Net::HTTP::Get.new(uri.request_uri)
    when 'DELETE'
      request = Net::HTTP::Delete.new(uri.request_uri)
    when 'PATCH'
      request = Net::HTTP::Patch.new(uri.request_uri)
      request.body = data.to_json
    else
      raise Puppet::Error, format('Unsupported HTTP operation %s', operation)
    end

    request.content_type = 'application/json'
    request.basic_auth resource[:grafana_user], resource[:grafana_password] if resource[:grafana_user] && resource[:grafana_password]

    Net::HTTP.start(grafana_host, grafana_port,
                    use_ssl: grafana_scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(request)
    end
  end
end

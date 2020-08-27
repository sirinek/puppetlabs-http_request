#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper'

require 'net/http'
require 'openssl'

class HTTPRequest < TaskHelper
  def task(**opts)
    # Get all of the request parameters in order...
    method   = opts[:method].capitalize.to_sym
    uri      = URI.parse(opts[:base_url]) + (opts[:path] || '')
    body     = opts[:body]
    headers  = opts[:headers] || {}
    ssl_opts = {
      cacert: opts[:cacert],
      cert:   opts[:cert],
      key:    opts[:key]
    }

    redirects = 0
    response  = nil

    # Make the request, following redirects if configured to do so.
    # If maximum number of redirects is exceeded, error.
    loop do
      response = request(method, uri, headers, body, ssl_opts)

      break unless response.is_a?(Net::HTTPRedirection) && opts[:follow_redirects]

      if redirects >= opts[:max_redirects]
        raise TaskHelper::Error.new(
          "Too many redirects (max: #{opts[:max_redirects]})",
          'http_request/too-many-redirects-error'
        )
      end

      redirects += 1
      uri = expand_redirect_url(response['location'], opts[:base_url])
    end

    # Return the body and status code of the response.
    {
      body:        encode_body(response.read_body, response.type_params['charset']),
      status_code: response.code.to_i
    }
  rescue TaskHelper::Error => e
    { _error: e.to_h }
  end

  private

  # Makes the actual request.
  def request(method, uri, headers, body, opts)
    # Create the client
    client = Net::HTTP.new(uri.host, uri.port)

    # Use SSL if requesting a secure connection
    if uri.scheme == 'https'
      client.use_ssl     = true
      client.verify_mode = OpenSSL::SSL::VERIFY_PEER
      client.ca_file     = opts[:cacert] if opts[:cacert]
      client.cert        = OpenSSL::X509::Certificate.new(File.read(opts[:cert])) if opts[:cert]
      client.key         = OpenSSL::PKey::RSA.new(opts[:key]) if opts[:key]
    end

    # Build the request
    request = Net::HTTP.const_get(method).new(uri.request_uri, headers)

    # Build the query if there's data to send
    request.body = body if body

    # Send the request
    client.request(request)
  rescue StandardError => e
    raise TaskHelper::Error.new(
      "Failed to connect to #{uri}: #{e.message}",
      'http_request/connect-error'
    )
  end

  # Forces the response body to the specified encoding and
  # then encodes as UTF-8.
  def encode_body(body, charset)
    body = body.force_encoding(charset) if charset
    body.encode('UTF-8')
  end

  # Parses the redirect URL and expands it relative to the
  # base URL if the redirect URL is relative.
  def expand_redirect_url(redirect_url, base_url)
    uri = URI.parse(redirect_url)
    uri = URI.parse(base_url) + redirect_url if uri.relative?
    uri
  end
end

if $PROGRAM_NAME == __FILE__
  HTTPRequest.run
end

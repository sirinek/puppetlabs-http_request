# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../tasks/init'

describe HTTPRequest do
  let(:url)          { 'http://0.0.0.0:80' }
  let(:success_keys) { %i[body status_code] }

  it 'can make a request' do
    opts = {
      method:   'get',
      base_url: "#{url}/get"
    }

    result = subject.task(opts)
    expect(result.keys).to match_array(success_keys)
    expect(result[:status_code]).to eq(200)
  end

  it 'joins the url and path' do
    opts = {
      method:   'post',
      base_url: url,
      path:     'post'
    }

    result = subject.task(opts)
    expect(result.keys).to match_array(success_keys)
    expect(result[:status_code]).to eq(200)
  end

  it 'encodes the response body as UTF-8' do
    opts = {
      method:   'get',
      base_url: 'https://www.google.com'
    }

    result = subject.task(opts)
    expect(result.keys).to match_array(success_keys)
    expect(result[:body].encoding).to eq(Encoding::UTF_8)
  end

  it 'follows redirects' do
    opts = {
      method:           'get',
      base_url:         "#{url}/redirect-to?url=#{url}/get",
      follow_redirects: true,
      max_redirects:    20
    }

    result = subject.task(opts)
    expect(result.keys).to match_array(success_keys)
  end

  it 'errors with too many redirects' do
    opts = {
      method:           'get',
      base_url:         "#{url}/absolute-redirect/5",
      follow_redirects: true,
      max_redirects:    3
    }

    result = subject.task(opts)
    expect(result.key?(:_error)).to be(true)
  end

  it 'errors if the body is not a String' do
    opts = {
      method:   'post',
      base_url: "#{url}/post",
      body:     { 'foo' => 'bar' }
    }

    result = subject.task(opts)
    expect(result.key?(:_error)).to be(true)
  end

  context 'json_endpoint' do
    let(:opts) do
      {
        method:        'get',
        base_url:      "#{url}/headers",
        json_endpoint: true
      }
    end

    it 'sets the Content-Type header to application/json' do
      result = subject.task(opts)
      expect(result.dig(:body, 'headers', 'Content-Type')).to eq('application/json')
    end

    it 'allows Content-Type to be overwritten' do
      opts.merge!(headers: { 'Content-Type' => 'text/plain' })
      result = subject.task(opts)
      expect(result.dig(:body, 'headers', 'Content-Type')).to eq('text/plain')
    end

    it 'formats body as JSON' do
      body = {
        'foo' => 'bar'
      }

      opts = {
        method:        'post',
        base_url:      "#{url}/anything",
        json_endpoint: true,
        body:          body
      }

      result = subject.task(opts)
      expect(result.dig(:body, 'json')).to eq(body)
    end
  end
end

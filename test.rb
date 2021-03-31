ENV["APP_ENV"] = "test"

require "./app"
require "minitest/autorun"
require "webmock/minitest"
require "rack/test"

class HelloWorldTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_health_check
    get "/health_check"
    assert last_response.ok?
    assert_equal "OK", last_response.body
  end

  def test_not_found
    get "/wrong/signature"
    assert last_response.not_found?
  end

  def test_proxy
    url = "http://example.com/image.jpg"
    content_type = "image/jpeg"
    signature = OpenSSL::HMAC.hexdigest("sha1", "secret", url)

    stub_request(:get, url).with(headers: {
      accept: "image/png,image/svg+xml,image/*"
    }).to_return({
      status: 200,
      body: "OK",
      headers: {content_type: content_type}
    })

    get "/#{signature}/#{hex_encode(url)}"
    assert last_response.ok?
    assert_equal content_type, last_response.get_header("Content-Type")
  end

  def test_wrong_content_type
    url = "http://example.com/image.jpg"
    signature = OpenSSL::HMAC.hexdigest("sha1", "secret", url)

    stub_request(:get, url).to_return({
      status: 500
    })

    get "/#{signature}/#{hex_encode(url)}"
    assert last_response.not_found?
  end

  def hex_encode(string)
    string.to_enum(:each_byte).map { |byte| "%02x" % byte }.join
  end
end

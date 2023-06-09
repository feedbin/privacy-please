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

    stub_request(:get, url)
      .to_return(status: 200, body: "", headers: {})

    signature = OpenSSL::HMAC.hexdigest("sha1", "secret", url)

    get "/#{signature}/#{hex_encode(url)}"

    assert last_response.ok?

    assert_equal(url, last_response.headers["X-Original-Image"])
  end

  def hex_encode(string)
    string.to_enum(:each_byte).map { |byte| "%02x" % byte }.join
  end
end

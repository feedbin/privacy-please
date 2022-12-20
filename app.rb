# frozen_string_literal: true

require "sinatra"
require "openssl"
require "addressable"
require "http"

def secret_key
  ENV.fetch("PRIVACY_KEY", "secret")
end

def hex_decode(string)
  string.scan(/../).map { |x| x.hex.chr }.join
end

def signature_valid?(signature, data)
  signature == OpenSSL::HMAC.hexdigest("sha1", secret_key, data)
end

def download(url)
  HTTP
    .follow(max_hops: 5)
    .timeout(connect: 30, write: 10, read: 30)
    .headers(accept: "image/png,image/svg+xml,image/*")
    .get(url)
end

def accel_redirect(url)
  parsed = Addressable::URI.heuristic_parse(url)

  headers("X-Original-Image" => parsed.to_s)

  halt(404) unless parsed.scheme =~ /^http/

  remainder = parsed.to_s.delete_prefix("#{parsed.scheme}://")
  redirect  = "/remote/#{parsed.scheme}/#{remainder}"

  headers("X-Accel-Redirect" => redirect)

  ""
end

get "/health_check" do
  "OK"
end

get "/:signature/:url" do
  url = hex_decode(params["url"])

  signature = params["signature"]

  halt(404) unless signature_valid?(signature, url)

  accel_redirect(url)
rescue => exception
  logger.error "Exception processing url=#{url} privacy_url=#{params["signature"]}/#{params["url"]}"
  raise exception
end

get "/redirect" do
  url = params["url"]
  new_location = download(url).uri.to_s
  accel_redirect(new_location)
rescue HTTP::StateError
  halt(404)
end

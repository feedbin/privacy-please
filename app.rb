# frozen_string_literal: true

require "sinatra"
require "http"
require "openssl"

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

get "/health_check" do
  "OK"
end

get "/:signature/:url" do
  url = hex_decode(params["url"])

  signature = params["signature"]

  halt(404) unless signature_valid?(signature, url)

  response = download(url)

  halt(404) unless response.status.ok?

  content_type = response.content_type.mime_type
  content_type = content_type&.start_with?("image/") ? content_type : "application/octet-stream"

  headers("Content-Type" => content_type)
  headers("Content-Length" => response.content_length) unless response.content_length.nil?
  headers("X-Content-Type-Options" => "nosniff")
  headers("X-Frame-Options" => "deny")
  headers("X-XSS-Protection" => "1; mode=block")
  headers("X-Original-Image" => url)
  expires(time_for(DateTime.now.next_year), :public)

  stream do |out|
    response.body.each do |chunk|
      out << chunk
      chunk.clear
    end
  end
rescue => exception
  logger.error "Exception processing url=#{url} privacy_url=#{params["signature"]}/#{params["url"]}"
  raise exception
end

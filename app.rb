require "sinatra"
require "http"
require "openssl"

def hex_decode(string)
  string.scan(/../).map { |x| x.hex.chr }.join
end

def secret_key
  ENV["PRIVACY_KEY"] || "secret"
end

def valid_signature?(signature, data)
  signature == signed(data)
end

def signed(data)
  OpenSSL::HMAC.hexdigest('sha1', secret_key, data)
end

def default_headers(content_type)
  {
    "Content-Type"            => content_type,
    "X-Frame-Options"         => "deny",
    "X-Frame-Options"         => "deny",
    "X-XSS-Protection"        => "1; mode=block",
    "X-Content-Type-Options"  => "nosniff",
    "Content-Security-Policy" => "default-src 'none'; img-src data:; style-src 'unsafe-inline'",
  }
end

get "/health_check" do
  "OK"
end

before "/:signature/:url" do
  signature = params["signature"]
  url = hex_decode(params["url"])
  if !valid_signature?(signature, url)
    logger.info "invalid signature given=#{signature} calculated=#{signed(url)} url=#{url}"
    halt 404
  end
end

get "/:signature/:url" do
  url = hex_decode(params["url"])
  response = HTTP.headers(accept: "image/png,image/svg+xml,image/*").get(url)
  mime_type = response.content_type.mime_type
  if response.status.ok? && mime_type.start_with?("image/")
    headers default_headers(mime_type)
    stream do |out|
      response.body.each {|chunk| out << chunk}
    end
  else
    halt 404
  end
end


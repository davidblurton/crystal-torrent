require "http/client"
require "digest"
require "uri"
require "./bemcoding"

module Torrent
  response = HTTP::Client.get "http://localhost:8000/pope.jpg.torrent"

  if response.status_code != 200
    puts "Couldn't get torrent"
    exit 1
  end

  response.body

  parser = Parser.new response.body
  tf = parser.decode()

  info = parser.info()

  digest = Digest::SHA1.digest(info)

  bs = digest.map {|d| d.chr.ascii? ? URI.escape(d.chr.to_s) : "%#{d.to_s(16)}"}.join

  url = case tf
    when Hash
    tf["announce"].to_s
  end

  if url
  	endpoint = "#{url}?info_hash=#{bs}&peer_id=torrlang10axeltest10&port=6881&compact=1&downloaded=0&event=started&uploaded=0"
    HTTP::Client.get endpoint
  end
end

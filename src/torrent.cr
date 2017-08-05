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
  puts parser.decode().pretty_inspect()

  info = parser.info()

  digest = Digest::SHA1.digest(info)
end

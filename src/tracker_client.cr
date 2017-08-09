data = "d8:completei0e10:incompletei1e8:intervali30e5:peers12:Y\u0011\x89F\u001a\xE16\xEF!\x98\u001a\xE1e"

parser = Parser.new data
decoded = parser.decode()

response = HTTP::Client.get "http://localhost:8000/pope.jpg.torrent"

if response.status_code != 200
  puts "Couldn't get torrent"
  exit 1
end

response.body

parser = Parser.new response.body
tf = parser.decode()

info = parser.info()

digest = Digest::SHA1.digest(info).to_slice

case decoded
  when Hash
  peers = decoded.fetch("peers").to_s

  poos = peers.bytes.in_groups_of(6, filled_up_with=0.to_u8).map { |peer|
		case peer
      when Array
      ip = Slice.new(peer[0, 4].to_unsafe, 4)
      port = Slice.new(peer[4, 2].to_unsafe, 2)

      ip.map(&.to_i).join('.')

      i = IO::ByteFormat::NetworkEndian.decode(UInt32, ip)
      p = IO::ByteFormat::NetworkEndian.decode(UInt16, port)

      {i, p}
    else
	    raise "Peer wasn't an array"
    end
  }

require "http/client"
require "./bemcoding"
require "./peer_client"
require "./torrent_file"
require "./tracker"

torrent_url = "https://s3-eu-west-1.amazonaws.com/bittorent-test/pope.jpg?torrent"
peer_id = "torrlang10axeltest10"

response = HTTP::Client.get torrent_url
tf = TorrentFile.new response.body

HTTP::Client.get build_tracker_url(tf.announce, tf.info_hash, peer_id, tf.length)

# case decoded
#   when Hash
#   peers = decoded.fetch("peers").to_s
#
#   poos = peers.bytes.in_groups_of(6, filled_up_with=0.to_u8).map { |peer|
# 		case peer
#       when Array
#       ip = Slice.new(peer[0, 4].to_unsafe, 4)
#       port = Slice.new(peer[4, 2].to_unsafe, 2)
#
#       ip.map(&.to_i).join('.')
#
#       i = IO::ByteFormat::NetworkEndian.decode(UInt32, ip)
#       p = IO::ByteFormat::NetworkEndian.decode(UInt16, port)
#
#       {i, p}
#     else
# 	    raise "Peer wasn't an array"
#     end
#   }
#
# 	ip, port = poos[1]
#
# client = PeerClient.new ip, port
# client.handshake(info_hash, peer_id)

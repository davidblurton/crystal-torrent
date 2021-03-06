require "http/client"
require "digest"
require "file"
require "./bemcoding"
require "./peer_client"
require "./torrent_file"
require "./tracker"
require "./tracker_response"

alias InfoHash = StaticArray(UInt8, 20)

torrent_url = "https://s3-eu-west-1.amazonaws.com/bittorent-test/pope.jpg?torrent"
peer_id = "torrlang10davidtest1"

response = HTTP::Client.get torrent_url
tf = TorrentFile.new response.body
puts "Got torrent file"
tf.length

response = HTTP::Client.get build_tracker_url(tf.announce, tf.info_hash, peer_id, tf.length)
tr = TrackerResponse.new response.body
puts "Got response from tracker"

peer = tr.peers.last
puts "Connecting to peer..."

client = PeerClient.new peer[0], peer[1]
client.handshake(tf.info_hash, peer_id)
puts "Completed handshake"

client.send_message(0x0001, 1)
client.receive_message()

client.send_message(0x0001, 2)
client.receive_message()

client.send_message(0x0013, 6, 0, 0, tf.length)
piece = client.receive_message().fetch("block").as(Bytes)

if Digest::SHA1.digest(piece).map(&.to_s(16)) == tf.pieces.map(&.to_s(16))
  puts "SHA1 verified"
else
  raise "SHA1 mismatch"
end

puts "Done"

File.write(tf.name, piece)

require "socket"

class PeerClient
  def initialize(ip : UInt32, port : UInt16)
    @client = TCPSocket.new ip.to_s, port.to_s
  end

  def handshake(info_hash : Bytes, peer_id : String)
    if info_hash.size != 20
      raise "info_hash must be 20 bytes"
    end

    if peer_id.bytesize != 20
      raise "peer_id must be 20 bytes"
    end

    @client.write Slice[19.to_u8]
    @client.write "BitTorrent protocol".to_slice
    @client.write Slice(UInt8).new 8
    @client.write info_hash
    @client.write peer_id.to_slice

    client_info_hash = Bytes.new(20)

    @client.read_byte
    @client.read_string(19)
    @client.skip(8)
    @client.read(client_info_hash)
    client_peer_id = @client.read_string(20)

    {client_info_hash, client_peer_id}
  end

  def close
    @client.close
  end
end

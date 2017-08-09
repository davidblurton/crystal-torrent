require "socket"

class PeerClient
  @peer_id = ""

  def initialize(ip : UInt32, port : UInt16)
    @client = TCPSocket.new ip.to_s, port.to_s
  end

  def handshake(info_hash : InfoHash, peer_id : String)
    if info_hash.size != 20
      raise "info_hash must be 20 bytes"
    end

    if peer_id.bytesize != 20
      raise "peer_id must be 20 bytes"
    end

    @client.write Slice[19.to_u8]
    @client.write "BitTorrent protocol".to_slice
    @client.write Slice(UInt8).new 8
    @client.write info_hash.to_slice
    @client.write peer_id.to_slice

    client_info_hash = Bytes.new(20)

    @client.read_byte
    @client.read_string(19)
    @client.skip(8)
    @client.read(client_info_hash)
    @peer_id = @client.read_string(20)

    if client_info_hash != info_hash.to_slice
      raise "Info hash didn't match"
    end
  end

  def send_message(len, id)
    @client.write_bytes(len, IO::ByteFormat::BigEndian)
    @client.write Slice[id.to_u8]
  end

  def send_message(len, id, *payload)
    self.send_message(len, id)
    payload.each {|i|
      @client.write_bytes(i, IO::ByteFormat::BigEndian)
    }
  end

  def receive_message()
    length = @client.read_bytes(Int32, IO::ByteFormat::NetworkEndian)
    puts "got block of length #{length}"
    message_id = @client.read_byte

    if message_id == 7
      index = @client.read_bytes(Int32, IO::ByteFormat::NetworkEndian)
      start = @client.read_bytes(Int32, IO::ByteFormat::NetworkEndian)

      slice = Bytes.new(length - 9)
      @client.read_fully(slice)

      {"message_id" => message_id, "block" => slice, "index" => index, "start" => start}
    else
      slice = Bytes.new(length - 1)
      @client.read(slice)
      {"message_id" => message_id, "block" => slice}
    end

  end

  def close
    @client.close
  end
end

require "./bemcoding"

class TrackerResponse
  @decoded : Hash(String, Type)

  def initialize(file : String)
    @parser = Parser.new file
    @decoded = @parser.decode().as(Hash(String, Type))
  end

  def peers()
    peers = @decoded.fetch("peers").as(String)

    peers.bytes.in_groups_of(6, filled_up_with=0.to_u8).map { |peer|
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
  end
end

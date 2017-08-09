require "digest"
require "./bemcoding"

alias H = Hash(String, Type)

class TorrentFile
  @decoded : H

  def initialize(file : String)
    @parser = Parser.new file
    @decoded = @parser.decode().as(H)
  end

  def info()
    @decoded["info"].as(H)
  end

  def announce()
    @decoded["announce"].as(String)
  end

  def pieces()
    self.info["pieces"].as(String).bytes
  end

  def length()
    self.info["length"].as(Int32)
  end

  def name()
    self.info["name"].as(String)
  end

  def info_hash() : InfoHash
    Digest::SHA1.digest(@parser.info())
  end
end

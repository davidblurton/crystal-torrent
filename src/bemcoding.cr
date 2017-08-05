# All valid bemcoding types.
alias Type = Int32 | String | Array(Type) | Hash(String, Type)

class Parser
  def initialize(str : String)
    @reader = Char::Reader.new(str)
    @info = ""
  end

  def decode_string_length() : Int32
    length = @reader.current_char.to_s

    until @reader.next_char() == ':'
      length += @reader.current_char()
    end

    @reader.next_char()
    length.to_i
  end

  def decode_string() : String
    length = decode_string_length()

    pos = @reader.pos

    @reader.pos += length
    @reader.string.byte_slice(pos, length)
  end

  def decode_integer() : Int32
    @reader.next_char()
    number = ""
    negative = false

    while @reader.has_next?
      if @reader.current_char.number?
        number += @reader.current_char
        @reader.next_char()
        next
      end

      if @reader.current_char == '-'
        negative = true
        @reader.next_char()
        next
      end

      if @reader.current_char == 'e'
        @reader.next_char()
        return negative ? -number.to_i : number.to_i
      end
    end

    raise "Expected number or e"
  end

  def decode_list() : Array(Type)
    list = Array(Type).new
    @reader.next_char()

    while @reader.has_next?
      if @reader.current_char == 'e'
        @reader.next_char()
        return list
      end

      list.push(decode())
    end

    raise "Expecting string"
  end

  def decode_hash() : Hash(String, Type)
    hash = Hash(String, Type).new
    @reader.next_char()

    while @reader.has_next?

      key = decode_string()
      pos = @reader.pos
      hash[key] = decode()

      if key == "info"
        @info = @reader.string.byte_slice(pos, @reader.pos - pos)
      end

      if @reader.current_char == 'e'
        @reader.next_char()
        return hash
      end
    end

    raise "Expecting string"
  end

  def decode() : Type
    if @reader.current_char.number?
      return decode_string()
    end

    if @reader.current_char == 'l'
      return decode_list()
    end

    if @reader.current_char == 'i'
      return decode_integer()
    end

    if @reader.current_char == 'd'
      return decode_hash()
    end
    raise "Unexpected token"
  end

  def info() : String
    @info
  end
end

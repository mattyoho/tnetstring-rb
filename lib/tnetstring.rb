module TNetstring
  def self.parse(tnetstring)
    parse_tnetstring(tnetstring)[0]
  end

  def self.parse_tnetstring(data)
    payload, payload_type, remain = parse_payload(data)
    value = case payload_type
    when '#'
      payload.to_i
    when ','
      payload
    when ']'
      parse_list(payload)
    when '}'
      parse_dictionary(payload)
    when '~'
      assert payload.length == 0, "Payload must be 0 length for null."
      nil
    when '!'
      parse_boolean(payload)
    else
      assert false, "Invalid payload type: #{payload_type}"
    end
    [value, remain]
  end

  def self.parse_payload(data)
    assert data, "Invalid data to parse, it's empty."
    length, extra = data.split(':', 2)
    length = length.to_i
    assert length <= 999_999_999, "Data is longer than the specification allows"
    assert length >= 0, "Data length cannot be negative!"

    payload, extra = extra[0, length], extra[length..-1]
    assert extra, "No payload type: %s, %s" % [payload, extra]
    payload_type, remain = extra[0,1], extra[1..-1]

    assert payload.length == length, "Data is wrong length %d vs %d" % [length, payload.length]
    [payload, payload_type, remain]
  end

  def self.parse_list(data)
    return [] if data.length == 0
    list = []
    value, remain = parse_tnetstring(data)
    list << value

    while remain.length > 0
      value, remain = parse_tnetstring(remain)
      list << value
    end
    list
  end

  def self.parse_dictionary(data)
    return {} if data.length == 0

    key, value, extra = parse_pair(data)
    result = {key => value}

    while extra.length > 0
        key, value, extra = parse_pair(extra)
        result[key] = value
    end
    result
  end

  def self.parse_pair(data)
    key, extra = parse_tnetstring(data)
    assert extra, "Unbalanced dictionary store."
    value, extra = parse_tnetstring(extra)
    assert value, "Got an invalid value, null not allowed."

    [key, value, extra]
  end

  def self.parse_boolean(data)
    case data
    when "false"
      false
    when "true"
      true
    else
      raise "Boolean wasn't 'true' or 'false'"
    end
  end

  def self.assert(truthy, message)
    raise message unless truthy
  end
end

class Object
  def to_tnetstring(sigil=",")
    self_as_string = self.to_s
    [self_as_string.length, ":", self_as_string, sigil].join
  end
end

class NilClass
  def to_tnetstring
    "".to_tnetstring("~")
  end
end

# XXX I'm sure there's a cute metaprogramming trick to make this less repetitive, but I'll find it later.
class Integer
  def to_tnetstring
    super("#")
  end
end

class TrueClass
  def to_tnetstring
    super "!"
  end
end

class FalseClass
  def to_tnetstring
    super "!"
  end
end

# XXX Actually implement the compound types

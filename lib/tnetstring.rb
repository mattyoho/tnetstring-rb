require 'tnetstring/errors'

module TNetstring
  # Converts a tnetstring into the encoded data structure.
  #
  # It expects a string argument prefixed with a valid tnetstring and
  # returns a tuple of the parsed object and any remaining string input.
  #
  # === Example
  #
  #  str = '5:12345#'
  #  TNetstring.parse(str)
  #
  #  #=> [12345, '']
  #
  #  str = '11:hello world,abc123'
  #
  #  #=> ['hello world', 'abc123']
  #
  def self.parse(tnetstring)
    payload, payload_type, remain = parse_payload(tnetstring)
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
      assert payload.length == 0, "Payload must be 0 length for null"
      nil
    when '!'
      parse_boolean(payload)
    else
      assert false, "Invalid payload type: #{payload_type}"
    end
    [value, remain]
  end

  def self.parse_payload(data) # :nodoc:
    assert data, "Invalid data to parse; it's empty"
    length, extra = data.split(':', 2)
    length = length.to_i
    assert length <= 999_999_999, "Data is longer than the specification allows"
    assert length >= 0, "Data length cannot be negative"

    payload, extra = extra[0, length], extra[length..-1]
    assert extra, "No payload type: #{payload}, #{extra}"
    payload_type, remain = extra[0,1], extra[1..-1]

    assert payload.length == length, "Data is wrong length: #{length} expected but was #{payload.length}"
    [payload, payload_type, remain]
  end

  def self.parse_list(data) # :nodoc:
    return [] if data.length == 0
    list = []
    value, remain = parse(data)
    list << value

    while remain.length > 0
      value, remain = parse(remain)
      list << value
    end
    list
  end

  def self.parse_dictionary(data) # :nodoc:
    return {} if data.length == 0

    key, value, extra = parse_pair(data)
    result = {key => value}

    while extra.length > 0
        key, value, extra = parse_pair(extra)
        result[key] = value
    end
    result
  end

  def self.parse_pair(data) # :nodoc:
    key, extra = parse(data)
    assert key.kind_of?(String) || key.kind_of?(Symbol), "Dictionary keys must be Strings or Symbols"
    assert extra, "Unbalanced dictionary store"
    value, extra = parse(extra)

    [key, value, extra]
  end

  def self.parse_boolean(data) # :nodoc:
    case data
    when "false"
      false
    when "true"
      true
    else
      assert false, "Boolean wasn't 'true' or 'false'"
    end
  end

  # Constructs a tnetstring out of the given object. Valid Ruby object types
  # include strings, integers, boolean values, nil, arrays, and hashes. Arrays
  # and hashes may contain any of the previous valid Ruby object types, but
  # hash keys must be strings.
  #
  # === Example
  #
  #  int = 12345
  #  TNetstring.encode(int)
  #
  #  #=> '5:12345#'
  #
  #  hash = {'hello' => 'world'}
  #  TNetstring.encode(hash)
  #
  #  #=> '16:5:hello,5:world,}'
  #
  def self.encode(obj)
    if obj.kind_of?(Integer)
      int_str = obj.to_s
      "#{int_str.length}:#{int_str}#"
    elsif obj.kind_of?(String) || obj.kind_of?(Symbol)
      "#{obj.length}:#{obj},"
    elsif obj.is_a?(TrueClass) || obj.is_a?(FalseClass)
      bool_str = obj.to_s
      "#{bool_str.length}:#{bool_str}!"
    elsif obj == nil
      "0:~"
    elsif obj.kind_of?(Array)
      encode_list(obj)
    elsif obj.kind_of?(Hash)
      encode_dictionary(obj)
    else
      assert false, "Object must be of a primitive type: #{obj.inspect}"
    end
  end

  def self.encode_list(list) # :nodoc:
    contents = list.map {|item| encode(item)}.join
    "#{contents.length}:#{contents}]"
  end

  def self.encode_dictionary(dict) # :nodoc:
    contents = dict.map do |key, value|
      assert key.kind_of?(String) || key.kind_of?(Symbol), "Dictionary keys must be Strings or Symbols"
      "#{encode(key)}#{encode(value)}"
    end.join
    "#{contents.length}:#{contents}}"
  end

  def self.assert(truthy, message) # :nodoc:
    raise ProcessError.new(message) unless truthy
  end
end

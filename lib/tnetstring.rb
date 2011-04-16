module TNetstring
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
    value, remain = parse(data)
    list << value

    while remain.length > 0
      value, remain = parse(remain)
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
    key, extra = parse(data)
    assert extra, "Unbalanced dictionary store."
    value, extra = parse(extra)
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

  def self.encode(obj)
    if obj.kind_of?(Integer)
      int_str = obj.to_s
      "#{int_str.length}:#{int_str}#"
    elsif obj.kind_of?(String)
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
      assert false, "Object must be of a primitive type"
    end
  end

  def self.encode_list(list)
    contents = list.map {|item| encode(item)}.join
    "#{contents.length}:#{contents}]"
  end

  def self.encode_dictionary(dict)
    contents = dict.map do |key, value|
      assert key.kind_of?(String), "Dictionary keys must be Strings"
      "#{encode(key)}#{encode(value)}"
    end.join
    "#{contents.length}:#{contents}}"
  end

  def self.assert(truthy, message)
    raise message unless truthy
  end
end

require 'uri'

class Params
  def initialize(req, route_params)
    @params = route_params
    parse_www_encoded_form(req.query_string)
    parse_www_encoded_form(req.body)
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    unless www_encoded_form.nil?
      URI::decode_www_form(www_encoded_form).each do |key, val|
        keys = parse_key(key)
        keys.inject(@params) do |accum, var|
          if var == keys.last
            accum[var] = val
          else
            accum[var] ||= {}
          end
        end
      end
    end
    nil
  end

  def parse_key(key)
    key.gsub("]", "").split("[")
  end
end

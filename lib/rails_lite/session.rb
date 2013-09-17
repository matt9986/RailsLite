require 'json'
require 'webrick'

class Session
  def initialize(req)
  	req.cookies.each do |cookie|
  		if cookie.name == "_rails_lite_app"
  			@cookie = JSON.parse(cookie.value)
  		end
  	end
  	@cookie ||= {}
  end

  def [](key)
  	@cookie[key]
  end

  def []=(key, val)
  	@cookie[key]= val
  end

  def blank
  	@cookie = {}
  end

  def store_session(res)
  	res.cookies << WEBrick::Cookie.new("_rails_lite_app", @cookie.to_json)
  end
end


class Flash
  def initialize(req)
  	req.cookies.each do |cookie|
  		if cookie.name == "_rails_lite_app_flash"
  			@flash_in = JSON.parse(cookie.value)
  		end
  	end
  	@flash_in ||= {}
  	@flash_out = {}
  end

  def [](key)
  	@flash_in[key]
  end

  def []=(key, val)
  	@flash_out[key]= val
  end

  def store_flash(res)
  	res.cookies << WEBrick::Cookie.new("_rails_lite_app_flash", @flash_out.to_json)
  end
end
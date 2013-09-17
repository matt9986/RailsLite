class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method = pattern, http_method
    @controller_class, @action_name = controller_class, action_name
  end

  def matches?(req)
    @http_method == req.request_method.downcase.to_sym &&
      req.path =~ @pattern
  end

  def run(req, res)
    hash = {}
    matches = @pattern.match(req.path)
    matches.names.each{|name| hash[name.to_sym]=matches[name]}
    @controller_class.new(req, res, hash).invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    # add these helpers in a loop here
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.select{|route| route.matches?(req)}.first
  end

  def run(req, res)
    if match = match(req)
      match.run(req, res)
    else
      res.status= 404
    end
  end
end
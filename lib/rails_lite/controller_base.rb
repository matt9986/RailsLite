require 'erb'
require_relative 'params'
require_relative 'session'
require_relative 'url_helper'
require 'active_support/inflector'

class ControllerBase
  attr_reader :params
  include UrlHelper

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  def form_authenticity_token
    @csrf ||= csrf
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
    @already_rendered
  end

  def redirect_to(url)
    session[:form_authenticity_token] = form_authenticity_token
    session.store_session(@res)
    flash.store_flash(@res)
    @res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, url)
    @already_rendered = true
  end

  def render_content(content, type)
    @res.content_type = type
    @res.body = content
    session[:form_authenticity_token] = form_authenticity_token
    session.store_session(@res)
    flash.store_flash(@res)
    @already_rendered = true
  end

  def render(template_name)
    controller_name = self.class.name.underscore
    contents = File.read("views/#{controller_name}/#{template_name}.html.erb")
    template = ERB.new(contents)
    render_content(template.result(binding), "text/html")
  end

  def invoke_action(name)
    session.blank unless session[:form_authenticity_token] ==
      params[:authenticity_token] && 
        [:put, :post, :delete].include?(@req.request_method.downcase.to_sym)
    self.send(name)
    render(name) unless already_rendered?
  end

  private

  def csrf
    SecureRandom.urlsafe_base64
  end
end

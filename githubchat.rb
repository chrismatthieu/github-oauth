begin
    require 'sinatra'
    require 'omniauth'
rescue LoadError
    require 'rubygems'
    require 'sinatra'
    require 'omniauth'
end
  
use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :github, '74a1475d7f5564343099', 'f8310520720f56e931f086d519c435d800c6997a'
end

get '/' do
  <<-HTML
  <a href='/auth/github'>Sign in with GitHub</a>
  HTML
end

post '/auth/:name/callback' do
  omniauth = request.env['omniauth.auth']
  # do whatever you want with the information!
end

get '/auth/:name/callback' do
  omniauth = request.env['omniauth.auth']

  # create a new hash
  @authhash = Hash.new
  
    omniauth['user_info']['email'] ? @authhash[:email] =  omniauth['user_info']['email'] : @authhash[:email] = ''
    omniauth['user_info']['name'] ? @authhash[:name] =  omniauth['user_info']['name'] : @authhash[:name] = ''
    omniauth['extra']['user_hash']['id'] ? @authhash[:uid] =  omniauth['extra']['user_hash']['id'].to_s : @authhash[:uid] = ''
    omniauth['provider'] ? @authhash[:provider] =  omniauth['provider'] : @authhash[:provider] = ''  
  
  # session[:user] = @authhash
  
end


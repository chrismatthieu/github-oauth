require 'rubygems'
require 'sinatra'
require 'omniauth'
require 'rest-client'
require 'json'
  
use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :github, '74a1475d7f5564343099', 'f8310520720f56e931f086d519c435d800c6997a'
end

get '/' do
  if session[:user]
    response = RestClient.get 'https://api.github.com/user/followers?access_token=' + session[:token]
    followers = JSON.parse(response.body)
    
    html = "Hello  #{session[:user][:name]}! (<a href=\"/logout\">logout</a>)<br/><p>Your followers:</p>"
    
    followers.each do |follower|
      html << "<img src=\"#{follower['avatar_url']}\" width=\"25\"> #{follower['login']}<br/>" rescue ""
    end
    
    html

  else
    <<-HTML
    <a href='/auth/github'><img src="/login-with-github.png"></a>
    HTML
  end
  
end


get '/auth/:name/callback' do
  omniauth = request.env['omniauth.auth']
  puts " *** omniauth: " + omniauth.inspect; 

  # create a new hash
  @authhash = Hash.new
  
  omniauth['user_info']['email'] ? @authhash[:email] =  omniauth['user_info']['email'] : @authhash[:email] = ''
  omniauth['user_info']['name'] ? @authhash[:name] =  omniauth['user_info']['name'] : @authhash[:name] = ''
  omniauth['extra']['user_hash']['id'] ? @authhash[:uid] =  omniauth['extra']['user_hash']['id'].to_s : @authhash[:uid] = ''
  omniauth['provider'] ? @authhash[:provider] =  omniauth['provider'] : @authhash[:provider] = ''  
  
  session[:user] = @authhash
  session[:token] = omniauth['credentials']['token']
  
  redirect "/"
end

get '/logout' do
  session[:user] = nil
  redirect "/"
end
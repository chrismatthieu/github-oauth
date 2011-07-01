require 'rubygems'
require 'sinatra'
require 'omniauth'
require 'rest-client'
require 'json'
  
use Rack::Session::Cookie
use OmniAuth::Builder do
  # provider :github, '74a1475d7f5564343099', 'f8310520720f56e931f086d519c435d800c6997a' #github chat
  provider :github, '25abed0273f2d33bd9a5', '5e1f21c1830c3c1a2816df2b1a1d798779763ce8' #testing
end

get '/' do
  if session[:user]
    
    html = "<h1>GitHub Issues Chat</h1><p>Hello  #{session[:user][:name]}! (<a href=\"/logout\">logout</a>)</p><p>Identify a user and repo:</p>"

    # # List Followers
    # response = RestClient.get 'https://api.github.com/user/followers?access_token=' + session[:token]
    # followers = JSON.parse(response.body)    
    # followers.each do |follower|
    #   html << "<img src=\"#{follower['avatar_url']}\" width=\"25\"> #{follower['login']}<br/>" rescue ""
    # end

    html << '<form action="/issues">User: <input type="text" name="user"> Repo: <input type="text" name="repo"><input type="submit" value="submit">'
    
    html

  else
    <<-HTML
    <a href='/auth/github'><img src="/login-with-github.png"></a>
    HTML
  end
  
end

get '/issues' do
  
  user = params[:user]
  repo = params[:repo]
  
  html = "<h1>GitHub Issues Chat</h1><p>Hello  #{session[:user][:name]}! (<a href=\"/\">home</a> | <a href=\"/logout\">logout</a>)</p><p>Select an issue:</p>"

  response = RestClient.get 'https://api.github.com/repos/' + user + '/' + repo + '/issues'
  issues = JSON.parse(response.body)    
  issues.each do |issue|
    html << "<img src='#{issue['user']['avatar_url']}' title='#{issue['user']['login']}' width='25'></a> "
    
    html << "<a href=\"#{user}/#{repo}/issues/#{issue['number']}\">#{issue['number']}</a> #{issue['title']}<br/>"
    
  end
  
  html
  
end

get '/:user/:repo/issues/:id' do
  user = params[:user]
  repo = params[:repo]
  id = params[:id]

  html = '<html>
  <head>
   <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>
   <script type="text/javascript" src="http://s.phono.com/releases/0.2/jquery.phono.js"></script>

   <script type="text/javascript">
   			var phono;
   			var call;
   		    $(document).ready(function(){
   		    	phono = $.phono({
   		    	  apiKey: "f12dc371538cb43b6c594d",
   		    	  onReady: function() {
   					if( ! this.audio.permission() ){
   					                this.audio.showPermissionBox();
   		             }
   					$("a.callme").addClass("phono-ready").text("Start");
   		    	  },
   				    phone: {
   				  	onConnect: function(event) {
   				  	},
   				  	onDisconnect: function(event) {
   				  		$(document).trigger("callHangUp");
   				  	}
   				  }

   		    	});

   		    	$("a.callme").click(function(){
   		    		$(".digit-hldr").slideDown();
   		    		$(this).hide();
   		    		$("a.hangup").show().css("display","block");
   		    		makeCall();
   		    		return false;
   		    	});

   		    	$("a.hangup").click(function(){
   		    		$(document).trigger("callHangUp");
   		    		return false;
   		    	});

   		    	$(document).bind("callHangUp", function(){
   		    		(call) ? call.hangup() : call = null;
   		    		$(".digit-hldr").slideUp();
   		    		$("a.hangup").hide();
   		    		$("a.callme").show();
   		    	});

   		    })

   		    function makeCall() {
                   numberToDial = "app:9996134567";

                   call = phono.phone.dial(numberToDial, {
   					headers: [
   					         {
   					           name:"web",
   					           value:"true"
   					         },
   							{
   					           name:"code",
   					           value: "' + user + repo + id + '"
   					         }
   					],
   					tones: false,
                       onAnswer: function(event) {

                       },
                       onHangup: function() {
   						$(document).trigger("callHangUp");
                       },
                       onDisconnect: function() {
   						$(document).trigger("callHangUp");
                       }
                   });
               }

   		</script>


  </head>
  <body>'
  
  html << "<h1>GitHub Issues Chat</h1><p>Hello  #{session[:user][:name]}! (<a href=\"/\">home</a> | <a href=\"/issues?user=#{user}&repo=#{repo}\">Issues</a> | <a href=\"/logout\">logout</a>)</p><p></p>"

  response = RestClient.get 'https://api.github.com/repos/' + user + '/' + repo + '/issues/' + id
  issue = JSON.parse(response.body)    

  html << "<a href='http://github.com/#{issue['user']['login']}'><img src='#{issue['user']['avatar_url']}' title='#{issue['user']['login']}' width='50'></a><br/>"
  html << "Issue: <a href='#{issue['html_url']}'>#{issue['number']}</a><br/>Title: #{issue['title']}<br/><p>#{issue['body']}</p>"
  
  html << '<div id="phono">
  			<a class="callme" href="#">Loading...</a>
  			<a class="hangup" href="#">hangup</a>
  		</div>
      </body>
  </html>'
  
  html
  
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
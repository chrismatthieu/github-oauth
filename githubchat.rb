require 'rubygems'
require 'sinatra'
require 'omniauth'
require 'rest-client'
require 'json'
  
use Rack::Session::Cookie
use OmniAuth::Builder do
  # provider :github, '74a1475d7f5564343099', 'f8310520720f56e931f086d519c435d800c6997a' #github chat
  provider :github, '25abed0273f2d33bd9a5', '5e1f21c1830c3c1a2816df2b1a1d798779763ce8' #testing port 4567 or 9393
end

get '/' do
  if session[:user]
    
    html = "<html><head><script src='http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js'></script><script>
    $(document).ready(function() {
           $('#btn').click(function(event){
             $.get('/issuesajax', {user: $(user).val(), repo : $(repo).val()}, function(data) {
               $('#answer').html(data);
             });
           });
         });</script></head>"
    
    html << "<body><h1>GitHub Issues Chat</h1><p><img src='https://secure.gravatar.com/avatar/#{session[:user][:gravatar_id]}?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png' width='50'> #{session[:user][:name]}! (<a href=\"/logout\">logout</a>)</p><p>Identify a user and repo:<br/>"

    # # List Followers
    # response = RestClient.get 'https://api.github.com/user/followers?access_token=' + session[:token]
    # followers = JSON.parse(response.body)    
    # followers.each do |follower|
    #   html << "<img src=\"#{follower['avatar_url']}\" width=\"25\"> #{follower['login']}<br/>" rescue ""
    # end

    html << 'User: <input type="text" id="user"> Repo: <input type="text" id="repo"><input name="btn" id="btn" type="button" value="Submit"></p><div id="answer"></div></body></html>'
    
    html

  else
    <<-HTML
    <a href='/auth/github'><img src="/login-with-github.png"></a>
    HTML
  end
  
end

# get '/issues' do
#   
#   user = params[:user]
#   repo = params[:repo]
#   
#   html = "<h1>GitHub Issues Chat</h1><p><img src='https://secure.gravatar.com/avatar/#{session[:user][:gravatar_id]}?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png' width='50'> #{session[:user][:name]}! (<a href=\"/\">home</a> | <a href=\"/logout\">logout</a>)<br/>Select an issue:</p>"
# 
#   response = RestClient.get 'https://api.github.com/repos/' + user + '/' + repo + '/issues'
#   issues = JSON.parse(response.body)    
#   issues.each do |issue|
#     html << "<img src='#{issue['user']['avatar_url']}' title='#{issue['user']['login']}' width='25'></a> "
#     
#     html << "<a href=\"#{user}/#{repo}/issues/#{issue['number']}\">#{issue['number']}</a> #{issue['title']}<br/>"
#     
#   end
#   
#   html
#   
# end

get '/issuesajax' do
  user = params[:user]
  repo = params[:repo]
  response = RestClient.get 'https://api.github.com/repos/' + user + '/' + repo + '/issues'
  issues = JSON.parse(response.body)  
  html = ""  
  issues.each do |issue|
    html << "<img src='#{issue['user']['avatar_url']}' title='#{issue['user']['login']}' width='25'></a> "
    html << "<a href=\"#{user}/#{repo}/issues/#{issue['number']}\">#{issue['number']}</a> #{issue['title']}<br/>"    
  end
  html
end


get '/phono/:user/:repo/:id' do
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

  html << '<center><img src="/phono.png"><br/><div id="phono">
  			<a class="callme" href="#">Loading...</a>
  			<a class="hangup" href="#">hangup</a>
  		</div></center></body></html>'
  		
  html
  
end

get '/:user/:repo/issues/:id' do
  user = params[:user]
  repo = params[:repo]
  id = params[:id]
  
  
  html='<html id="mainHTML">
  <head> 
      <title>GitHub Chat</title>
  	    <link href = "/style.css" type = text/css rel = stylesheet>

  </head>
  <body>
  <div>
      <iframe name="mainWebFrame" id="mainWebFrame" src="http://github.com/' + user + '/' + repo + '/issues/' + id + '" TITLE="GitHub" height="100%" width="100%" frameborder="0"
              marginwidth="0" marginheight="0" vspace="0" hspace="0">
      </iframe>
  </div>
  <div>
      <iframe id="mainChatFrame" name="mainChatFrame" src="/phono/' + user + '/' + repo + '/' + id + '"
              style="width: 300px; height: 250px; ">
      </iframe>
  </div>

  </body>
  </html>'
  
  html
  
end  

get 'old/:user/:repo/issues/:id' do
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
  
  html << "<h1>GitHub Issues Chat</h1><p><img src='https://secure.gravatar.com/avatar/#{session[:user][:gravatar_id]}?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-140.png' width='50'> #{session[:user][:name]}! (<a href=\"/\">home</a> | <a href=\"/logout\">logout</a>)</p><p></p>"

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
  omniauth['extra']['user_hash']['gravatar_id'] ? @authhash[:gravatar_id] =  omniauth['extra']['user_hash']['gravatar_id'].to_s : @authhash[:gravatar_id] = ''
  
  session[:user] = @authhash
  session[:token] = omniauth['credentials']['token']
  
  redirect "/"
end

get '/logout' do
  session[:user] = nil
  redirect "/"
end
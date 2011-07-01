web = $currentCall.getHeader("x-sbc-web")
code = $currentCall.getHeader("x-sbc-code") 


conferenceOptions={
			:playTones=>false
			}

answer
sleep 2

#Create conference ID
say 'Welcome to the GitHub issue conference.'

if web == "true"
  conferenceID = "conf" + code.to_s
else

  result = ask "Please enter your access code followed by the pound key.", {
  :choices => "[1-4 DIGITS]",
  :terminator => '#'}

  conferenceID = "conf" + result.value
end

conference(conferenceID,conferenceOptions)

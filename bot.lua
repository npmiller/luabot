--- IRC bot module:
-- Utility module to develop simple IRC bots in lua with luasockets

local socket = require 'socket'

Bot = { }

--- Bot creation
--@param n Username of the bot
function Bot:new(n)
	local bot = { chans = { }, name = n }
	setmetatable(bot, {__index = self})
	return bot
end

--- Connect to the server
--@param network Server address
--@param port Server port
function Bot:connect(network,port)
	self.s = assert(socket.connect(network,port))
	self.s:send('NICK ' .. self.name ..'\r\n')
	self.s:send('USER ' .. self.name ..'-bot 0 * :test\r\n')
end

--- Join a channel
--@param chan Channel to join
function Bot:join(chan)
	self.s:send('JOIN ' .. chan .. '\r\n')
	table.insert(self.chans,chan)
end

--- Leave a channel
--@param chan Channel to leave
function Bot:part(chan)
	self.s:send('PART ' .. chan .. '\r\n')
end

--- Say something
--@param string What to say
--@param chan Where to say it 
function Bot:say(string,chan)
	self.s:send('PRIVMSG ' .. chan .. ' :' .. string..'\r\n')end

--- Send a notice
--@param string Notice text
--@param target Notice destination
function Bot:notice(string,target)
	self.s:send('NOTICE ' .. target .. ' :' .. string..'\r\n')
end

--- Quit IRC
--@param quitmsg Quit message
function Bot:quit(quitmsg)
	if quitmsg == nil then quitmsg = 'quit' end
	self.s:send('QUIT :' .. quitmsg .. '\r\n')
end

--- Reply to pings
--@param ping Ping ID
function Bot:pong(ping)
	self.s:send('PONG ' .. ping:sub(6,-1) .. '\r\n')
end

--- Receive data from the server
function Bot:receive()
	local l = self.s:receive() or ''
	if l:sub(1,6) == 'PING :' then
		self:pong(l)
		return 'PING/PONG'
	else
		return l
	end
end

--- Parse received data
--@param l Raw data
--@return from Who sent the data
--@return mode With what mode (notice and so on)
--@return to Where was the data sent
--@return msg Content of the message
function Bot:parse(l)
	if l:match('PRIVMSG') or l:match('NOTICE') 
	or l:match('MODE') then
		i,_ = string.find(l,' ')
		from = string.gsub(string.sub(l,1,i-1),':','')
		j,_ = string.find(l,' ',i+1)
		mode = string.sub(l,i+1,j-1)
		i,_ = string.find(l,' ',j+1)
		to = string.gsub(string.sub(l,j+1,i-1),':','')
		msg = string.sub(l,i+2,-1)
		return from,mode,to,msg	
	elseif l:match('PART') or l:match('JOIN') then
		i,_ = string.find(l,' ')
		from = string.gsub(string.sub(l,1,i-1),':','')
		j,_ = string.find(l,' ',i+1)
		mode = string.sub(l,i+1,j-1)
		to = string.gsub(string.sub(l,j+1,-1),':','')
		return from,mode,to,''
	end
end

--- Get user name from the host
--@param user Host
function Bot:separate(user)
	i = string.find(user,'!')
	if i~= nil then
		return user:sub(1,i-1),user:sub(i+1,-1)
	end
end

return Bot

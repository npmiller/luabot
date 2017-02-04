#!/usr/bin/env lua5.1

local Bot = require ('bot')

local botname = 'testbot'

b = Bot:new(botname)
b:connect('ircserver',6667)


while true do
	l = b:receive()
	print(l,'\n')
	from,mode,to,msg = b:parse(l)
	print('>>>',from,mode,to,msg,'\n')
	if mode == 'NOTICE' and to == botname then
		b:join('#chan')
	end
	
	if mode == 'JOIN' then
		name = b:separate(from)
		b:say('Hi ' .. name .. ' !' ,to)
	end

	if msg == 'bot quit' and 'owner' == b:separate(from)then
		b:quit('quitting...')
		break
	end

	if string.match(msg or '', 'testbot') then
		b:say('hey', to)
	end

	if string.match(msg or '', 'hey') then
		b:say('hey', to)
	end

	if mode == 'NOTICE' and b:separate(from) == 'owner' then
		if msg:sub(1,1) == '#' then
			b:join(msg)
		end
	end
end


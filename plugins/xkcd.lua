--[[
    Based on a plugin by topkecleon.
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]--

local xkcd = {}

local mattata = require('mattata')
local https = require('ssl.https')
local url = require('socket.url')
local json = require('dkjson')

function xkcd:init(configuration)
    xkcd.arguments = 'xkcd <i>'
    xkcd.commands = mattata.commands(
        self.info.username,
        configuration.command_prefix
    ):command('xkcd').table
    xkcd.help = '/xkcd <i> - Returns the latest xkcd strip and its alt text. If a number is given, returns that number strip. If \'r\' is passed in place of a number, returns a random strip.'
    local jstr = https.request('https://xkcd.com/info.0.json')
    if jstr then
        local jdat = json.decode(jstr)
        if jdat then
            xkcd.latest = jdat.num
        end
    end
    xkcd.latest = xkcd.latest
end

function xkcd:on_message(message, configuration, language)
    local input = mattata.input(message.text)
    if not input then
        input = xkcd.latest
    end
    if input == 'r' then
        input = math.random(xkcd.latest)
    elseif tonumber(input) ~= nil then
        input = tonumber(input)
    else
        input = 'inurl:xkcd.com ' .. input
        local search = https.request('https://www.google.co.uk/search?num=20&q= ' .. url.escape(input))
        if not search:match('https?://xkcd[^/]+/%d+') then
            input = xkcd.latest
        else
            input = search:match('https?://xkcd[^/]+/(%d+)')
        end
    end
    local url = string.format(
        'https://xkcd.com/%s/info.0.json',
        tostring(input)
    )
    local jstr, res = https.request(url)
    if res == 404 then
        return mattata.send_message(
            message.chat.id,
            '[<a href="https://xkcd.com/404">404</a>] <b>404 Not Found</b>, 1/4/2008',
            'html'
        )
    elseif res ~= 200 then
        return mattata.send_reply(
            message,
            language.errors.connection
        )
    end
    local jdat = json.decode(jstr)
    return mattata.send_message(
        message.chat.id,
        string.format(
            '[<a href="%s">%s</a>] <b>%s</b>, %s/%s/%s\n<i>%s</i>',
            jdat.img,
            jdat.num,
            mattata.escape_html(jdat.safe_title),
            jdat.day,
            jdat.month,
            jdat.year,
            mattata.escape_html(jdat.alt)
        ),
        'html'
    )
end

return xkcd
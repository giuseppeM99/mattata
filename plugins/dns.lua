--[[
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]--

local dns = {}

local mattata = require('mattata')
local http = require('socket.http')
local json = require('dkjson')
local ltn12 = require('ltn12')

function dns:init(configuration)
    dns.arguments = 'dns <url> <type>'
    dns.commands = mattata.commands(
        self.info.username,
        configuration.command_prefix
    ):command('dns').table
    dns.help = '/dns <url> <type> - Sends DNS records of the given type for the given url. The types currently supported are AAAA, A, CERT, CNAME, DLV, IPSECKEY, MX, NS, PTR, SIG, SRV and TXT.'
end

function dns:on_message(message, configuration, language)
    local input = mattata.input(message.text_lower)
    if not input then
        return mattata.send_reply(
            message,
            dns.help
        )
    end
    local response = {}
    local _, res = http.request(
        {
            ['url'] = 'http://dig.jsondns.org/IN/' .. input:gsub(' ', '/'),
            ['redirect'] = true,
            ['sink'] = ltn12.sink.table(response)
        }
    )
    if res ~= 203 then
        return mattata.send_reply(
            message,
            language.errors.connection
        )
    end
    local jdat = json.decode(table.concat(response))
    if jdat.header.rcode ~= 'NOERROR' then
        return mattata.send_reply(
            message,
            language.errors.results
        )
    end
    if jdat.authority[1] then
        jdat = jdat.authority
    elseif jdat.answer[1] then
        jdat = jdat.answer
    else
        return mattata.send_reply(
            message,
            language.errors.results
        )
    end
    local output = ''
    local rdata = ''
    for n in pairs(jdat) do
        if type(jdat[n].rdata) == 'table' then
            for d in pairs(jdat[n].rdata) do
                rdata = rdata .. jdat[n].rdata[d]
                if d < #jdat[n].rdata then
                    rdata = rdata .. ', '
                end
            end
        else
            rdata = jdat[n].rdata
        end
        output = output .. 'Name: ' .. jdat[n].name .. '\nType: ' .. jdat[n].type .. '\nClass: ' .. jdat[n].class .. '\nTTL: ' .. jdat[n].ttl .. '\nRData: ' .. rdata .. '\n\n'
    end
    return mattata.send_message(
        message.chat.id,
        output
    )
end

return dns
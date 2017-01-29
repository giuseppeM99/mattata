--[[
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]--

local dictionary = {}

local mattata = require('mattata')
local https = require('ssl.https')
local url = require('socket.url')
local ltn12 = require('ltn12')
local json = require('dkjson')

function dictionary:init(configuration)
    dictionary.arguments = 'dictionary <word>'
    dictionary.commands = mattata.commands(
        self.info.username,
        configuration.command_prefix
    ):command('dictionary')
     :command('define').table
    dictionary.help = '/dictionary <word> - Searches the Oxford Dictionary for the given word and returns the definition. Alias: /define.'
end

function dictionary:on_message(message, configuration, language)
    local input = mattata.input(message.text_lower)
    if not input then
        return mattata.send_reply(
            message,
            dictionary.help
        )
    end
    local body = {}
    local _, res = https.request(
        {
            ['url'] = 'https://od-api.oxforddictionaries.com/api/v1/entries/en/' .. url.escape(input),
            ['headers'] = {
                ['app_id'] = configuration.keys.dictionary.id,
                ['app_key'] = configuration.keys.dictionary.key
            },
            ['sink'] = ltn12.sink.table(body),
        }
    )
    if res ~= 200 then
        return mattata.send_reply(
            message,
            language.errors.connection
        )
    end
    local jdat = json.decode(table.concat(body))
    local word = jdat.results[1].word
    word = mattata.escape_html(word)
    local results = #jdat.results[1].lexicalEntries
    if tonumber(results) > 4 then
        results = 4
    end
    local definitions = {}
    for i = 1, results do
        local entry = jdat.results[1].lexicalEntries[i].entries[1].senses[1].definitions[1]:gsub(':$', ''):gsub('%.$', '')
        entry = mattata.escape_html(entry)
        table.insert(
            definitions,
            '• ' .. entry
        )
    end
    local output = '<b>' .. word .. '</b>\n\n' .. table.concat(
        definitions,
        '\n'
    )
    return mattata.send_message(
        message.chat.id,
        output,
        'html'
    )
end

return dictionary
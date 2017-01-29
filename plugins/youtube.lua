--[[
    Copyright 2017 wrxck <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]--

local youtube = {}

local mattata = require('mattata')
local https = require('ssl.https')
local url = require('socket.url')
local json = require('dkjson')
local configuration = require('configuration')

function youtube:init(configuration)
    assert(
        configuration.keys.google,
        'youtube.lua requires an API key, and you haven\'t got one configured!'
    )
    youtube.arguments = 'youtube <query>'
    youtube.commands = mattata.commands(
        self.info.username,
        configuration.command_prefix
    ):command('youtube'):command('yt').table
    youtube.help = '/youtube <query> - Sends the top results from YouTube for the given search query. Alias: /yt.'
end

function youtube.get_result_count(input)
    local jstr, res = https.request('https://www.googleapis.com/youtube/v3/search?key=' .. configuration.keys.google .. '&type=video&part=snippet&q=' .. url.escape(input))
    if res ~= 200 then
        return 0
    end
    local jdat = json.decode(jstr)
    if jdat.pageInfo.total_results == 0 then
        return 0
    end
    return #jdat.items
end

function youtube.get_result(input, n)
    n = n or 1
    local jstr, res = https.request('https://www.googleapis.com/youtube/v3/search?key=' .. configuration.keys.google .. '&type=video&part=snippet&q=' .. url.escape(input))
    if res ~= 200 then
        return false
    end
    local jdat = json.decode(jstr)
    if jdat.pageInfo.total_results == 0 then
        return false
    end
    local jstr_info, res_info = https.request('https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&key=' .. configuration.keys.google .. '&id=' .. jdat.items[n].id.videoId .. '&fields=items(id,snippet(publishedAt,channelTitle,localized(title,description)),statistics(viewCount,likeCount,dislikeCount,commentCount),contentDetails(duration,regionRestriction(blocked)))')
    if res_info ~= 200 then
        return false
    end
    local jdat_info = json.decode(jstr_info)
    local output = ''
    output = output .. '<a href="https://www.youtube.com/watch?v=' .. jdat.items[n].id.videoId .. '">' .. mattata.escape_html(jdat.items[n].snippet.title) .. '</a>\n'
    if jdat_info.items[1].snippet.channelTitle then
        output = output .. '👤 ' .. mattata.escape_html(jdat_info.items[1].snippet.channelTitle) .. '\n'
    end
    if jdat_info.items[1].statistics.viewCount then
        output = output .. '👁 ' .. mattata.comma_value(jdat_info.items[1].statistics.viewCount) .. '\n'
    end
    if jdat_info.items[1].statistics.commentCount then
        output = output .. '💬 ' .. mattata.comma_value(jdat_info.items[1].statistics.commentCount) .. '\n'
    end
    if jdat_info.items[1].statistics.likeCount then
        output = output .. '👍 ' .. mattata.comma_value(jdat_info.items[1].statistics.likeCount) .. '\n'
    end
    if jdat_info.items[1].statistics.dislikeCount then
        output = output .. '👎 ' .. mattata.comma_value(jdat_info.items[1].statistics.dislikeCount) .. '\n'
    end
    return output
end

function youtube:on_callback_query(callback_query, message, configuration)
    if not message.reply_to_message then
        return mattata.answer_callback_query(
            callback_query.id,
            'An error occured!'
        )
    elseif callback_query.data:match('^results:(%d*)$') then
        local result = callback_query.data:match('^results:(%d*)$')
        local input = mattata.input(message.reply_to_message.text)
        local total_results = youtube.get_result_count(input)
        if tonumber(result) > tonumber(total_results) then
            result = 1
        elseif tonumber(result) < 1 then
            result = tonumber(total_results)
        end
        local output = youtube.get_result(input, tonumber(result))
        if not output then
            return mattata.answer_callback_query(
                callback_query.id,
                'An error occured!'
            )
        end
        local previous_result = 'youtube:results:' .. tonumber(result) - 1
        local next_result = 'youtube:results:' .. tonumber(result) + 1
        local keyboard = json.encode(
            {
                inline_keyboard = {
                    {
                        {
                            ['text'] = '← Previous',
                            ['callback_data'] = previous_result
                        },
                        {
                            ['text'] = result .. '/' .. total_results,
                            ['callback_data'] = 'youtube:pages:' .. result .. ':' .. total_results
                        },
                        {
                            ['text'] = 'Next →',
                            ['callback_data'] = next_result
                        }
                    }
                }
            }
        )
        return mattata.edit_message_text(
            message.chat.id,
            message.message_id,
            output,
            'html',
            true,
            keyboard
        )
    elseif callback_query.data:match('^pages:(.-):(.-)$') then
        local current_page, total_pages = callback_query.data:match('^pages:(.-):(.-)$')
        return mattata.answer_callback_query(
            callback_query.id,
            'You are on page ' .. current_page .. ' of ' .. total_pages .. '!'
        )
    end
end

function youtube:on_message(message, configuration, language)
    local input = mattata.input(message.text)
    if not input then
        return mattata.send_reply(
            message,
            youtube.help
        )
    end
    local output = youtube.get_result(input)
    if not output then
        return mattata.send_reply(
            message,
            language.errors.results
        )
    end
    local keyboard = json.encode(
        {
            inline_keyboard = {
                {
                    {
                        ['text'] = '← Previous',
                        ['callback_data'] = 'youtube:results:0'
                    },
                    {
                        ['text'] = '1/' .. youtube.get_result_count(input),
                        ['callback_data'] = 'youtube:pages:1:' .. youtube.get_result_count(input)
                    },
                    {
                        ['text'] = 'Next →',
                        ['callback_data'] = 'youtube:results:2'
                    }
                }
            }
        }
    )
    return mattata.send_message(
        message.chat.id,
        output,
        'html',
        true,
        false,
        message.message_id,
        keyboard
    )
end

return youtube
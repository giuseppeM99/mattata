return { -- when you're translating, do NOT translate the things in CAPS!
    locale = 'fr',
    join_messages = {
        'Welcome, NAME!',
        'Hello, NAME!',
        'Enjoy your stay, NAME!',
        'I\'m glad you joined, NAME!',
        'Howdy, NAME!',
        'Hi, NAME!'
    },
    user_added_bot = 'Hello, World! Thanks for adding me, NAME!',
    left_messages = {
        'RIP NAME.',
        'Rest in peace, NAME!',
        'Boy, I sure hope NAME enjoyed their stay!',
        'Was it something I said, NAME?',
        'But we were just getting to know each other, NAME...',
        'Gosh, NAME - am I really THAT bad?',
        'It\'s your loss, NAME.',
        'Come again soon, NAME!',
        'Bye, NAME!',
        'Goodbye, NAME.',
        'Farewell, NAME.'
    },
    errors = {
        generic = 'I\'m afraid an error has occured!',
        connection = 'I\'m sorry, but there was an error whilst I was processing your request, please try again later.',
        results = 'I\'m sorry, but I couldn\'t find any results for that.'
    },
    ['ai'] = {
        ['57'] = 'Matt\'s words echoed: NAME, there\'s a time and place for everything, but not now!'
    },
    specify_blacklisted_user = 'Please specify the user by their numerical ID.',
    user_now_blacklisted = 'That user is now blacklisted from using me.',
    user_now_whitelisted = 'That user is now able to use me again.',
    message_sent_to_channel = 'Your message has been sent!',
    unable_to_send_to_channel = 'Sorry, I was unable to send your message.',
    enter_message_to_send_to_channel = 'Please enter a message to send. Markdown formatting is supported.',
    not_channel_admin = 'Sorry, you do not appear to be an administrator for that group/channel.',
    unable_to_retrieve_channel_admins = 'Sorry, I was unable to retrieve a list of administrators for that group/channel.\n',
    ['copypasta'] = {
        ['45'] = 'Please respond to a message with less than MAXIMUM characters.'
    },
    found_one_pwned_account = 'The given account was found in 1 leak',
    account_found_multiple_leaks = 'The given account was found in X leaks',
    official_links = 'Here are some official links that you may find useful!',
    help_introduction = '*Hello, NAME!*\nMy name is MATTATA and I\'m an intelligent bot written with precision. There are many things I can do - try clicking the \'Commands\' button below to see what I can do for you.\n\n*Oh, and I work well in groups, too!*\nYou can enable and disable plugins in your group(s) using /plugins.\nI also feature a multilingual mode (currently in beta), try using /setlang <language> to adjust your language. That way, when you have a conversation with me, I\'ll make sure to always respond in your language!',
    help_confused = '*Confused?*\nDon\'t worry, I was programmed to help! Try using /help <command> to get help with a specific plugin and its usage.\n\nI\'m also an innovative example of artificial intelligence - yes, that\'s right; I can learn from you! Try speaking to me right here, or mention me by my name in a group. I can also describe images sent in response to messages I send.\n\nYou can also use me inline, try mentioning my username from any group and discover what else I can do!',
    no_documented_help = 'I\'m sorry, but I\'m afraid there is no help documented for that plugin at this moment in time. If you believe this is a mistake, please don\'t hesitate to contact [my developer](https://telegram.me/wrxck).',
    help_about = 'I\'m a bot written in Lua, and built to take advantage of the brilliant Bot API which Telegram offers.\n\nMy creator (and primary maintainer) is @wrxck.\nHe believes that anybody who enjoys programming should be able to work with the code of which I was compiled from, so I\'m proud to say that I am an open source project, which you can discover more about on [GitHub](https://github.com/matthewhesketh/mattata).',
    please_message_me = 'Please [message me in a private chat](http://telegram.me/MATTATA?start=help) to get started.',
    sent_private_message = 'I have sent you a private message containing the requested information.',
	['setlang'] = {
		['112'] = 'You can only use this command in private chat!'
	}
}
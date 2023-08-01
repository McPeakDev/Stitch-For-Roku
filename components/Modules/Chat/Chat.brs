sub init()
    m.chatPanel = m.top.findNode("chatPanel")
    m.keyboard = m.top.findNode("keyboard")
    m.chatButton = m.top.findNode("chatButton")
    ' determines how far down the screen the first message will appear
    ' set to 700 to have first message at bottom of screen.
    m.translation = 700
end sub

sub onInvisible()
    if m.top.visible = false
        m.chat.control = "stop"
    else
        m.chat.control = "run"
    end if
end sub

sub onVideoChange()
    if not m.top.control
        m.chat.control = "stop"
        m.top.control = true
    end if
end sub

sub onEnterChannel()
    ' ? "Chat >> onEnterChannel > " m.top.channel
    if get_user_setting("ChatWebOption", "true") = "true"
        m.chat = CreateObject("roSGNode", "ChatJob")
        m.chat.observeField("nextComment", "onNewComment")
        m.chat.observeField("clientComment", "onNewComment")
        m.chat.channel = m.top.channel
        m.chat.control = "stop"
        m.chat.control = "run"
    end if
    m.EmoteJob = CreateObject("roSGNode", "EmoteJob")
    m.EmoteJob.channel_id = m.top.channel_id
    m.EmoteJob.channel = m.top.channel
    m.EmoteJob.control = "run"
end sub

sub extractMessage(section) as object
    m.userstate_change = false
    words = section.Split(" ")
    if words[2] = "USERSTATE"
        m.userstate_change = true
    end if
    message = ""
    for i = 4 to words.Count() - 1
        message += words[i] + " "
    end for
    return message
end sub

sub onNewComment()
    m.chat.readyForNextComment = false
    comment = m.chat.nextComment.Split(";")
    display_name = ""
    message = ""
    color = ""
    badges = []
    emote_set = {}
    for each section in comment
        if Left(section, 9) = "user-type"
            temp = extractMessage(section)
            temp = Left(temp, Len(temp) - 3)
            message = Right(temp, Len(temp) - 1)
        else if Left(section, 12) = "display-name"
            display_name = Right(section, Len(section) - 13)
        else if Left(section, 5) = "color"
            color = Right(section, Len(section) - 7)
        else if Left(section, 6) = "badges"
            badges = Right(section, Len(section) - 7).Split(",")
        else if Left(section, 6) = "emotes"
            emotes = Right(section, Len(section) - 7).Split("/")
            for each emote in emotes
                if emote <> ""
                    temp = emote.Split(":")
                    key = temp[0]
                    value = {}
                    value.starts = []
                    for each interval in temp[1].Split(",")
                        range = interval.Split("-")
                        value.starts.Push(Val(range[0]))
                        value.length = Val(range[1]) - Val(range[0]) + 1
                    end for
                    emote_set[key] = value
                end if
            end for
        end if
    end for

    if display_name = "" or message = ""
        m.chat.readyForNextComment = true
        return
    end if

    group = createObject("roSGNode", "Group")
    group.visible = true
    group.translation = [5, m.translation]
    badge_translation = 0
    for each badge in badges
        if badge <> invalid and badge <> ""
            if m.global.twitchBadges <> invalid
                if m.global.twitchBadges[badge] <> invalid
                    poster = createObject("roSGNode", "Poster")
                    poster.uri = m.global.twitchBadges[badge]
                    poster.width = 18
                    poster.height = 18
                    poster.visible = true
                    poster.translation = [badge_translation, 0]
                    group.appendChild(poster)
                    badge_translation += 20
                end if
            end if
        end if
    end for

    username = createObject("roSGNode", "SimpleLabel")
    username.text = display_name
    if color = ""
        color = "FFFFFF"
    end if
    username.color = "0x" + color + "FF"
    username.translation = [badge_translation, 0]
    username.visible = true
    username.fontSize = "14"
    username.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Bold.otf"

    message_chars = message.Split(" ")

    username_width = username.localBoundingRect().width
    x_translation = badge_translation + username_width + 1
    y_translation = 0
    appended_last_line = false

    message_text = createObject("roSGNode", "SimpleLabel")
    message_text.fontSize = "14"
    message_text.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
    message_text.visible = true
    message_text.text = ""

    colon = createObject("roSGNode", "SimpleLabel")
    colon.fontSize = "14"
    colon.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
    colon.color = "0xFFFFFFFF"
    colon.translation = [x_translation, y_translation]
    colon.visible = true
    colon.text = ":"

    currentWord = createObject("roSGNode", "SimpleLabel")
    currentWord.fontSize = "14"
    currentWord.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
    currentWord.color = "0xFFFFFFFF"
    currentWord.translation = [x_translation, y_translation]
    currentWord.visible = true
    currentWord.text = ""
    x_translation += 7
    word_number = 1
    char = 0
    for each word in message_chars
        appended_last_line = false
        is_emote = false
        currentWord.text = word
        width = message_text.localBoundingRect().width
        currentWordWidth = currentWord.localBoundingRect().width
        '? "Current word width ("; word; "): "; currentWordWidth; ", Total message width: "; width
        for each emote in emote_set.Items()
            for each start in emote.value.starts
                if start = char
                    message_text.translation = [x_translation, y_translation]
                    group.appendChild(message_text)
                    message_text = createObject("roSGNode", "SimpleLabel")
                    message_text.fontSize = "14"
                    message_text.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
                    message_text.visible = true
                    message_text.text = ""
                    x_translation += width
                    poster = createObject("roSGNode", "Poster")
                    poster.uri = "https://static-cdn.jtvnw.net/emoticons/v1/" + emote.key + "/1.0"
                    poster.visible = true
                    poster.translation = [x_translation, y_translation - 5]
                    group.appendChild(poster)
                    x_translation += 35
                    if x_translation >= 230 or word_number = message_chars.Count()
                        x_translation = 0
                        y_translation += 23
                    end if
                    is_emote = true
                    appended_last_line = true
                end if
            end for
        end for
        if m.global.globalTTVEmotes <> invalid and not is_emote
            if m.global.globalTTVEmotes.DoesExist(word)
                message_text.translation = [x_translation, y_translation]
                group.appendChild(message_text)
                message_text = createObject("roSGNode", "SimpleLabel")
                message_text.fontSize = "14"
                message_text.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
                message_text.visible = true
                message_text.text = ""
                x_translation += width
                poster = createObject("roSGNode", "Poster")
                poster.uri = "https://cdn.betterttv.net/emote/" + m.global.globalTTVEmotes[word] + "/1x"
                poster.visible = true
                poster.translation = [x_translation, y_translation - 5]
                group.appendChild(poster)
                x_translation += 35
                if x_translation >= 230 or word_number = message_chars.Count()
                    x_translation = 0
                    y_translation += 23
                end if
                is_emote = true
                appended_last_line = true
            end if
        end if
        if m.global.channelTTVEmotes <> invalid and not is_emote
            if m.global.channelTTVEmotes.DoesExist(word)
                message_text.translation = [x_translation, y_translation]
                group.appendChild(message_text)
                message_text = createObject("roSGNode", "SimpleLabel")
                message_text.fontSize = "14"
                message_text.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
                message_text.visible = true
                message_text.text = ""
                x_translation += width
                poster = createObject("roSGNode", "Poster")
                poster.uri = "https://cdn.betterttv.net/emote/" + m.global.channelTTVEmotes[word] + "/1x"
                poster.visible = true
                poster.translation = [x_translation, y_translation - 5]
                group.appendChild(poster)
                x_translation += 35
                if x_translation >= 230 or word_number = message_chars.Count()
                    x_translation = 0
                    y_translation += 23
                end if
                is_emote = true
                appended_last_line = true
            end if
        end if
        if m.global.channelTTVFrankerEmotes <> invalid and not is_emote
            if m.global.channelTTVFrankerEmotes.DoesExist(word)
                message_text.translation = [x_translation, y_translation]
                group.appendChild(message_text)
                message_text = createObject("roSGNode", "SimpleLabel")
                message_text.fontSize = "14"
                message_text.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
                message_text.visible = true
                message_text.text = ""
                x_translation += width
                poster = createObject("roSGNode", "Poster")
                poster.uri = m.global.channelTTVFrankerEmotes[word]
                poster.visible = true
                poster.translation = [x_translation, y_translation - 5]
                group.appendChild(poster)
                x_translation += 35
                if x_translation >= 230 or word_number = message_chars.Count()
                    x_translation = 0
                    y_translation += 23
                end if
                is_emote = true
                appended_last_line = true
            end if
        end if
        if m.global.global7TVEmotes <> invalid and not is_emote
            if m.global.global7TVEmotes.DoesExist(word)
                message_text.translation = [x_translation, y_translation]
                group.appendChild(message_text)
                message_text = createObject("roSGNode", "SimpleLabel")
                message_text.fontSize = "14"
                message_text.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
                message_text.visible = true
                message_text.text = ""
                x_translation += width
                poster = createObject("roSGNode", "Poster")
                poster.uri = m.global.global7TVEmotes[word]
                poster.visible = true
                poster.translation = [x_translation, y_translation - 5]
                group.appendChild(poster)
                x_translation += 35
                if x_translation >= 230 or word_number = message_chars.Count()
                    x_translation = 0
                    y_translation += 23
                end if
                is_emote = true
                appended_last_line = true
            end if
        end if
        if m.global.channel7TVEmotes <> invalid and not is_emote
            if m.global.channel7TVEmotes.DoesExist(word)
                message_text.translation = [x_translation, y_translation]
                group.appendChild(message_text)
                message_text = createObject("roSGNode", "SimpleLabel")
                message_text.fontSize = "14"
                message_text.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
                message_text.visible = true
                message_text.text = ""
                x_translation += width
                poster = createObject("roSGNode", "Poster")
                poster.uri = m.global.channel7TVEmotes[word]
                poster.visible = true
                poster.translation = [x_translation, y_translation - 5]
                group.appendChild(poster)
                x_translation += 35
                if x_translation >= 230 or word_number = message_chars.Count()
                    x_translation = 0
                    y_translation += 23
                end if
                is_emote = true
                appended_last_line = true
            end if
        end if
        if not is_emote
            if (x_translation + currentWordWidth + width) < 230
                temp = message_text.text
                temp2 = word + " "
                temp.AppendString(temp2, Len(temp2))
                message_text.text = temp
            else if (x_translation + currentWordWidth + width) >= 230
                if currentWordWidth >= 230
                    currentWordChars = word.Split("")
                    for each character in currentWordChars
                        width = message_text.localBoundingRect().width
                        appended_last_line = false
                        if width >= 230
                            message_text.translation = [x_translation, y_translation]
                            group.appendChild(message_text)
                            appended_last_line = true
                            message_text = createObject("roSGNode", "SimpleLabel")
                            message_text.fontSize = "14"
                            message_text.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
                            message_text.visible = true
                            message_text.text = ""
                            x_translation = 0
                            y_translation += 23
                        end if
                        message_text.text += character
                    end for
                else
                    message_text.translation = [x_translation, y_translation]
                    group.appendChild(message_text)
                    message_text = createObject("roSGNode", "SimpleLabel")
                    message_text.fontSize = "14"
                    message_text.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
                    message_text.visible = true
                    message_text.text = word
                    appended_last_line = false
                    x_translation = 0
                    y_translation += 23
                end if
                message_text.text += " "
            end if
        end if
        char += Len(word) + 1
        word_number += 1
    end for

    if not appended_last_line
        message_text.translation = [x_translation, y_translation]
        group.appendChild(message_text)
        y_translation += 32
    end if

    group.appendChild(username)
    m.chatPanel.appendChild(group)
    if m.translation + y_translation > 700
        for each chatmessage in m.chatPanel.getChildren(-1, 0)
            if chatmessage.translation[1] - y_translation < -150 ' Wait until it's off the screen to remove it.
                m.chatPanel.removeChild(chatmessage)
            else
                chatmessage.translation = [0, (chatmessage.translation[1] - y_translation)]
            end if
        end for
    else
        m.translation += y_translation
    end if
    m.chat.readyForNextComment = true
end sub

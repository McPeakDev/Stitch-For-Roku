sub init()
    m.videoPlayer = m.top.findNode("videoWindow")
end sub

function handleContent()
    ?"Content Requested!"
    ? "Type: "; m.top.contentRequested.contentType
    m.getTwitchDataTask = CreateObject("roSGNode", "TwitchApiTask")
    m.getTwitchDataTask.observeField("response", "handleResponse")
    if m.top.contentRequested.contentType = "VOD"
        request = {
            type: "getVodPlayerWrapperQuery"
            params: {
                id: m.top.contentRequested.contentId
            }
        }
    end if
    if m.top.contentRequested.contentType = "LIVE"
        request = {
            type: "getStreamPlayerQuery"
            params: {
                id: m.top.contentRequested.streamerLogin
            }
        }
    end if
    m.getTwitchDataTask.request = request
    m.getTwitchDataTask.functionName = request.type
    m.getTwitchDataTask.control = "run"
end function

function handleResponse()
    if m.top.contentRequested.contentType = "VOD"
        usherUrl = "https://usher.ttvnw.net/vod/" + m.gettwitchdatatask.response.data.video.id + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&nauth=" + m.gettwitchdatatask.response.data.video.playbackAccessToken.value.EncodeUri() + "&nauthsig=" + m.gettwitchdatatask.response.data.video.playbackAccessToken.signature
    else if m.top.contentRequested.contentType = "LIVE"
        usherUrl = "https://usher.ttvnw.net/api/channel/hls/" + m.gettwitchdatatask.response.data.user.login + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&lr=true&token=" + m.gettwitchdatatask.response.data.user.stream.playbackaccesstoken.value.EncodeUri() + "&sig=" + m.gettwitchdatatask.response.data.user.stream.playbackaccesstoken.signature
    end if
    ' return usherUrl
    req = HttpRequest({
        url: usherUrl
        headers: {
            "Accept": "*/*"
            "Origin": "https://switch.tv.twitch.tv"
            "Referer": "https://switch.tv.twitch.tv/"
        }
        method: "GET"
    })
    while true
        rsp = req.send().getString()
        if rsp <> invalid
            exit while
        end if
        sleep(10)
    end while
    list = rsp.Split(chr(10))
    first_stream_link = ""
    last_stream_link = ""
    link = ""
    cnt = 0
    ' streamitems_all = []
    stream_objects = []
    for line = 2 to list.Count() - 1
        stream_info = list[line + 1].Split(",")
        streamobject = {}
        for info = 0 to stream_info.Count() - 1
            info_parsed = stream_info[info].Split("=")
            streamobject[info_parsed[0].replace("#EXT-X-STREAM-INF:", "")] = toString(info_parsed[1], true).replace(chr(34), "")
        end for
        streamobject["URL"] = list[line + 2]
        stream_objects.push(streamobject)
        line += 2
    end for
    stream_bitrates = []
    stream_urls = []
    stream_qualities = []
    stream_content_ids = []
    stream_sticky = []
    for each stream_item in stream_objects
        stream_bitrates.push(Int(Val(stream_item["BANDWIDTH"])) / 1000)
        if stream_item["VIDEO"] = "chunked"
            value = stream_item["RESOLUTION"].split("x")[1] + "p"
            if stream_item["FRAME-RATE"] <> invalid
                value = value + stream_item["FRAME-RATE"].split(".")[0]
            end if
        else
            value = stream_item["VIDEO"]
        end if
        stream_content_ids.push(value)
        stream_urls.push(stream_item["URL"])
        if Int(Val(stream_item["RESOLUTION"].split("x")[1])) >= 720
            stream_qualities.push("HD")
        else
            stream_qualities.push("SD")
        end if
        stream_sticky.push("false")

    end for
    ' The stream needs a couple of seconds to load on AWS's server side before we display back to user.
    ' The idea is that this will provide a better user experience by removing stuttering.
    ? "STREAMURLS:" stream_urls
    playVideo({
        streamUrls: stream_urls
        streamQualities: stream_qualities
        streamContentIDs: stream_content_ids
        streamBitrates: stream_bitrates
        streamStickyHttpRedirects: stream_sticky
    })
end function

function playVideo(data)
    vidContent = createObject("roSGNode", "ContentNode")
    vidContent.title = m.top.contentRequested.contentTitle
    vidContent.url = data.streamUrls[0]
    vidContent.streamFormat = "hls"
    ? "Pause"
    m.videoplayer.content = vidContent
    m.videoplayer.visible = true
    m.videoplayer.setFocus(true)
    m.videoplayer.enableCookies()
    m.videoplayer.control = "play"
end function



function onKeyEvent(key as string, press as boolean) as boolean
    if press
        ? "Home Scene Key Event: "; key
        if key = "back"
            m.top.backPressed = true
            return true
        end if
        if key = "OK"
            ? "selected"
        end if
    end if
end function
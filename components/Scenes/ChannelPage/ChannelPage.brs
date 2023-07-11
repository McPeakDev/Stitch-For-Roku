sub init()
    m.top.observeField("focusedChild", "onGetfocus")
    ' m.top.observeField("itemFocused", "onGetFocus")
    m.rowlist = m.top.findNode("exampleRowList")
    m.rowlist.ObserveField("itemSelected", "handleItemSelected")
    m.username = m.top.findNode("username")
    m.followers = m.top.findNode("followers")
    m.description = m.top.findNode("description")
    m.livestreamlabel = m.top.findNode("livestreamlabel")
    m.liveDuration = m.top.findNode("liveDuration")
    m.recentVideosLabel = m.top.findNode("recentVideosLabel")
    m.avatar = m.top.findNode("avatar")
end sub

sub updatePage()
    m.username.text = m.top.contentRequested.streamerDisplayName
    m.GetContentTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
    ' ' observe content so we can know when feed content will be parsed
    ' ? "REQUESTED CONTENT: "; m.top.contentRequested
    ' ? "Pause"
    m.GetContentTask.observeField("response", "updateChannelInfo")
    m.GetContentTask.request = {
        type: "getChannelHomeQuery"
        params: {
            id: m.top.contentRequested.streamerLogin
        }
    }
    m.GetShellTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
    ' ' observe content so we can know when feed content will be parsed
    ' ? "REQUESTED CONTENT: "; m.top.contentRequested
    ' ? "Pause"
    m.GetShellTask.observeField("response", "updateChannelShell")
    m.GetShellTask.request = {
        type: "getChannelShell"
        params: {
            id: m.top.contentRequested.streamerLogin
        }
    }
end sub

sub updateChannelShell()
    setBannerImage()
end sub

function setBannerImage()
    bannerGroup = m.top.findNode("banner")
    poster = createObject("roSGNode", "Poster")
    if m.GetShellTask.response.data.userOrError.bannerImageUrl <> invalid
        poster.uri = m.GetShellTask.response.data.userOrError.bannerImageUrl
    else
        poster.uri = "pkg:/images/default_banner.png"
    end if
    poster.width = 1280
    poster.height = 320
    poster.visible = true
    poster.translation = [-122, -25]
    overlay = createObject("roSGNode", "Rectangle")
    overlay.color = "0x010101F0"
    overlay.width = 1280
    overlay.height = 320
    poster.appendChild(overlay)
    bannerGroup.appendChild(poster)
end function

sub updateChannelInfo()
    ' m.GetcontentTask.response.data.channel
    ' id                : 71092938
    ' __typename        : User
    ' login             : xqc
    ' stream            :
    ' videoShelves      : @{edges=System.Object[]}
    ' self              : @{follower=; subscriptionBenefit=}
    ' displayName       : xQc
    ' hosting           :
    ' videos            : @{edges=System.Object[]}
    ' roles             : @{isPartner=True}
    ' broadcastSettings : @{isMature=False; id=71092938; __typename=BroadcastSettings}
    ' description       : THE BEST AT ABSOLUTELY EVERYTHING. THE JUICER. LEADER OF THE JUICERS.
    ' followers         : @{totalCount=11870230}
    ' profileImageURL   : https://static-cdn.jtvnw.net/jtv_user_pictures/xqc-profile_image-9298dca608632101-70x70.jpeg
    ' profileViewCount  :
    m.description.infoText = m.GetcontentTask.response.data.channel.description
    m.followers.text = numberToText(m.GetcontentTask.response.data.channel.followers.totalCount) + " " + tr("followers")
    m.avatar.uri = m.GetcontentTask.response.data.channel.profileImageUrl
    ? "Resp: "; m.GetcontentTask.response
    ? "Resp: "; m.GetcontentTask.response.data
end sub

function buildContentNodeFromShelves(shelves)
    contentCollection = createObject("RoSGNode", "ContentNode")
    for each shelf in shelves
        row = createObject("RoSGNode", "ContentNode")
        temp_title = ""
        try
            for each wordblock in shelf.node.title.localizedTitleTokens
                if wordblock.node.__typename = "TextToken"
                    temp_title = Substitute("{0}{1}", temp_title, wordblock.node.text)
                end if
                if wordblock.node.__typename = "Game"
                    temp_title = Substitute("{0}{1}", temp_title, wordblock.node.displayName)
                end if
                if wordblock.node.__typename = "BrowsableCollection"
                    temp_title = shelf.node.title.fallbackLocalizedTitle
                end if
            end for
        catch e
            ? "TITLE ERROR: "; e
            temp_title = shelf.node.title.fallbackLocalizedTitle
        end try
        row.title = temp_title
        for each stream in shelf.node.content.edges
            streamnode = stream.node
            ' type_name = stream.node.__typename
            try
                if stream.node.type <> invalid and stream.node.type = "live"
                    rowItem = createObject("RoSGNode", "TwitchContentNode")
                    rowItem.contentId = stream.node.Id
                    rowItem.contentType = "LIVE"
                    rowItem.previewImageURL = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", stream.node.broadcaster.login, "320", "180")
                    rowItem.contentTitle = stream.node.broadcaster.broadcastSettings.title
                    rowItem.viewersCount = stream.node.viewersCount
                    rowItem.streamerDisplayName = stream.node.broadcaster.displayName
                    rowItem.streamerLogin = stream.node.broadcaster.login
                    rowItem.streamerId = stream.node.broadcaster.id
                    rowItem.streamerProfileImageUrl = stream.node.broadcaster.profileImageURL
                    rowItem.gameDisplayName = stream.node.game.displayName
                    rowItem.gameBoxArtUrl = Left(stream.node.game.boxArtUrl, Len(stream.node.game.boxArtUrl) - 20) + "188x250.jpg"
                    rowItem.gameId = stream.node.game.Id
                    rowItem.gameName = stream.node.game.name

                    rowItem.Title = streamnode.broadcaster.broadcastSettings.title
                    rowItem.secondaryTitle = streamnode.broadcaster.displayName
                    rowItem.HDPosterUrl = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", streamnode.broadcaster.login, "320", "180")
                    rowItem.ShortDescriptionLine1 = streamnode.viewersCount
                    rowItem.ShortDescriptionLine2 = streamnode.game.displayName
                    row.appendChild(rowItem)
                else
                    rowItem = createObject("RoSGNode", "TwitchContentNode")
                    rowItem.contentId = stream.node.Id
                    rowItem.contentType = "GAME"
                    rowItem.viewersCount = stream.node.viewersCount
                    rowItem.gameDisplayName = stream.node.displayName
                    rowItem.gameBoxArtUrl = Left(stream.node.boxArtUrl, Len(stream.node.boxArtUrl) - 20) + "188x250.jpg"
                    rowItem.gameId = stream.node.Id
                    rowItem.gameName = stream.node.name

                    rowItem.Title = streamnode.displayName
                    rowItem.secondaryTitle = streamnode.viewersCount
                    rowItem.HDPosterUrl = Left(stream.node.boxArtUrl, Len(stream.node.boxArtUrl) - 20) + "188x250.jpg"
                    rowItem.ShortDescriptionLine1 = streamnode.viewersCount
                    row.appendChild(rowItem)
                end if
            catch e
                ? "Error: "; e
            end try
        end for
        contentCollection.appendChild(row)
    end for
    return contentCollection
end function


sub handleRecommendedSections()
    if m.GetContentTask.response.data <> invalid and m.GetContentTask.response.data.shelves <> invalid
        contentCollection = buildContentNodeFromShelves(m.GetContentTask.response.data.shelves.edges)
    else
        for each error in m.GetContentTask.response.errors
            ? "RESP: "; error.message
        end for
    end if
    updateRowList(contentCollection)
end sub

' function createRowList()
'     newRowList = createObject("RoSGNode", "RowList")
'     newRowList.rowLabelOffset = "[[0,5]]"
'     newRowList.rowLabelFont = "font:LargeBoldSystemFont"
'     newRowList.itemComponentName = "VideoItem"
'     newRowList.numRows = 1
'     newRowList.rowItemSize = "[[320,180]]"
'     newRowList.rowItemSpacing = "[[30,0]]"
'     newRowList.itemSize = "[1080,275]"
'     newRowList.itemSpacing = "[ 0, 40 ]"
'     newRowList.showRowLabel = "[true]"
'     newRowList.focusBitmapUri = "pkg:/images/focusIndicator.9.png"
'     newRowList.vertFocusAnimationStyle = "fixedFocus"
'     newRowList.rowFocusAnimationStyle = "fixedFocusWrap"
'     return newRowList
' end function

function updateRowList(contentCollection)
    rowItemSize = []
    showRowLabel = []
    rowHeights = []
    for each row in contentCollection.getChildren(contentCollection.getChildCount(), 0)
        if row.title <> ""
            hasRowLabel = true
        else
            hasRowLabel = false
        end if
        showRowLabel.push(hasRowLabel)
        defaultRowHeight = 275
        if row.getchild(0).contentType = "LIVE" or row.getchild(0).contentType = "VOD"
            rowItemSize.push([320, 180])
            if hasRowLabel
                rowHeights.push(275)
            else
                rowHeights.push(235)
            end if
        end if
        if row.getchild(0).contentType = "GAME"
            rowItemSize.push([188, 250])
            if hasRowLabel
                rowHeights.push(325)
            else
                rowHeights.push(305)
            end if
        end if
    end for
    m.rowList.rowHeights = rowHeights
    m.rowlist.showRowLabel = showRowLabel
    m.rowlist.rowItemSize = rowItemSize
    m.rowlist.content = contentCollection
    m.rowlist.numRows = contentCollection.getChildCount()
end function

sub handleItemSelected()
    selectedRow = m.rowlist.content.getchild(m.rowlist.rowItemSelected[0])
    selectedItem = selectedRow.getChild(m.rowlist.rowItemSelected[1])
    m.top.contentSelected = selectedItem
end sub

sub onGetFocus()
    if m.rowlist.focusedChild = invalid
        m.rowlist.setFocus(true)
    else if m.rowlist.focusedchild.id = "exampleRowList"
        m.rowlist.focusedChild.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        ? "Home Scene Key Event: "; key
        if key = "up" or key = "back"
            m.top.backPressed = true
            return true
        end if
    end if
end function
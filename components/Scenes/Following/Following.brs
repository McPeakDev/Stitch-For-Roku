sub init()
    m.top.observeField("focusedChild", "onGetfocus")
    ? "init"; TimeStamp()
    ' m.top.observeField("itemFocused", "onGetFocus")
    m.rowlist = m.top.findNode("exampleRowList")
    ' m.allChannels = m.top.findNode("allChannels")
    ' m.allChannels.observeField("itemSelected", "handleItemSelected")
    m.rowlist.ObserveField("itemSelected", "handleItemSelected")
    m.offlineList = m.top.findNode("offlineList")
    m.GetContentTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.GetContentTask.observeField("response", "handleRecommendedSections")
    m.GetContentTask.request = {
        type: "getFollowingPageQuery"
    }
    m.getcontentTask.functionName = m.getcontenttask.request.type
    m.getcontentTask.control = "run"
end sub

function TimeStamp()
    date = CreateObject("roDateTime")
    return date.AsSeconds()
end function

sub handleRecommendedSections()
    ? "handleRecommendedSections: "; TimeStamp()
    contentCollection = createObject("RoSGNode", "ContentNode")
    if m.GetcontentTask.response.data <> invalid
        if m.GetcontentTask.response.data.user <> invalid
        else
            ? "User Section Invalid"
        end if
    end if
    if m.GetcontentTask.response.data <> invalid and m.GetcontentTask.response.data.user <> invalid and m.GetcontentTask.response.data.user.followedLiveUsers <> invalid
        row = createObject("RoSGNode", "ContentNode")
        row.title = tr("followedLiveUsers")
        first = true
        itemsPerRow = 3
        for i = 0 to (m.GetcontentTask.response.data.user.followedLiveUsers.edges.count() - 1) step 1
            if first
                first = false
            else if i mod itemsPerRow = 0
                row = createObject("RoSGNode", "ContentNode")
            end if
            ' for each stream in m.GetcontentTask.response.data.user.followedLiveUsers.edges
            stream = m.GetcontentTask.response.data.user.followedLiveUsers.edges[i].node.stream
            ' type_name = stream.node.__typename
            if stream["__typename"].toStr() <> invalid and stream["__typename"].toStr() = "Stream"
                rowItem = createObject("RoSGNode", "TwitchContentNode")
                rowItem.contentId = stream.Id
                rowItem.contentType = "LIVE"
                rowItem.previewImageURL = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", stream.broadcaster.login, "320", "180")
                rowItem.contentTitle = stream.broadcaster.broadcastSettings.title
                rowItem.viewersCount = stream.viewersCount
                rowItem.streamerDisplayName = stream.broadcaster.displayName
                rowItem.streamerLogin = stream.broadcaster.login
                rowItem.streamerId = stream.broadcaster.id
                rowItem.streamerProfileImageUrl = stream.broadcaster.profileImageURL
                rowItem.gameDisplayName = stream.game.displayName
                rowItem.gameBoxArtUrl = Left(stream.game.boxArtUrl, Len(stream.game.boxArtUrl) - 20) + "188x250.jpg"
                rowItem.gameId = stream.game.Id
                rowItem.gameName = stream.game.name
                row.appendChild(rowItem)
            end if
            appended = false
            if row.getChildCount() = itemsPerRow
                contentCollection.appendChild(row)
                appended = true
            end if
        end for
        if not appended and row <> invalid and row.getchildcount() > 0
            contentCollection.appendChild(row)
        end if
    end if
    ? "LiveStreamSection Complete: "; TimeStamp()
    if m.GetcontentTask.response.data <> invalid and m.GetcontentTask.response.data.user <> invalid and m.GetcontentTask.response.data.user.follows <> invalid
        row = createObject("RoSGNode", "ContentNode")
        row.title = tr("followedOfflineUsers")
        first = true
        itemsPerRow = 6
        m.GetcontentTask.response.data.user.follows.edges.sortBy("node.login")
        for i = 0 to (m.GetcontentTask.response.data.user.follows.edges.count() - 1) step 1
            ? "OfflineSection Start: "; TimeStamp()
            if first
                first = false
            else if i mod itemsPerRow = 0
                row = createObject("RoSGNode", "ContentNode")
            end if
            stream = m.GetcontentTask.response.data.user.follows.edges[i]
            try
                rowItem = createObject("RoSGNode", "TwitchContentNode")
                rowItem.contentId = stream.node.Id
                rowItem.contentType = "USER"
                rowItem.previewImageURL = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", stream.node.login, "320", "180")
                rowItem.contentTitle = stream.node.displayName
                rowItem.followerCount = stream.node.followers.totalCount
                rowItem.streamerDisplayName = stream.node.displayName
                rowItem.streamerLogin = stream.node.login
                rowItem.streamerId = stream.node.id
                rowItem.streamerProfileImageUrl = stream.node.profileImageURL
                ' rowItem.gameDisplayName = stream.node.game.displayName
                ' rowItem.gameBoxArtUrl = Left(stream.node.game.boxArtUrl, Len(stream.node.game.boxArtUrl) - 20) + "188x250.jpg"
                ' rowItem.gameId = stream.node.game.Id
                ' rowItem.gameName = stream.node.game.name
                row.appendChild(rowItem)
            catch e
                ? "error: "; e
            end try
            ' end if
            appended = false
            if row.getChildCount() = itemsPerRow
                contentCollection.appendChild(row)
                appended = true
            end if
        end for
        if not appended and row <> invalid and row.getchildcount() > 0
            contentCollection.appendChild(row)
        end if
        ? "OfflineStreamSection Complete: "; TimeStamp()
    end if
    updateRowList(contentCollection)
end sub

function updateRowList(contentCollection)
    ? "updateRowList: "; TimeStamp()
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
                rowHeights.push(295)
            else
                rowHeights.push(255)
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
        if row.getchild(0).contentType = "USER"
            rowItemSize.push([150, 150])
            if hasRowLabel
                rowHeights.push(260)
            else
                rowHeights.push(240)
            end if
        end if
    end for
    m.rowlist.rowHeights = rowHeights
    m.rowlist.showRowLabel = showRowLabel
    m.rowlist.rowItemSize = rowItemSize
    m.rowlist.content = contentCollection
    m.rowlist.numRows = m.rowlist.content.getChildCount()
    m.rowlist.rowlabelcolor = m.global.constants.colors.twitch.purple10
end function

sub handleItemSelected()
    if m.rowlist.focusedChild <> invalid
        item = m.rowList
    else if m.offlinelist.focusedChild <> invalid
        item = m.offlinelist
    end if
    selectedRow = item.content.getchild(item.rowItemSelected[0])
    selectedItem = selectedRow.getChild(item.rowItemSelected[1])
    m.top.contentSelected = selectedItem
end sub

sub handleLiveItemSelected()
    selectedRow = m.rowlist.content.getchild(m.rowlist.rowItemSelected[0])
    selectedItem = selectedRow.getChild(m.rowlist.rowItemSelected[1])
    m.top.playContent = true
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
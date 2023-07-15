
function TwitchGraphQLRequest($data, $access_token = $null, $device_code = $null) {
    $headers = @{
        "Accept"          = "*/*"
        "Authorization"   = "OAuth $access_token"
        "Client-Id"       = "ue6666qo983tsx6so1t0vnawi233wa"
        "Device-ID"       = $device_code
        "Origin"          = "https://switch.tv.twitch.tv"
        "Referer"         = "https://switch.tv.twitch.tv/"
        "Accept-Language" = "en-US,en"
        "content-type"    = "application/json"
    }
    $req = Invoke-RestMethod -Uri "https://gql.twitch.tv/gql" -Method POST -Body $data -Headers $headers

    return $req
}

function get-OAuthToken($device_code) {
    $url = "https://id.twitch.tv/oauth2/token" + "?client_id=ue6666qo983tsx6so1t0vnawi233wa&device_code=" + $device_code + "&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code"
    $headers = @{
        "content-type" = "application/x-www-form-urlencoded"
        "origin"       = "https://switch.tv.twitch.tv"
        "referer"      = "https://switch.tv.twitch.tv/"
        "accept"       = "application/json"
    }
    $method = "POST"
    while ($true) {
        $req = Invoke-RestMethod -Uri $url -Headers $headers -Method $method -SkipHttpErrorCheck
        if ($req.access_token) {
            break
        }
        else {
            Start-Sleep 5
        }
    }
    return $req
}

function get-rendezvouztoken {
    $url = "https://id.twitch.tv/oauth2/device?scopes=channel_read%20chat%3Aread%20user_blocks_edit%20user_blocks_read%20user_follows_edit%20user_read&client_id=ue6666qo983tsx6so1t0vnawi233wa"
    $headers = @{
        "content-type" = "application/x-www-form-urlencoded"
        "origin"       = "https://switch.tv.twitch.tv"
        "referer"      = "https://switch.tv.twitch.tv/"
    }
    $method = "POST"
    $req = Invoke-RestMethod -Uri $url -Headers $headers -Method $method
    return $req
}



function TwitchHelixApiRequest($access_token = $null, $device_code = $null, $data = $null, $endpoint, $twitchargs, $method) {

    $url = "https://api.twitch.tv/helix/" + $endpoint + "?" + $twitchargs
    $headers = @{
        "Accept"        = "*/*"
        "Authorization" = "Bearer $access_token"
        "Client-Id"     = "ue6666qo983tsx6so1t0vnawi233wa"
        "Device-ID"     = $device_code
        "Origin"        = "https://switch.tv.twitch.tv"
        "Referer"       = "https://switch.tv.twitch.tv/"
    }
    if ($null -eq $data) {
        $rsp = Invoke-RestMethod -Uri $url -Headers $headers -Method $method
    }
    else {
        $rsp = Invoke-RestMethod -Uri $url -Headers $headers -Method $method -Body $data
    }
    return $rsp
}



$info = get-rendezvouztoken
$user_code = $info.user_code
$device_code = $info.device_code
Write-Host "Authenticate to https://www.twitch.tv/activate using code $user_code"
$token = get-OAuthToken -device_code $device_code
$access_token = $token.access_token

$body = "{`"query`":`"query Homepage_Query(\n  `$itemsPerRow: Int!\n  `$limit: Int!\n  `$platform: String!\n  `$requestID: String!\n) {\n  currentUser {\n    id\n    __typename\n    login\n    roles {\n      isStaff\n    }\n  }\n  shelves(itemsPerRow: `$itemsPerRow, first: `$limit, platform: `$platform, requestID: `$requestID) {\n    edges {\n      node {\n        id\n        __typename\n        title {\n          fallbackLocalizedTitle\n          localizedTitleTokens {\n            node {\n              __typename\n              ... on Game {\n                __typename\n                displayName\n                name\n              }\n              ... on TextToken {\n                __typename\n                text\n                location\n              }\n            }\n          }\n        }\n        trackingInfo {\n          reasonTarget\n          reasonTargetType\n          reasonType\n          rowName\n        }\n        content {\n          edges {\n            trackingID\n            node {\n              __typename\n              __isShelfContent: __typename\n              ... on Stream {\n                id\n                __typename\n                previewImageURL\n                broadcaster {\n                  displayName\n                  broadcastSettings {\n                    title\n                    id\n                    __typename\n                  }\n                  id\n                  __typename\n                }\n                game {\n                  displayName\n                  boxArtURL\n                  id\n                  __typename\n                }\n                ...FocusableStreamCard_stream\n              }\n              ... on Game {\n                ...FocusableCategoryCard_category\n                id\n                __typename\n                streams(first: 1) {\n                  edges {\n                    node {\n                      id\n                      __typename\n                      previewImageURL\n                      broadcaster {\n                        displayName\n                        broadcastSettings {\n                          title\n                          id\n                          __typename\n                        }\n                        id\n                        __typename\n                      }\n                      game {\n                        displayName\n                        boxArtURL\n                        id\n                        __typename\n                      }\n                    }\n                  }\n                }\n              }\n            }\n          }\n        }\n      }\n    }\n  }\n}\n\nfragment FocusableCategoryCard_category on Game {\n  name\n  id\n  __typename\n  displayName\n  viewersCount\n  boxArtURL\n}\n\nfragment FocusableStreamCard_stream on Stream {\n  broadcaster {\n    displayName\n    login\n    hosting {\n      id\n      __typename\n    }\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    profileImageURL(width: 50)\n    id\n    __typename\n  }\n  game {\n    displayName\n    name\n    id\n    __typename\n  }\n  id\n  __typename\n  previewImageURL\n  type\n  viewersCount\n}\n`",`"variables`":{`"itemsPerRow`":20,`"limit`":8,`"platform`":`"switch_web_tv`",`"requestID`":`"lwxcwatjfMfwXYPz`"}}"
$bodytest = TwitchGraphQLRequest -data $body -access_token $access_token -device_code $device_code


$catbody = "{`"query`":`"query GamesDirectory_Query(\n  `$first: Int!\n) {\n  currentUser {\n    id\n    __typename\n    login\n    roles {\n      isStaff\n    }\n  }\n  games(first: `$first) {\n    edges {\n      node {\n        ...FocusableCategoryCard_category\n        id\n        __typename\n      }\n    }\n  }\n}\n\nfragment FocusableCategoryCard_category on Game {\n  name\n  id\n  __typename\n  displayName\n  viewersCount\n  boxArtURL\n}\n`",`"variables`":{`"first`":80}}"
$test = TwitchGraphQLRequest -data $catbody -access_token $access_token -device_code $device_code

$followBody = "{`"query`": `"query FollowingPage_Query(\n  `$first: Int!\n  `$liveUserCursor: Cursor\n  `$offlineUserCursor: Cursor\n  `$followedGameType: FollowedGamesType\n  `$categoryFirst: Int!\n  `$itemsPerRow: Int!\n  `$limit: Int!\n  `$platform: String!\n  `$requestID: String!\n) {\n  user {\n    followedLiveUsers(first: `$first, after: `$liveUserCursor) {\n      edges {\n        node {\n          id\n          __typename\n        }\n      }\n    }\n    follows(first: `$first, after: `$offlineUserCursor) {\n      edges {\n        node {\n          id\n          __typename\n          stream {\n            id\n            __typename\n          }\n        }\n      }\n    }\n    followedGames(first: `$categoryFirst, type: `$followedGameType) {\n      nodes {\n        id\n        __typename\n      }\n    }\n    ...LiveStreamInfiniteShelf_followedLiveUsers\n    ...OfflineInfiniteShelf_followedUsers\n    ...CategoryShelf_followedCategories\n    id\n    __typename\n  }\n  ...FollowingPageEmpty_Query\n}\n\nfragment CategoryBannerContent_category on Game {\n  streams(first: 1) {\n    edges {\n      node {\n        ...FollowingLiveStreamBannerContent_stream\n        id\n        __typename\n      }\n    }\n  }\n}\n\nfragment CategoryShelf_followedCategories on User {\n  followedGames(first: `$categoryFirst, type: `$followedGameType) {\n    nodes {\n      id\n      __typename\n      displayName\n      developers\n      boxArtURL\n      ...FocusableCategoryCard_category\n      ...CategoryBannerContent_category\n      streams(first: 1) {\n        edges {\n          node {\n            previewImageURL\n            id\n            __typename\n          }\n        }\n      }\n    }\n  }\n}\n\nfragment FocusableCategoryCard_category on Game {\n  id\n  __typename\n  name\n  displayName\n  viewersCount\n  boxArtURL\n}\n\nfragment FocusableOfflineChannelCard_channel on User {\n  displayName\n  followers {\n    totalCount\n  }\n  lastBroadcast {\n    startedAt\n    id\n    __typename\n  }\n  login\n  profileImageURL(width: 300)\n}\n\nfragment FocusableStreamCard_stream on Stream {\n  broadcaster {\n    displayName\n    login\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    profileImageURL(width: 50)\n    id\n    __typename\n  }\n  game {\n    displayName\n    name\n    id\n    __typename\n  }\n  id\n  __typename\n  previewImageURL\n  type\n  viewersCount\n}\n\nfragment FollowingLiveStreamBannerContent_stream on Stream {\n  game {\n    displayName\n    id\n    __typename\n  }\n  broadcaster {\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    displayName\n    id\n    __typename\n  }\n}\n\nfragment FollowingPageEmpty_Query on Query {\n  shelves(itemsPerRow: `$itemsPerRow, first: `$limit, platform: `$platform, requestID: `$requestID) {\n    edges {\n      node {\n        id\n        __typename\n        title {\n          fallbackLocalizedTitle\n          localizedTitleTokens {\n            node {\n              __typename\n              ... on Game {\n                __typename\n                displayName\n                name\n                id\n                __typename\n              }\n              ... on TextToken {\n                __typename\n                text\n                location\n              }\n              ... on BrowsableCollection {\n                id\n                __typename\n              }\n              ... on Tag {\n                id\n                __typename\n              }\n              ... on User {\n                id\n                __typename\n              }\n            }\n          }\n        }\n        trackingInfo {\n          rowName\n        }\n        content {\n          edges {\n            trackingID\n            node {\n              __typename\n              __isShelfContent: __typename\n              ... on Stream {\n                id\n                __typename\n                previewImageURL\n                broadcaster {\n                  displayName\n                  broadcastSettings {\n                    title\n                    id\n                    __typename\n                  }\n                  id\n                  __typename\n                }\n                game {\n                  displayName\n                  boxArtURL\n                  id\n                  __typename\n                }\n                ...FocusableStreamCard_stream\n              }\n              ... on Game {\n                ...FocusableCategoryCard_category\n                id\n                __typename\n                streams(first: 1) {\n                  edges {\n                    node {\n                      id\n                      __typename\n                      previewImageURL\n                      broadcaster {\n                        displayName\n                        broadcastSettings {\n                          title\n                          id\n                          __typename\n                        }\n                        id\n                        __typename\n                      }\n                      game {\n                        displayName\n                        boxArtURL\n                        id\n                        __typename\n                      }\n                    }\n                  }\n                }\n              }\n              ... on Clip {\n                id\n                __typename\n              }\n              ... on Tag {\n                id\n                __typename\n              }\n              ... on Video {\n                id\n                __typename\n              }\n            }\n          }\n        }\n      }\n    }\n  }\n}\n\nfragment LiveStreamInfiniteShelf_followedLiveUsers on User {\n  followedLiveUsers(first: `$first, after: `$liveUserCursor) {\n    edges {\n      cursor\n      node {\n        id\n        __typename\n        displayName\n        stream {\n          previewImageURL\n          game {\n            boxArtURL\n            id\n            __typename\n          }\n          ...FollowingLiveStreamBannerContent_stream\n          ...FocusableStreamCard_stream\n          id\n          __typename\n        }\n      }\n    }\n  }\n}\n\nfragment OfflineBannerContent_user on User {\n  displayName\n  lastBroadcast {\n    startedAt\n    game {\n      displayName\n      id\n      __typename\n    }\n    id\n    __typename\n  }\n  stream {\n    id\n    __typename\n  }\n}\n\nfragment OfflineInfiniteShelf_followedUsers on User {\n  follows(first: `$first, after: `$offlineUserCursor) {\n    edges {\n      cursor\n      node {\n        id\n        __typename\n        bannerImageURL\n        displayName\n        lastBroadcast {\n          game {\n            boxArtURL\n            id\n            __typename\n          }\n          id\n          __typename\n        }\n        stream {\n          id\n          __typename\n        }\n        ...OfflineBannerContent_user\n        ...FocusableOfflineChannelCard_channel\n      }\n    }\n  }\n}\n`",`"variables`": {`"first`": 100,`"followedGameType`": `"ALL`",`"categoryFirst`": 100,`"itemsPerRow`": 100,`"limit`": 8,`"platform`": `"switch_web_tv`",`"requestID`": `"$([guid]::newGuid())`"}}"

$test = TwitchGraphQLRequest -data $followbody -access_token $access_token -device_code $device_code

$gamePage = "{`"query`": `"query GameDirectory_Query(\n  `$gameAlias: String!\n  `$channelsCount: Int!\n) {\n  currentUser {\n    id\n    __typename\n    login\n    roles {\n      isStaff\n    }\n  }\n  game(name: `$gameAlias) {\n    boxArtURL\n    displayName\n    name\n    streams(first: `$channelsCount) {\n      edges {\n        node {\n          id\n          __typename\n          previewImageURL\n          ...FocusableStreamCard_stream\n        }\n      }\n    }\n    id\n    __typename\n  }\n}\n\nfragment FocusableStreamCard_stream on Stream {\n  broadcaster {\n    displayName\n    login\n    hosting {\n      id\n      __typename\n    }\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    profileImageURL(width: 50)\n    id\n    __typename\n  }\n  game {\n    displayName\n    name\n    id\n    __typename\n  }\n  id\n  __typename\n  previewImageURL\n  type\n  viewersCount\n}\n`",`"variables`": {`"gameAlias`": `"just chatting`",`"channelsCount`": 40}}"

$test = TwitchGraphQLRequest -data $gamePage -access_token $access_token -device_code $device_code

$channelPage = "{`"query`": `"query ChannelHome_Query(\n  `$login: String!\n  `$platform: String!\n  `$playerType: String!\n  `$skipPlayToken: Boolean!\n) {\n  channel: user(login: `$login) {\n    id\n    __typename\n    login\n    stream {\n      id\n      __typename\n    }\n    videoShelves {\n      edges {\n        node {\n          id\n          __typename\n          title\n          items {\n            __typename\n            __isVideoShelfItem: __typename\n            ... on Clip {\n              ...FocusableClipCard_clip\n            }\n            ... on Video {\n              ...FocusableVodCard_video\n            }\n          }\n        }\n      }\n    }\n    ...ProfileBanner_channel\n  }\n  currentUser {\n    ...ProfileBanner_currentUser\n    id\n    __typename\n    login\n    roles {\n      isStaff\n    }\n  }\n  ...StreamPlayer_token\n  ...VodPreviewPlayerWrapper_previewToken\n}\n\nfragment BannerButtonsRow_channel on User {\n  ...FocusableFollowButton_channel\n  displayName\n  hosting {\n    displayName\n    id\n    __typename\n    login\n    stream {\n      id\n      __typename\n      type\n    }\n  }\n  id\n  __typename\n  login\n  stream {\n    id\n    __typename\n    type\n  }\n  videos(first: 1, sort: TIME) {\n    edges {\n      node {\n        id\n        __typename\n      }\n    }\n  }\n}\n\nfragment BannerChannelStatus_channel on User {\n  displayName\n  hosting {\n    displayName\n    id\n    __typename\n    login\n    stream {\n      id\n      __typename\n      type\n    }\n  }\n  id\n  __typename\n  login\n  stream {\n    id\n    __typename\n    type\n  }\n}\n\nfragment DefaultPreviewContent_channel on User {\n  ...SwitchPreviewContent_channel\n  ...StreamPreviewPlayer_channel\n  hosting {\n    id\n    __typename\n    login\n    stream {\n      id\n      __typename\n      type\n      viewersCount\n    }\n  }\n  id\n  __typename\n  login\n  stream {\n    id\n    __typename\n    type\n    viewersCount\n  }\n  videos(first: 1, sort: TIME) {\n    edges {\n      node {\n        id\n        __typename\n        previewThumbnailURL\n        ...VodPreviewPlayer_video\n      }\n    }\n  }\n}\n\nfragment DefaultPreviewContent_currentUser on User {\n  ...StreamPreviewPlayer_currentUser\n  ...VodPreviewPlayer_currentUser\n}\n\nfragment FocusableClipCard_clip on Clip {\n  broadcaster {\n    login\n    id\n    __typename\n  }\n  createdAt\n  durationSeconds\n  game {\n    boxArtURL\n    displayName\n    id\n    __typename\n  }\n  id\n  __typename\n  slug\n  thumbnailURL\n  title\n  viewCount\n}\n\nfragment FocusableFollowButton_channel on User {\n  login\n  id\n  __typename\n  self {\n    follower {\n      followedAt\n    }\n  }\n}\n\nfragment FocusableVodCard_video on Video {\n  createdAt\n  lengthSeconds\n  game {\n    boxArtURL\n    displayName\n    id\n    __typename\n  }\n  id\n  __typename\n  previewThumbnailURL\n  self {\n    viewingHistory {\n      position\n    }\n  }\n  title\n  viewCount\n}\n\nfragment ProfileBanner_channel on User {\n  ...BannerButtonsRow_channel\n  ...BannerChannelStatus_channel\n  ...SwitchPreviewContent_channel\n  ...DefaultPreviewContent_channel\n  description\n  displayName\n  followers {\n    totalCount\n  }\n  hosting {\n    id\n    __typename\n    login\n    profileImageURL(width: 70)\n  }\n  id\n  __typename\n  login\n  profileImageURL(width: 70)\n  profileViewCount\n}\n\nfragment ProfileBanner_currentUser on User {\n  ...DefaultPreviewContent_currentUser\n}\n\nfragment StreamPlayer_channel on User {\n  id\n  __typename\n  login\n  roles {\n    isPartner\n  }\n  self {\n    subscriptionBenefit {\n      id\n      __typename\n    }\n  }\n  stream {\n    id\n    __typename\n    game {\n      name\n      id\n      __typename\n    }\n    previewImageURL\n  }\n}\n\nfragment StreamPlayer_currentUser on User {\n  hasTurbo\n  id\n  __typename\n}\n\nfragment StreamPlayer_token on Query {\n  user(login: `$login) {\n    login\n    stream @skip(if: `$skipPlayToken) {\n      playbackAccessToken(params: {platform: `$platform, playerType: `$playerType}) {\n        signature\n        value\n      }\n      id\n      __typename\n    }\n    id\n    __typename\n  }\n}\n\nfragment StreamPreviewPlayer_channel on User {\n  hosting {\n    ...StreamPlayer_channel\n    id\n    __typename\n    login\n    stream {\n      id\n      __typename\n      type\n      viewersCount\n    }\n  }\n  ...StreamPlayer_channel\n  id\n  __typename\n  login\n  stream {\n    id\n    __typename\n    type\n    viewersCount\n    restrictionType\n    self {\n      canWatch\n    }\n  }\n  displayName\n  broadcastSettings {\n    isMature\n    id\n    __typename\n  }\n}\n\nfragment StreamPreviewPlayer_currentUser on User {\n  ...StreamPlayer_currentUser\n}\n\nfragment SwitchPreviewContent_channel on User {\n  id\n  __typename\n  login\n  stream {\n    id\n    __typename\n    previewImageURL\n  }\n  videos(first: 1, sort: TIME) {\n    edges {\n      node {\n        id\n        __typename\n        previewThumbnailURL\n      }\n    }\n  }\n}\n\nfragment VodPlayerBase_currentUser on User {\n  id\n  __typename\n  hasTurbo\n}\n\nfragment VodPlayerBase_video on Video {\n  broadcastType\n  id\n  __typename\n  game {\n    name\n    id\n    __typename\n  }\n  owner {\n    id\n    __typename\n    login\n    roles {\n      isPartner\n    }\n    self {\n      subscriptionBenefit {\n        id\n        __typename\n      }\n    }\n  }\n  self {\n    viewingHistory {\n      position\n    }\n  }\n}\n\nfragment VodPlayerOverlay_video on Video {\n  createdAt\n  lengthSeconds\n  viewCount\n}\n\nfragment VodPreviewPlayerWrapper_previewToken on Query {\n  user(login: `$login) @skip(if: `$skipPlayToken) {\n    videos(first: 1) {\n      edges {\n        node {\n          playbackAccessToken(params: {platform: `$platform, playerType: `$playerType}) {\n            signature\n            value\n          }\n          id\n          __typename\n        }\n      }\n    }\n    id\n    __typename\n  }\n}\n\nfragment VodPreviewPlayer_currentUser on User {\n  ...VodPlayerBase_currentUser\n}\n\nfragment VodPreviewPlayer_video on Video {\n  ...VodPlayerBase_video\n  ...VodPlayerOverlay_video\n  muteInfo {\n    mutedSegmentConnection {\n      nodes {\n        duration\n      }\n    }\n  }\n  owner {\n    id\n    __typename\n    login\n    broadcastSettings {\n      isMature\n      id\n      __typename\n    }\n    subscriptionProducts {\n      displayName\n      hasSubonlyVideoArchive\n      id\n      __typename\n    }\n    displayName\n  }\n  resourceRestriction {\n    type\n    id\n    __typename\n  }\n  self {\n    isRestricted\n  }\n}\n`",`"variables`": {`"login`": `"willneff`", `"platform`": `"switch_web_tv`", `"playerType`": `"quasar`", `"skipPlayToken`": false}}"
$test = TwitchGraphQLRequest -data $channelPage -access_token $access_token -device_code $device_code

$channelShell = "{ `"operationName`": `"ChannelShell`", `"variables`": { `"login`": `"paymoneywubby`"}, `"extensions`": {`"persistedQuery`": {`"version`": 1,`"sha256Hash`": `"580ab410bcd0c1ad194224957ae2241e5d252b2c5173d8e0cce9d32d5bb14efe`"}}}"
$test = TwitchGraphQLRequest -data $channelShell -access_token $access_token -device_code $device_code


$followSmallBody = "{`"query`": `"query FollowingPage_Query(\n  `$first: Int!\n  `$liveUserCursor: Cursor\n  `$offlineUserCursor: Cursor\n  `$followedGameType: FollowedGamesType\n  `$categoryFirst: Int!\n  `$itemsPerRow: Int!\n  `$limit: Int!\n  `$platform: String!\n  `$requestID: String!\n) {\n  user {\n    followedLiveUsers(first: `$first, after: `$liveUserCursor) {\n      edges {\n        node {\n          id\n          __typename\n        }\n      }\n    }\n    \n    ...LiveStreamInfiniteShelf_followedLiveUsers\n    id\n    __typename\n  }\n  ...FollowingPageEmpty_Query\n}\n\nfragment FocusableStreamCard_stream on Stream {\n  broadcaster {\n    displayName\n    login\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    profileImageURL(width: 50)\n    id\n    __typename\n  }\n  game {\n    displayName\n    name\n    id\n    __typename\n  }\n  id\n  __typename\n  previewImageURL\n  type\n  viewersCount\n}\n\nfragment FollowingLiveStreamBannerContent_stream on Stream {\n  game {\n    displayName\n    id\n    __typename\n  }\n  broadcaster {\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    displayName\n    id\n    __typename\n  }\n}\n\nfragment FollowingPageEmpty_Query on Query {\n  shelves(itemsPerRow: `$itemsPerRow, first: `$limit, platform: `$platform, requestID: `$requestID) {\n    edges {\n      node {\n        id\n        __typename\n        title {\n          fallbackLocalizedTitle\n          localizedTitleTokens {\n            node {\n              __typename\n              ... on Game {\n                __typename\n                displayName\n                name\n                id\n                __typename\n              }\n              ... on TextToken {\n                __typename\n                text\n                location\n              }\n              ... on BrowsableCollection {\n                id\n                __typename\n              }\n              ... on Tag {\n                id\n                __typename\n              }\n              ... on User {\n                id\n                __typename\n              }\n            }\n          }\n        }\n        trackingInfo {\n          rowName\n        }\n        content {\n          edges {\n            trackingID\n            node {\n              __typename\n              __isShelfContent: __typename\n              ... on Stream {\n                id\n                __typename\n                previewImageURL\n                broadcaster {\n                  displayName\n                  broadcastSettings {\n                    title\n                    id\n                    __typename\n                  }\n                  id\n                  __typename\n                }\n                game {\n                  displayName\n                  boxArtURL\n                  id\n                  __typename\n                }\n                ...FocusableStreamCard_stream\n              }\n              ... on Game {\n                ...FocusableCategoryCard_category\n                id\n                __typename\n                streams(first: 1) {\n                  edges {\n                    node {\n                      id\n                      __typename\n                      previewImageURL\n                      broadcaster {\n                        displayName\n                        broadcastSettings {\n                          title\n                          id\n                          __typename\n                        }\n                        id\n                        __typename\n                      }\n                      game {\n                        displayName\n                        boxArtURL\n                        id\n                        __typename\n                      }\n                    }\n                  }\n                }\n              }\n              ... on Clip {\n                id\n                __typename\n              }\n              ... on Tag {\n                id\n                __typename\n              }\n              ... on Video {\n                id\n                __typename\n              }\n            }\n          }\n        }\n      }\n    }\n  }\n}\n\nfragment LiveStreamInfiniteShelf_followedLiveUsers on User {\n  followedLiveUsers(first: `$first, after: `$liveUserCursor) {\n    edges {\n      cursor\n      node {\n        id\n        __typename\n        displayName\n        stream {\n          previewImageURL\n          game {\n            boxArtURL\n            id\n            __typename\n          }\n          ...FollowingLiveStreamBannerContent_stream\n          ...FocusableStreamCard_stream\n          id\n          __typename\n        }\n      }\n    }\n  }\n}\n`", `"variables`": { `"first`": 100, `"followedGameType`": `"ALL`", `"categoryFirst`": 100, `"itemsPerRow`": 100, `"limit`": 8, `"platform`": `"switch_web_tv`", `"requestID`": `"$([guid]::newGuid())`" }}"

$test = TwitchGraphQLRequest -data $followSmallbody -access_token $access_token -device_code $device_code

"query FollowingPage_Query(\n  `$first: Int!\n  `$liveUserCursor: Cursor\n  `$platform: String!\n  `$requestID: String!\n) {\n  user {\n    followedLiveUsers(first: `$first, after: `$liveUserCursor) {\n      edges {\n        node {\n          id\n          __typename\n        }\n      }\n    }\n    \n    ...LiveStreamInfiniteShelf_followedLiveUsers\n    id\n    __typename\n  }\n  ...FollowingPageEmpty_Query\n}\n\nfragment FocusableStreamCard_stream on Stream {\n  broadcaster {\n    displayName\n    login\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    profileImageURL(width: 50)\n    id\n    __typename\n  }\n  game {\n    displayName\n    name\n    id\n    __typename\n  }\n  id\n  __typename\n  previewImageURL\n  type\n  viewersCount\n}\n\nfragment FollowingLiveStreamBannerContent_stream on Stream {\n  game {\n    displayName\n    id\n    __typename\n  }\n  broadcaster {\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    displayName\n    id\n    __typename\n  }\n}\n\nfragment LiveStreamInfiniteShelf_followedLiveUsers on User {\n  followedLiveUsers(first: `$first, after: `$liveUserCursor) {\n    edges {\n      cursor\n      node {\n        id\n        __typename\n        displayName\n        stream {\n          previewImageURL\n          game {\n            boxArtURL\n            id\n            __typename\n          }\n          ...FollowingLiveStreamBannerContent_stream\n          ...FocusableStreamCard_stream\n          id\n          __typename\n        }\n      }\n    }\n  }\n}\n\n"
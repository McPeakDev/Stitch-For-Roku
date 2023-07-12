sub init()
    m.deviceInfo = createObject("roDeviceInfo")
end sub

function writeResponse(data)
    if data <> invalid
        m.top.response = data
    else
        m.top.response = { "response": invalid }
    end if
    m.top.control = "STOP"
end function

function GetRandomUUID()
    di = CreateObject("roDeviceInfo")
    return di.GetRandomUUID()
end function

function getDeviceLocale()
    di = CreateObject("roDeviceInfo")
    return di.GetCurrentLocale().Replace("_", "-")
end function

function TwitchGraphQLRequest(data)
    access_token = invalid
    ' doubled up here in stead of defaulting to "" because access_token is dependent on device_code
    if get_user_setting("device_code") <> invalid
        device_code = get_user_setting("device_code")
        if get_user_setting("access_token") <> invalid
            access_token = "OAuth " + get_user_setting("access_token")
        end if
    end if
    reqHeaders = {
        "Accept": "*/*"
        "Client-Id": "ue6666qo983tsx6so1t0vnawi233wa"
        "Device-ID": device_code
        "Origin": "https://switch.tv.twitch.tv"
        "Referer": "https://switch.tv.twitch.tv/"
        "Accept-Language": getDeviceLocale()
    }
    if access_token <> invalid
        reqHeaders["Authorization"] = access_token
    end if
    req = HttpRequest({
        url: "https://gql.twitch.tv/gql"
        headers: reqHeaders
        method: "POST"
        data: data
    })
    rsp = ParseJSON(req.send())
    return rsp
end function

function getHomePageQuery() as object
    rsp = TwitchGraphQLRequest({
        query: "query Homepage_Query(" + chr(10) + "  $itemsPerRow: Int!" + chr(10) + "  $limit: Int!" + chr(10) + "  $platform: String!" + chr(10) + "  $requestID: String!" + chr(10) + ") {" + chr(10) + "  currentUser {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  shelves(itemsPerRow: $itemsPerRow, first: $limit, platform: $platform, requestID: $requestID) {" + chr(10) + "    edges {" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        title {" + chr(10) + "          fallbackLocalizedTitle" + chr(10) + "          localizedTitleTokens {" + chr(10) + "            node {" + chr(10) + "              __typename" + chr(10) + "              ... on Game {" + chr(10) + "                __typename" + chr(10) + "                displayName" + chr(10) + "                name" + chr(10) + "              }" + chr(10) + "              ... on TextToken {" + chr(10) + "                __typename" + chr(10) + "                text" + chr(10) + "                location" + chr(10) + "              }" + chr(10) + "            }" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "        trackingInfo {" + chr(10) + "          reasonTarget" + chr(10) + "          reasonTargetType" + chr(10) + "          reasonType" + chr(10) + "          rowName" + chr(10) + "        }" + chr(10) + "        content {" + chr(10) + "          edges {" + chr(10) + "            trackingID" + chr(10) + "            node {" + chr(10) + "              __typename" + chr(10) + "              __isShelfContent: __typename" + chr(10) + "              ... on Stream {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "                previewImageURL" + chr(10) + "                broadcaster {" + chr(10) + "                  displayName" + chr(10) + "                  broadcastSettings {" + chr(10) + "                    title" + chr(10) + "                    id" + chr(10) + "                    __typename" + chr(10) + "                  }" + chr(10) + "                  id" + chr(10) + "                  __typename" + chr(10) + "                }" + chr(10) + "                game {" + chr(10) + "                  displayName" + chr(10) + "                  boxArtURL" + chr(10) + "                  id" + chr(10) + "                  __typename" + chr(10) + "                }" + chr(10) + "                ...FocusableStreamCard_stream" + chr(10) + "              }" + chr(10) + "              ... on Game {" + chr(10) + "                ...FocusableCategoryCard_category" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "                streams(first: 1) {" + chr(10) + "                  edges {" + chr(10) + "                    node {" + chr(10) + "                      id" + chr(10) + "                      __typename" + chr(10) + "                      previewImageURL" + chr(10) + "                      broadcaster {" + chr(10) + "                        displayName" + chr(10) + "                        broadcastSettings {" + chr(10) + "                          title" + chr(10) + "                          id" + chr(10) + "                          __typename" + chr(10) + "                        }" + chr(10) + "                        id" + chr(10) + "                        __typename" + chr(10) + "                      }" + chr(10) + "                      game {" + chr(10) + "                        displayName" + chr(10) + "                        boxArtURL" + chr(10) + "                        id" + chr(10) + "                        __typename" + chr(10) + "                      }" + chr(10) + "                    }" + chr(10) + "                  }" + chr(10) + "                }" + chr(10) + "              }" + chr(10) + "            }" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableCategoryCard_category on Game {" + chr(10) + "  name" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  displayName" + chr(10) + "  viewersCount" + chr(10) + "  boxArtURL" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableStreamCard_stream on Stream {" + chr(10) + "  broadcaster {" + chr(10) + "    displayName" + chr(10) + "    login" + chr(10) + "    hosting {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    broadcastSettings {" + chr(10) + "      title" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    profileImageURL(width: 50)" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  game {" + chr(10) + "    displayName" + chr(10) + "    name" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewImageURL" + chr(10) + "  type" + chr(10) + "  viewersCount" + chr(10) + "}" + chr(10) + ""
        variables: {
            "itemsPerRow": 50,
            "limit": 50,
            "platform": "switch_web_tv",
            "requestID": getRandomUUID()
        }
    })
    writeResponse(rsp)
end function

function getCategoryQuery() as object
    rsp = TwitchGraphQLRequest({
        query: "query GameDirectory_Query(" + chr(34) + "  $gameAlias: String!" + chr(34) + "  $channelsCount: Int!" + chr(34) + ") {" + chr(34) + "  currentUser {" + chr(34) + "    id" + chr(34) + "    __typename" + chr(34) + "    login" + chr(34) + "    roles {" + chr(34) + "      isStaff" + chr(34) + "    }" + chr(34) + "  }" + chr(34) + "  game(name: $gameAlias) {" + chr(34) + "    boxArtURL" + chr(34) + "    displayName" + chr(34) + "    name" + chr(34) + "    streams(first: $channelsCount) {" + chr(34) + "      edges {" + chr(34) + "        node {" + chr(34) + "          id" + chr(34) + "          __typename" + chr(34) + "          previewImageURL" + chr(34) + "          ...FocusableStreamCard_stream" + chr(34) + "        }" + chr(34) + "      }" + chr(34) + "    }" + chr(34) + "    id" + chr(34) + "    __typename" + chr(34) + "  }" + chr(34) + "}" + chr(34) + "" + chr(34) + "fragment FocusableStreamCard_stream on Stream {" + chr(34) + "  broadcaster {" + chr(34) + "    displayName" + chr(34) + "    login" + chr(34) + "    hosting {" + chr(34) + "      id" + chr(34) + "      __typename" + chr(34) + "    }" + chr(34) + "    broadcastSettings {" + chr(34) + "      title" + chr(34) + "      id" + chr(34) + "      __typename" + chr(34) + "    }" + chr(34) + "    profileImageURL(width: 50)" + chr(34) + "    id" + chr(34) + "    __typename" + chr(34) + "  }" + chr(34) + "  game {" + chr(34) + "    displayName" + chr(34) + "    name" + chr(34) + "    id" + chr(34) + "    __typename" + chr(34) + "  }" + chr(34) + "  id" + chr(34) + "  __typename" + chr(34) + "  previewImageURL" + chr(34) + "  type" + chr(34) + "  viewersCount" + chr(34) + "}" + chr(34) + ""
        variables: {
            "channelsCount": 40
            "gameAlias": m.top.request.params.id
        }
    })
    writeResponse(rsp)
end function

function getStreamPlayerQuery()
    rsp = TwitchGraphQLRequest({
        query: "query StreamPlayer_Query(" + chr(10) + "  $login: String!" + chr(10) + "  $playerType: String!" + chr(10) + "  $platform: String!" + chr(10) + "  $skipPlayToken: Boolean!" + chr(10) + ") {" + chr(10) + "  ...StreamPlayer_token" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_token on Query {" + chr(10) + "  user(login: $login) {" + chr(10) + "    login" + chr(10) + "    stream @skip(if: $skipPlayToken) {" + chr(10) + "      playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "        signature" + chr(10) + "        value" + chr(10) + "      }" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
        variables: {
            "login": m.top.request.params.id
            "platform": "switch_web_tv"
            "playerType": "pulsar"
            "skipPlayToken": false
        }
    })
    writeResponse(rsp)
end function

function getVodPlayerWrapperQuery() as object
    rsp = TwitchGraphQLRequest({
        query: "query VodPlayerWrapper_Query(" + chr(10) + "  $videoId: ID!" + chr(10) + "  $platform: String!" + chr(10) + "  $playerType: String!" + chr(10) + "  $skipPlayToken: Boolean!" + chr(10) + ") {" + chr(10) + "  ...VodPlayerWrapper_token" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment VodPlayerWrapper_token on Query {" + chr(10) + "  video(id: $videoId) @skip(if: $skipPlayToken) {" + chr(10) + "    playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "      signature" + chr(10) + "      value" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
        variables: {
            "videoId": m.top.request.params.id
            "platform": "switch_web_tv"
            "playerType": "pulsar"
            "skipPlayToken": false
        }
    })
    writeResponse(rsp)
end function


function getChannelInterstitialQuery() as object
    rsp = TwitchGraphQLRequest({
        query: "query ChannelInterstitial_Query(" + chr(10) + "  $login: String!" + chr(10) + "  $platform: String!" + chr(10) + "  $playerType: String!" + chr(10) + "  $skipPlayToken: Boolean!" + chr(10) + ") {" + chr(10) + "  channel: user(login: $login) {" + chr(10) + "    ...InterstitialLayout_channel" + chr(10) + "    ...StreamDetails_channel" + chr(10) + "    ...StreamPlayer_channel" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    displayName" + chr(10) + "    broadcastSettings {" + chr(10) + "      isMature" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    stream {" + chr(10) + "      restrictionType" + chr(10) + "      self {" + chr(10) + "        canWatch" + chr(10) + "      }" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      type" + chr(10) + "    }" + chr(10) + "    hosting {" + chr(10) + "      displayName" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      login" + chr(10) + "      stream {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        type" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  currentUser {" + chr(10) + "    ...StreamPlayer_currentUser" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  ...StreamPlayer_token" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment BroadcasterOverview_channel on User {" + chr(10) + "  login" + chr(10) + "  displayName" + chr(10) + "  followers {" + chr(10) + "    totalCount" + chr(10) + "  }" + chr(10) + "  primaryColorHex" + chr(10) + "  primaryTeam {" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  profileImageURL(width: 70)" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment ChannelDescription_channel on User {" + chr(10) + "  description" + chr(10) + "  displayName" + chr(10) + "  login" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableFollowButton_channel on User {" + chr(10) + "  login" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  self {" + chr(10) + "    follower {" + chr(10) + "      followedAt" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment InterstitialButtonRow_channel on User {" + chr(10) + "  ...FocusableFollowButton_channel" + chr(10) + "  login" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment InterstitialLayout_channel on User {" + chr(10) + "  ...BroadcasterOverview_channel" + chr(10) + "  ...ChannelDescription_channel" + chr(10) + "  ...InterstitialButtonRow_channel" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamDetails_channel on User {" + chr(10) + "  broadcastSettings {" + chr(10) + "    game {" + chr(10) + "      boxArtURL" + chr(10) + "      displayName" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    title" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  stream {" + chr(10) + "    viewersCount" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_channel on User {" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  login" + chr(10) + "  roles {" + chr(10) + "    isPartner" + chr(10) + "  }" + chr(10) + "  self {" + chr(10) + "    subscriptionBenefit {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    game {" + chr(10) + "      name" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    previewImageURL" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_currentUser on User {" + chr(10) + "  hasTurbo" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_token on Query {" + chr(10) + "  user(login: $login) {" + chr(10) + "    login" + chr(10) + "    stream @skip(if: $skipPlayToken) {" + chr(10) + "      playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "        signature" + chr(10) + "        value" + chr(10) + "      }" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
        variables: {
            "login": m.top.request.params.id
            "platform": "switch_web_tv"
            "playerType": "pulsar"
            "skipPlayToken": true
        }
    })
    writeResponse(rsp)
end function

function getChannelHomeQuery() as object
    rsp = TwitchGraphQLRequest({
        query: "query ChannelHome_Query(" + chr(10) + "  $login: String!" + chr(10) + "  $platform: String!" + chr(10) + "  $playerType: String!" + chr(10) + "  $skipPlayToken: Boolean!" + chr(10) + ") {" + chr(10) + "  channel: user(login: $login) {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    stream {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    videoShelves {" + chr(10) + "      edges {" + chr(10) + "        node {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "          title" + chr(10) + "          items {" + chr(10) + "            __typename" + chr(10) + "            __isVideoShelfItem: __typename" + chr(10) + "            ... on Clip {" + chr(10) + "              ...FocusableClipCard_clip" + chr(10) + "            }" + chr(10) + "            ... on Video {" + chr(10) + "              ...FocusableVodCard_video" + chr(10) + "            }" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "    ...ProfileBanner_channel" + chr(10) + "  }" + chr(10) + "  currentUser {" + chr(10) + "    ...ProfileBanner_currentUser" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  ...StreamPlayer_token" + chr(10) + "  ...VodPreviewPlayerWrapper_previewToken" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment BannerButtonsRow_channel on User {" + chr(10) + "  ...FocusableFollowButton_channel" + chr(10) + "  displayName" + chr(10) + "  hosting {" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    stream {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      type" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  login" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    type" + chr(10) + "  }" + chr(10) + "  videos(first: 1, sort: TIME) {" + chr(10) + "    edges {" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment BannerChannelStatus_channel on User {" + chr(10) + "  displayName" + chr(10) + "  hosting {" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    stream {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      type" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  login" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    type" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment DefaultPreviewContent_channel on User {" + chr(10) + "  ...SwitchPreviewContent_channel" + chr(10) + "  ...StreamPreviewPlayer_channel" + chr(10) + "  hosting {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    stream {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      type" + chr(10) + "      viewersCount" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  login" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    type" + chr(10) + "    viewersCount" + chr(10) + "  }" + chr(10) + "  videos(first: 1, sort: TIME) {" + chr(10) + "    edges {" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        previewThumbnailURL" + chr(10) + "        ...VodPreviewPlayer_video" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment DefaultPreviewContent_currentUser on User {" + chr(10) + "  ...StreamPreviewPlayer_currentUser" + chr(10) + "  ...VodPreviewPlayer_currentUser" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableClipCard_clip on Clip {" + chr(10) + "  broadcaster {" + chr(10) + "    login" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  createdAt" + chr(10) + "  durationSeconds" + chr(10) + "  game {" + chr(10) + "    boxArtURL" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  slug" + chr(10) + "  thumbnailURL" + chr(10) + "  title" + chr(10) + "  viewCount" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableFollowButton_channel on User {" + chr(10) + "  login" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  self {" + chr(10) + "    follower {" + chr(10) + "      followedAt" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableVodCard_video on Video {" + chr(10) + "  createdAt" + chr(10) + "  lengthSeconds" + chr(10) + "  game {" + chr(10) + "    boxArtURL" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewThumbnailURL" + chr(10) + "  self {" + chr(10) + "    viewingHistory {" + chr(10) + "      position" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  title" + chr(10) + "  viewCount" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment ProfileBanner_channel on User {" + chr(10) + "  ...BannerButtonsRow_channel" + chr(10) + "  ...BannerChannelStatus_channel" + chr(10) + "  ...SwitchPreviewContent_channel" + chr(10) + "  ...DefaultPreviewContent_channel" + chr(10) + "  description" + chr(10) + "  displayName" + chr(10) + "  followers {" + chr(10) + "    totalCount" + chr(10) + "  }" + chr(10) + "  hosting {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    profileImageURL(width: 150)" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  login" + chr(10) + "  profileImageURL(width: 150)" + chr(10) + "  profileViewCount" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment ProfileBanner_currentUser on User {" + chr(10) + "  ...DefaultPreviewContent_currentUser" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_channel on User {" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  login" + chr(10) + "  roles {" + chr(10) + "    isPartner" + chr(10) + "  }" + chr(10) + "  self {" + chr(10) + "    subscriptionBenefit {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    game {" + chr(10) + "      name" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    previewImageURL" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_currentUser on User {" + chr(10) + "  hasTurbo" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_token on Query {" + chr(10) + "  user(login: $login) {" + chr(10) + "    login" + chr(10) + "    stream @skip(if: $skipPlayToken) {" + chr(10) + "      playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "        signature" + chr(10) + "        value" + chr(10) + "      }" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPreviewPlayer_channel on User {" + chr(10) + "  hosting {" + chr(10) + "    ...StreamPlayer_channel" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    stream {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      type" + chr(10) + "      viewersCount" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  ...StreamPlayer_channel" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  login" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    type" + chr(10) + "    viewersCount" + chr(10) + "    restrictionType" + chr(10) + "    self {" + chr(10) + "      canWatch" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  displayName" + chr(10) + "  broadcastSettings {" + chr(10) + "    isMature" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPreviewPlayer_currentUser on User {" + chr(10) + "  ...StreamPlayer_currentUser" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment SwitchPreviewContent_channel on User {" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  login" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    previewImageURL" + chr(10) + "  }" + chr(10) + "  videos(first: 1, sort: TIME) {" + chr(10) + "    edges {" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        previewThumbnailURL" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment VodPlayerBase_currentUser on User {" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  hasTurbo" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment VodPlayerBase_video on Video {" + chr(10) + "  broadcastType" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  game {" + chr(10) + "    name" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  owner {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isPartner" + chr(10) + "    }" + chr(10) + "    self {" + chr(10) + "      subscriptionBenefit {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  self {" + chr(10) + "    viewingHistory {" + chr(10) + "      position" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment VodPlayerOverlay_video on Video {" + chr(10) + "  createdAt" + chr(10) + "  lengthSeconds" + chr(10) + "  viewCount" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment VodPreviewPlayerWrapper_previewToken on Query {" + chr(10) + "  user(login: $login) @skip(if: $skipPlayToken) {" + chr(10) + "    videos(first: 1) {" + chr(10) + "      edges {" + chr(10) + "        node {" + chr(10) + "          playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "            signature" + chr(10) + "            value" + chr(10) + "          }" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment VodPreviewPlayer_currentUser on User {" + chr(10) + "  ...VodPlayerBase_currentUser" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment VodPreviewPlayer_video on Video {" + chr(10) + "  ...VodPlayerBase_video" + chr(10) + "  ...VodPlayerOverlay_video" + chr(10) + "  muteInfo {" + chr(10) + "    mutedSegmentConnection {" + chr(10) + "      nodes {" + chr(10) + "        duration" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  owner {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    broadcastSettings {" + chr(10) + "      isMature" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    subscriptionProducts {" + chr(10) + "      displayName" + chr(10) + "      hasSubonlyVideoArchive" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    displayName" + chr(10) + "  }" + chr(10) + "  resourceRestriction {" + chr(10) + "    type" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  self {" + chr(10) + "    isRestricted" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "",
        variables: {
            "login": m.top.request.params.id
            "platform": "switch_web_tv"
            "playerType": "quasar"
            "skipPlayToken": false
        }
    })
    writeResponse(rsp)
end function

function getFollowingPageQuery() as object
    rsp = TwitchGraphQLRequest({
        query: "query FollowingPage_Query(" + chr(10) + "  $first: Int!" + chr(10) + "  $liveUserCursor: Cursor" + chr(10) + "  $offlineUserCursor: Cursor" + chr(10) + "  $followedGameType: FollowedGamesType" + chr(10) + "  $categoryFirst: Int!" + chr(10) + "  $itemsPerRow: Int!" + chr(10) + "  $limit: Int!" + chr(10) + "  $platform: String!" + chr(10) + "  $requestID: String!" + chr(10) + ") {" + chr(10) + "  user {" + chr(10) + "    followedLiveUsers(first: $first, after: $liveUserCursor) {" + chr(10) + "      edges {" + chr(10) + "        node {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "    follows(first: $first, after: $offlineUserCursor) {" + chr(10) + "      edges {" + chr(10) + "        node {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "          stream {" + chr(10) + "            id" + chr(10) + "            __typename" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "    followedGames(first: $categoryFirst, type: $followedGameType) {" + chr(10) + "      nodes {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "    ...LiveStreamInfiniteShelf_followedLiveUsers" + chr(10) + "    ...OfflineInfiniteShelf_followedUsers" + chr(10) + "    ...CategoryShelf_followedCategories" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  ...FollowingPageEmpty_Query" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment CategoryBannerContent_category on Game {" + chr(10) + "  streams(first: 1) {" + chr(10) + "    edges {" + chr(10) + "      node {" + chr(10) + "        ...FollowingLiveStreamBannerContent_stream" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment CategoryShelf_followedCategories on User {" + chr(10) + "  followedGames(first: $categoryFirst, type: $followedGameType) {" + chr(10) + "    nodes {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      displayName" + chr(10) + "      developers" + chr(10) + "      boxArtURL" + chr(10) + "      ...FocusableCategoryCard_category" + chr(10) + "      ...CategoryBannerContent_category" + chr(10) + "      streams(first: 1) {" + chr(10) + "        edges {" + chr(10) + "          node {" + chr(10) + "            previewImageURL" + chr(10) + "            id" + chr(10) + "            __typename" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableCategoryCard_category on Game {" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  name" + chr(10) + "  displayName" + chr(10) + "  viewersCount" + chr(10) + "  boxArtURL" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableOfflineChannelCard_channel on User {" + chr(10) + "  displayName" + chr(10) + "  followers {" + chr(10) + "    totalCount" + chr(10) + "  }" + chr(10) + "  lastBroadcast {" + chr(10) + "    startedAt" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  login" + chr(10) + "  profileImageURL(width: 300)" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableStreamCard_stream on Stream {" + chr(10) + "  broadcaster {" + chr(10) + "    displayName" + chr(10) + "    login" + chr(10) + "    broadcastSettings {" + chr(10) + "      title" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    profileImageURL(width: 50)" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  game {" + chr(10) + "    displayName" + chr(10) + "    name" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewImageURL" + chr(10) + "  type" + chr(10) + "  viewersCount" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FollowingLiveStreamBannerContent_stream on Stream {" + chr(10) + "  game {" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  broadcaster {" + chr(10) + "    broadcastSettings {" + chr(10) + "      title" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FollowingPageEmpty_Query on Query {" + chr(10) + "  shelves(itemsPerRow: $itemsPerRow, first: $limit, platform: $platform, requestID: $requestID) {" + chr(10) + "    edges {" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        title {" + chr(10) + "          fallbackLocalizedTitle" + chr(10) + "          localizedTitleTokens {" + chr(10) + "            node {" + chr(10) + "              __typename" + chr(10) + "              ... on Game {" + chr(10) + "                __typename" + chr(10) + "                displayName" + chr(10) + "                name" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "              ... on TextToken {" + chr(10) + "                __typename" + chr(10) + "                text" + chr(10) + "                location" + chr(10) + "              }" + chr(10) + "              ... on BrowsableCollection {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "              ... on Tag {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "              ... on User {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "            }" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "        trackingInfo {" + chr(10) + "          rowName" + chr(10) + "        }" + chr(10) + "        content {" + chr(10) + "          edges {" + chr(10) + "            trackingID" + chr(10) + "            node {" + chr(10) + "              __typename" + chr(10) + "              __isShelfContent: __typename" + chr(10) + "              ... on Stream {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "                previewImageURL" + chr(10) + "                broadcaster {" + chr(10) + "                  displayName" + chr(10) + "                  broadcastSettings {" + chr(10) + "                    title" + chr(10) + "                    id" + chr(10) + "                    __typename" + chr(10) + "                  }" + chr(10) + "                  id" + chr(10) + "                  __typename" + chr(10) + "                }" + chr(10) + "                game {" + chr(10) + "                  displayName" + chr(10) + "                  boxArtURL" + chr(10) + "                  id" + chr(10) + "                  __typename" + chr(10) + "                }" + chr(10) + "                ...FocusableStreamCard_stream" + chr(10) + "              }" + chr(10) + "              ... on Game {" + chr(10) + "                ...FocusableCategoryCard_category" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "                streams(first: 1) {" + chr(10) + "                  edges {" + chr(10) + "                    node {" + chr(10) + "                      id" + chr(10) + "                      __typename" + chr(10) + "                      previewImageURL" + chr(10) + "                      broadcaster {" + chr(10) + "                        displayName" + chr(10) + "                        broadcastSettings {" + chr(10) + "                          title" + chr(10) + "                          id" + chr(10) + "                          __typename" + chr(10) + "                        }" + chr(10) + "                        id" + chr(10) + "                        __typename" + chr(10) + "                      }" + chr(10) + "                      game {" + chr(10) + "                        displayName" + chr(10) + "                        boxArtURL" + chr(10) + "                        id" + chr(10) + "                        __typename" + chr(10) + "                      }" + chr(10) + "                    }" + chr(10) + "                  }" + chr(10) + "                }" + chr(10) + "              }" + chr(10) + "              ... on Clip {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "              ... on Tag {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "              ... on Video {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "            }" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment LiveStreamInfiniteShelf_followedLiveUsers on User {" + chr(10) + "  followedLiveUsers(first: $first, after: $liveUserCursor) {" + chr(10) + "    edges {" + chr(10) + "      cursor" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        displayName" + chr(10) + "        stream {" + chr(10) + "          previewImageURL" + chr(10) + "          game {" + chr(10) + "            boxArtURL" + chr(10) + "            id" + chr(10) + "            __typename" + chr(10) + "          }" + chr(10) + "          ...FollowingLiveStreamBannerContent_stream" + chr(10) + "          ...FocusableStreamCard_stream" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment OfflineBannerContent_user on User {" + chr(10) + "  displayName" + chr(10) + "  lastBroadcast {" + chr(10) + "    startedAt" + chr(10) + "    game {" + chr(10) + "      displayName" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment OfflineInfiniteShelf_followedUsers on User {" + chr(10) + "  follows(first: $first, after: $offlineUserCursor) {" + chr(10) + "    edges {" + chr(10) + "      cursor" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        bannerImageURL" + chr(10) + "        displayName" + chr(10) + "        lastBroadcast {" + chr(10) + "          game {" + chr(10) + "            boxArtURL" + chr(10) + "            id" + chr(10) + "            __typename" + chr(10) + "          }" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "        stream {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "        ...OfflineBannerContent_user" + chr(10) + "        ...FocusableOfflineChannelCard_channel" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
        variables: {
            "first": 100
            ' "liveUserCursor": ""
            ' "offlineUserCursor": ""
            "followedGameType": "ALL"
            "categoryFirst": 100
            "itemsPerRow": 25
            "limit": 8
            "platform": "switch_web_tv"
            "requestID": getRandomUUID()
        }
    })
    writeResponse(rsp)
end function

function getRendezvouzToken()
    req = HttpRequest({
        url: "https://id.twitch.tv/oauth2/device?scopes=channel_read%20chat%3Aread%20user_blocks_edit%20user_blocks_read%20user_follows_edit%20user_read&client_id=ue6666qo983tsx6so1t0vnawi233wa"
        headers: {
            "content-type": "application/x-www-form-urlencoded"
            "origin": "https://switch.tv.twitch.tv"
            "referer": "https://switch.tv.twitch.tv/"
        }
        method: "POST"
    })
    rsp = ParseJSON(req.send())
    writeResponse(rsp)
end function


function getOauthToken()
    if m.top.request.params.device_code = invalid return invalid
    req = HttpRequest({
        url: "https://id.twitch.tv/oauth2/token" + "?client_id=ue6666qo983tsx6so1t0vnawi233wa&device_code=" + m.top.request.params.device_code + "&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code"
        headers: {
            "content-type": "application/x-www-form-urlencoded"
            "origin": "https://switch.tv.twitch.tv"
            "referer": "https://switch.tv.twitch.tv/"
            "accept": "application/json"
        }
        method: "POST"
    })
    while true
        rsp = ParseJSON(req.send())
        if rsp <> invalid and rsp.DoesExist("access_token")
            exit while
        end if
        sleep(5000)
    end while
    writeResponse(rsp)
end function

function getSearchQuery()
    if m.top.request.params.query = invalid return invalid
    rsp = TwitchGraphQLRequest({
        query: "query Search_Query(" + chr(10) + "  $userQuery: String!" + chr(10) + "  $platform: String!" + chr(10) + "  $noQuery: Boolean!" + chr(10) + ") {" + chr(10) + "  currentUser {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  searchFor(userQuery: $userQuery, platform: $platform) @skip(if: $noQuery) {" + chr(10) + "    ...SearchResults_results" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableCategoryCard_category on Game {" + chr(10) + "  name" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  displayName" + chr(10) + "  viewersCount" + chr(10) + "  boxArtURL" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableOfflineChannelCard_channel on User {" + chr(10) + "  displayName" + chr(10) + "  followers {" + chr(10) + "    totalCount" + chr(10) + "  }" + chr(10) + "  lastBroadcast {" + chr(10) + "    startedAt" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  login" + chr(10) + "  profileImageURL(width: 300)" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableStreamCard_stream on Stream {" + chr(10) + "  broadcaster {" + chr(10) + "    displayName" + chr(10) + "    login" + chr(10) + "    hosting {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    broadcastSettings {" + chr(10) + "      title" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    profileImageURL(width: 50)" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  game {" + chr(10) + "    displayName" + chr(10) + "    name" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewImageURL" + chr(10) + "  type" + chr(10) + "  viewersCount" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableVodCard_video on Video {" + chr(10) + "  createdAt" + chr(10) + "  lengthSeconds" + chr(10) + "  game {" + chr(10) + "    boxArtURL" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewThumbnailURL" + chr(10) + "  self {" + chr(10) + "    viewingHistory {" + chr(10) + "      position" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  title" + chr(10) + "  viewCount" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment SearchResults_results on SearchFor {" + chr(10) + "  channels {" + chr(10) + "    items {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      bannerImageURL" + chr(10) + "      ...FocusableOfflineChannelCard_channel" + chr(10) + "      stream {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        previewImageURL" + chr(10) + "        ...FocusableStreamCard_stream" + chr(10) + "        game {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  relatedLiveChannels {" + chr(10) + "    items {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      bannerImageURL" + chr(10) + "      ...FocusableOfflineChannelCard_channel" + chr(10) + "      stream {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        previewImageURL" + chr(10) + "        ...FocusableStreamCard_stream" + chr(10) + "        game {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  games {" + chr(10) + "    items {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      ...FocusableCategoryCard_category" + chr(10) + "      streams(first: 1) {" + chr(10) + "        edges {" + chr(10) + "          node {" + chr(10) + "            previewImageURL" + chr(10) + "            id" + chr(10) + "            __typename" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  videos {" + chr(10) + "    items {" + chr(10) + "      ...FocusableVodCard_video" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      game {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "      }" + chr(10) + "      previewThumbnailURL" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
        variables: {
            userQuery: m.top.request.params.query
            platform: "switch_web_tv"
            noQuery: false
        }
    })
    writeResponse(rsp)
end function

function getGameDirectoryQuery()
    ? "param: " m.top.request.params
    if m.top.request.params.gamealias = invalid return invalid
    rsp = TwitchGraphQLRequest({
        query: "query GameDirectory_Query(" + chr(10) + "  $gameAlias: String!" + chr(10) + "  $channelsCount: Int!" + chr(10) + ") {" + chr(10) + "  currentUser {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  game(name: $gameAlias) {" + chr(10) + "    boxArtURL" + chr(10) + "    displayName" + chr(10) + "    name" + chr(10) + "    streams(first: $channelsCount) {" + chr(10) + "      edges {" + chr(10) + "        node {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "          previewImageURL" + chr(10) + "          ...FocusableStreamCard_stream" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableStreamCard_stream on Stream {" + chr(10) + "  broadcaster {" + chr(10) + "    displayName" + chr(10) + "    login" + chr(10) + "    hosting {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    broadcastSettings {" + chr(10) + "      title" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    profileImageURL(width: 50)" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  game {" + chr(10) + "    displayName" + chr(10) + "    name" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewImageURL" + chr(10) + "  type" + chr(10) + "  viewersCount" + chr(10) + "}",
        variables: {
            "gameAlias": m.top.request.params.gamealias,
            "channelsCount": 40
        }
    })
    writeResponse(rsp)
end function

function getCategoriesQuery()
    rsp = TwitchGraphQLRequest({
        query: "query GamesDirectory_Query(" + chr(10) + "  $first: Int!" + chr(10) + ") {" + chr(10) + "  currentUser {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  games(first: $first) {" + chr(10) + "    edges {" + chr(10) + "      node {" + chr(10) + "        ...FocusableCategoryCard_category" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableCategoryCard_category on Game {" + chr(10) + "  name" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  displayName" + chr(10) + "  viewersCount" + chr(10) + "  boxArtURL" + chr(10) + "}",
        variables: {
            "first": 80
        }
    })
    writeResponse(rsp)
end function

function getChannelShell()
    if m.top.request.params.id = invalid return invalid
    rsp = TwitchGraphQLRequest({
        operationName: "ChannelShell"
        variables: {
            login: m.top.request.params.id
        }
        extensions: {
            persistedQuery: {
                version: 1,
                sha256Hash: "580ab410bcd0c1ad194224957ae2241e5d252b2c5173d8e0cce9d32d5bb14efe"
            }
        }
    })
    writeResponse(rsp)
end function

function TwitchHelixApiRequest()
    access_token = ""
    device_code = ""
    ' doubled up here in stead of defaulting to "" because access_token is dependent on device_code
    if get_user_setting("device_code") <> invalid
        device_code = get_user_setting("device_code")
        if get_user_setting("access_token") <> invalid
            access_token = "Bearer " + get_user_setting("access_token")
        end if
    end if
    requestParams = {
        url: "https://api.twitch.tv/helix/" + m.top.request.params.endpoint + "?" + m.top.request.params.args
        headers: {
            "Accept": "*/*"
            "Authorization": access_token
            "Client-Id": "ue6666qo983tsx6so1t0vnawi233wa"
            "Device-ID": device_code
            "Origin": "https://switch.tv.twitch.tv"
            "Referer": "https://switch.tv.twitch.tv/"
        }
        method: m.top.request.params.method
    }
    if m.top.request.params.data <> invalid
        requestParams["data"] = m.top.request.params.data
    end if
    req = HttpRequest(requestParams)
    rsp = ParseJSON(req.send())
    writeResponse(rsp)
end function


function followChannel() as object
    rsp = TwitchGraphQLRequest({
        operationName: "FollowButton_FollowUser",
        variables: {
            input: {
                disableNotifications: false,
                targetID: m.top.request.params.id
            }
        },
        extensions: {
            persistedQuery: {
                version: 1,
                sha256Hash: "800e7346bdf7e5278a3c1d3f21b2b56e2639928f86815677a7126b093b2fdd08"
            }
        }
    })
    writeResponse(rsp)
end function

function getRecommendedSections() as object
    rsp = TwitchGraphQLRequest({
        operationName: "Shelves",
        variables: {
            "imageWidth": 50,
            "itemsPerRow": 3,
            "platform": "web",
            "limit": 8,
            "requestID": getRandomUUID(),
            "context": {
                "clientApp": "twilight",
                "location": "home",
                "referrerDomain": "twitch.tv",
                "viewportHeight": 1080,
                "viewportWidth": 1920
            },
            "verbose": false
        },
        extensions: {
            persistedQuery: {
                version: 1,
                sha256Hash: "b6f0c72c747457b73107f6aa00bd6a5bb294539d2de5398646e949c863662543"
            }
        }
    })
    writeResponse(rsp)
end function

function unfollowChannel() as object
    rsp = TwitchGraphQLRequest({
        operationName: "FollowButton_UnfollowUser",
        variables: {
            input: {
                targetID: m.top.request.params.id
            }
        },
        extensions: {
            persistedQuery: {
                version: 1,
                sha256Hash: "f7dae976ebf41c755ae2d758546bfd176b4eeb856656098bb40e0a672ca0d880"
            }
        }
    })
    writeResponse(rsp)
end function

function extractUrls(input, contentType)
    if contentType = "VOD"
        ' .replace(chr(22), "%22").replace("{", "%7B").replace("}", "%7D").replace(":", "%3A").replace(",", "%2C").replace("[", "%5B").replace("]", "%5D")
        usherUrl = "https://usher.ttvnw.net/vod/" + input.data.video.id + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&nauth=" + input.data.video.playbackAccessToken.value.EncodeUri() + "&nauthsig=" + input.data.video.playbackAccessToken.signature
    else if contentType = "LIVE"

        usherUrl = "https://usher.ttvnw.net/api/channel/hls/" + input.data.user.login + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&lr=true&token=" + input.data.user.stream.playbackaccesstoken.value.EncodeUri() + "&sig=" + input.data.user.stream.playbackaccesstoken.signature
    end if
    ? "userUrl: "; usherUrl
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
            value = stream_item["RESOLUTION"].split("x")[1] + "p" + stream_item["FRAME-RATE"].split(".")[0]
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
    return {
        streamUrls: stream_urls
        streamQualities: stream_qualities
        streamContentIDs: stream_content_ids
        streamBitrates: stream_bitrates
        streamStickyHttpRedirects: stream_sticky
    }
end function

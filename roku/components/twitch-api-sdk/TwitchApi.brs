sub init()
    m.deviceInfo = createObject("roDeviceInfo")
    m.port = createObject("roMessagePort")
    ' setting callbacks for url request and response
    m.top.observeField("request", m.port)
    ' setting the task thread function
    m.top.functionName = "main"
    m.top.control = "RUN"
end sub

function writeResponse(data)
    if data <> invalid
        m.top.response = data
    else
        m.top.response = { "response": invalid }
    end if
end function

function GetRandomUUID()
    di = CreateObject("roDeviceInfo")
    return di.GetRandomUUID()
end function


function TwitchGraphQLRequest(data)
    access_token = ""
    device_code = ""
    ' doubled up here in stead of defaulting to "" because access_token is dependent on device_code
    if get_user_setting("device_code") <> invalid
        device_code = get_user_setting("device_code")
        if get_user_setting("access_token") <> invalid
            access_token = "OAuth " + get_user_setting("access_token")
        end if
    end if
    req = HttpRequest({
        url: "https://gql.twitch.tv/gql"
        headers: {
            "Accept": "*/*"
            "Authorization": access_token
            "Client-Id": "ue6666qo983tsx6so1t0vnawi233wa"
            "Device-ID": device_code
            "Origin": "https://switch.tv.twitch.tv"
            "Referer": "https://switch.tv.twitch.tv/"
        }
        method: "POST"
        data: data
    })
    rsp = ParseJSON(req.send())
    writeResponse(rsp)
end function

function getHomePageQuery() as object
    TwitchGraphQLRequest({
        query: "query Homepage_Query(" + chr(10) + "  $itemsPerRow: Int!" + chr(10) + "  $limit: Int!" + chr(10) + "  $platform: String!" + chr(10) + "  $requestID: String!" + chr(10) + ") {" + chr(10) + "  currentUser {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  shelves(itemsPerRow: $itemsPerRow, first: $limit, platform: $platform, requestID: $requestID) {" + chr(10) + "    edges {" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        title {" + chr(10) + "          fallbackLocalizedTitle" + chr(10) + "          localizedTitleTokens {" + chr(10) + "            node {" + chr(10) + "              __typename" + chr(10) + "              ... on Game {" + chr(10) + "                __typename" + chr(10) + "                displayName" + chr(10) + "                name" + chr(10) + "              }" + chr(10) + "              ... on TextToken {" + chr(10) + "                __typename" + chr(10) + "                text" + chr(10) + "                location" + chr(10) + "              }" + chr(10) + "            }" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "        trackingInfo {" + chr(10) + "          reasonTarget" + chr(10) + "          reasonTargetType" + chr(10) + "          reasonType" + chr(10) + "          rowName" + chr(10) + "        }" + chr(10) + "        content {" + chr(10) + "          edges {" + chr(10) + "            trackingID" + chr(10) + "            node {" + chr(10) + "              __typename" + chr(10) + "              __isShelfContent: __typename" + chr(10) + "              ... on Stream {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "                previewImageURL" + chr(10) + "                broadcaster {" + chr(10) + "                  displayName" + chr(10) + "                  broadcastSettings {" + chr(10) + "                    title" + chr(10) + "                    id" + chr(10) + "                    __typename" + chr(10) + "                  }" + chr(10) + "                  id" + chr(10) + "                  __typename" + chr(10) + "                }" + chr(10) + "                game {" + chr(10) + "                  displayName" + chr(10) + "                  boxArtURL" + chr(10) + "                  id" + chr(10) + "                  __typename" + chr(10) + "                }" + chr(10) + "                ...FocusableStreamCard_stream" + chr(10) + "              }" + chr(10) + "              ... on Game {" + chr(10) + "                ...FocusableCategoryCard_category" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "                streams(first: 1) {" + chr(10) + "                  edges {" + chr(10) + "                    node {" + chr(10) + "                      id" + chr(10) + "                      __typename" + chr(10) + "                      previewImageURL" + chr(10) + "                      broadcaster {" + chr(10) + "                        displayName" + chr(10) + "                        broadcastSettings {" + chr(10) + "                          title" + chr(10) + "                          id" + chr(10) + "                          __typename" + chr(10) + "                        }" + chr(10) + "                        id" + chr(10) + "                        __typename" + chr(10) + "                      }" + chr(10) + "                      game {" + chr(10) + "                        displayName" + chr(10) + "                        boxArtURL" + chr(10) + "                        id" + chr(10) + "                        __typename" + chr(10) + "                      }" + chr(10) + "                    }" + chr(10) + "                  }" + chr(10) + "                }" + chr(10) + "              }" + chr(10) + "            }" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableCategoryCard_category on Game {" + chr(10) + "  name" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  displayName" + chr(10) + "  viewersCount" + chr(10) + "  boxArtURL" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableStreamCard_stream on Stream {" + chr(10) + "  broadcaster {" + chr(10) + "    displayName" + chr(10) + "    login" + chr(10) + "    hosting {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    broadcastSettings {" + chr(10) + "      title" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    profileImageURL(width: 50)" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  game {" + chr(10) + "    displayName" + chr(10) + "    name" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewImageURL" + chr(10) + "  type" + chr(10) + "  viewersCount" + chr(10) + "}" + chr(10) + ""
        variables: {
            "itemsPerRow": 50,
            "limit": 50,
            "platform": "switch_web_tv",
            "requestID": getRandomUUID()
        }
    })
end function

function getCategoryQuery() as object
    TwitchGraphQLRequest({
        query: "query GameDirectory_Query(" + chr(34) + "  $gameAlias: String!" + chr(34) + "  $channelsCount: Int!" + chr(34) + ") {" + chr(34) + "  currentUser {" + chr(34) + "    id" + chr(34) + "    __typename" + chr(34) + "    login" + chr(34) + "    roles {" + chr(34) + "      isStaff" + chr(34) + "    }" + chr(34) + "  }" + chr(34) + "  game(name: $gameAlias) {" + chr(34) + "    boxArtURL" + chr(34) + "    displayName" + chr(34) + "    name" + chr(34) + "    streams(first: $channelsCount) {" + chr(34) + "      edges {" + chr(34) + "        node {" + chr(34) + "          id" + chr(34) + "          __typename" + chr(34) + "          previewImageURL" + chr(34) + "          ...FocusableStreamCard_stream" + chr(34) + "        }" + chr(34) + "      }" + chr(34) + "    }" + chr(34) + "    id" + chr(34) + "    __typename" + chr(34) + "  }" + chr(34) + "}" + chr(34) + "" + chr(34) + "fragment FocusableStreamCard_stream on Stream {" + chr(34) + "  broadcaster {" + chr(34) + "    displayName" + chr(34) + "    login" + chr(34) + "    hosting {" + chr(34) + "      id" + chr(34) + "      __typename" + chr(34) + "    }" + chr(34) + "    broadcastSettings {" + chr(34) + "      title" + chr(34) + "      id" + chr(34) + "      __typename" + chr(34) + "    }" + chr(34) + "    profileImageURL(width: 50)" + chr(34) + "    id" + chr(34) + "    __typename" + chr(34) + "  }" + chr(34) + "  game {" + chr(34) + "    displayName" + chr(34) + "    name" + chr(34) + "    id" + chr(34) + "    __typename" + chr(34) + "  }" + chr(34) + "  id" + chr(34) + "  __typename" + chr(34) + "  previewImageURL" + chr(34) + "  type" + chr(34) + "  viewersCount" + chr(34) + "}" + chr(34) + ""
        variables: {
            "channelsCount": 40
            "gameAlias": m.top.request.params.id
        }
    })
end function

function getStreamPlayerQuery()
    TwitchGraphQLRequest({
        query: "query StreamPlayer_Query(" + chr(10) + "  $login: String!" + chr(10) + "  $playerType: String!" + chr(10) + "  $platform: String!" + chr(10) + "  $skipPlayToken: Boolean!" + chr(10) + ") {" + chr(10) + "  ...StreamPlayer_token" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_token on Query {" + chr(10) + "  user(login: $login) {" + chr(10) + "    login" + chr(10) + "    stream @skip(if: $skipPlayToken) {" + chr(10) + "      playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "        signature" + chr(10) + "        value" + chr(10) + "      }" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
        variables: {
            "login": m.top.request.params.id
            "platform": "switch_web_tv"
            "playerType": "pulsar"
            "skipPlayToken": false
        }
    })
end function

function getVodPlayerWrapperQuery() as object
    TwitchGraphQLRequest({
        query: "query VodPlayerWrapper_Query(" + chr(10) + "  $videoId: ID!" + chr(10) + "  $platform: String!" + chr(10) + "  $playerType: String!" + chr(10) + "  $skipPlayToken: Boolean!" + chr(10) + ") {" + chr(10) + "  ...VodPlayerWrapper_token" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment VodPlayerWrapper_token on Query {" + chr(10) + "  video(id: $videoId) @skip(if: $skipPlayToken) {" + chr(10) + "    playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "      signature" + chr(10) + "      value" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
        variables: {
            "videoId": m.top.request.params.id
            "platform": "switch_web_tv"
            "playerType": "pulsar"
            "skipPlayToken": false
        }
    })
end function


function getChannelInterstitialQuery() as object
    TwitchGraphQLRequest({
        query: "query ChannelInterstitial_Query(" + chr(10) + "  $login: String!" + chr(10) + "  $platform: String!" + chr(10) + "  $playerType: String!" + chr(10) + "  $skipPlayToken: Boolean!" + chr(10) + ") {" + chr(10) + "  channel: user(login: $login) {" + chr(10) + "    ...InterstitialLayout_channel" + chr(10) + "    ...StreamDetails_channel" + chr(10) + "    ...StreamPlayer_channel" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    displayName" + chr(10) + "    broadcastSettings {" + chr(10) + "      isMature" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    stream {" + chr(10) + "      restrictionType" + chr(10) + "      self {" + chr(10) + "        canWatch" + chr(10) + "      }" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      type" + chr(10) + "    }" + chr(10) + "    hosting {" + chr(10) + "      displayName" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      login" + chr(10) + "      stream {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        type" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  currentUser {" + chr(10) + "    ...StreamPlayer_currentUser" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  ...StreamPlayer_token" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment BroadcasterOverview_channel on User {" + chr(10) + "  login" + chr(10) + "  displayName" + chr(10) + "  followers {" + chr(10) + "    totalCount" + chr(10) + "  }" + chr(10) + "  primaryColorHex" + chr(10) + "  primaryTeam {" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  profileImageURL(width: 70)" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment ChannelDescription_channel on User {" + chr(10) + "  description" + chr(10) + "  displayName" + chr(10) + "  login" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableFollowButton_channel on User {" + chr(10) + "  login" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  self {" + chr(10) + "    follower {" + chr(10) + "      followedAt" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment InterstitialButtonRow_channel on User {" + chr(10) + "  ...FocusableFollowButton_channel" + chr(10) + "  login" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment InterstitialLayout_channel on User {" + chr(10) + "  ...BroadcasterOverview_channel" + chr(10) + "  ...ChannelDescription_channel" + chr(10) + "  ...InterstitialButtonRow_channel" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamDetails_channel on User {" + chr(10) + "  broadcastSettings {" + chr(10) + "    game {" + chr(10) + "      boxArtURL" + chr(10) + "      displayName" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    title" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  stream {" + chr(10) + "    viewersCount" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_channel on User {" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  login" + chr(10) + "  roles {" + chr(10) + "    isPartner" + chr(10) + "  }" + chr(10) + "  self {" + chr(10) + "    subscriptionBenefit {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    game {" + chr(10) + "      name" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    previewImageURL" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_currentUser on User {" + chr(10) + "  hasTurbo" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_token on Query {" + chr(10) + "  user(login: $login) {" + chr(10) + "    login" + chr(10) + "    stream @skip(if: $skipPlayToken) {" + chr(10) + "      playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "        signature" + chr(10) + "        value" + chr(10) + "      }" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
        variables: {
            "login": m.top.request.params.id
            "platform": "switch_web_tv"
            "playerType": "pulsar"
            "skipPlayToken": true
        }
    })
end function

function getFollowingPageQuery() as object
    TwitchGraphQLRequest({
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
    TwitchGraphQLRequest({
        query: "query Search_Query(" + chr(10) + "  $userQuery: String!" + chr(10) + "  $platform: String!" + chr(10) + "  $noQuery: Boolean!" + chr(10) + ") {" + chr(10) + "  currentUser {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  searchFor(userQuery: $userQuery, platform: $platform) @skip(if: $noQuery) {" + chr(10) + "    ...SearchResults_results" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableCategoryCard_category on Game {" + chr(10) + "  name" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  displayName" + chr(10) + "  viewersCount" + chr(10) + "  boxArtURL" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableOfflineChannelCard_channel on User {" + chr(10) + "  displayName" + chr(10) + "  followers {" + chr(10) + "    totalCount" + chr(10) + "  }" + chr(10) + "  lastBroadcast {" + chr(10) + "    startedAt" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  login" + chr(10) + "  profileImageURL(width: 300)" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableStreamCard_stream on Stream {" + chr(10) + "  broadcaster {" + chr(10) + "    displayName" + chr(10) + "    login" + chr(10) + "    hosting {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    broadcastSettings {" + chr(10) + "      title" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    profileImageURL(width: 50)" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  game {" + chr(10) + "    displayName" + chr(10) + "    name" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewImageURL" + chr(10) + "  type" + chr(10) + "  viewersCount" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableVodCard_video on Video {" + chr(10) + "  createdAt" + chr(10) + "  lengthSeconds" + chr(10) + "  game {" + chr(10) + "    boxArtURL" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewThumbnailURL" + chr(10) + "  self {" + chr(10) + "    viewingHistory {" + chr(10) + "      position" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  title" + chr(10) + "  viewCount" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment SearchResults_results on SearchFor {" + chr(10) + "  channels {" + chr(10) + "    items {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      bannerImageURL" + chr(10) + "      ...FocusableOfflineChannelCard_channel" + chr(10) + "      stream {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        previewImageURL" + chr(10) + "        ...FocusableStreamCard_stream" + chr(10) + "        game {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  relatedLiveChannels {" + chr(10) + "    items {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      bannerImageURL" + chr(10) + "      ...FocusableOfflineChannelCard_channel" + chr(10) + "      stream {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        previewImageURL" + chr(10) + "        ...FocusableStreamCard_stream" + chr(10) + "        game {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  games {" + chr(10) + "    items {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      ...FocusableCategoryCard_category" + chr(10) + "      streams(first: 1) {" + chr(10) + "        edges {" + chr(10) + "          node {" + chr(10) + "            previewImageURL" + chr(10) + "            id" + chr(10) + "            __typename" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  videos {" + chr(10) + "    items {" + chr(10) + "      ...FocusableVodCard_video" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      game {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "      }" + chr(10) + "      previewThumbnailURL" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
        variables: {
            userQuery: m.top.request.params.query
            platform: "switch_web_tv"
            noQuery: false
        }
    })

end function

function getGameDirectoryQuery()
    if m.top.request.params.gameAlias = invalid return invalid
    TwitchGraphQLRequest({
        query: "query GameDirectory_Query(" + chr(10) + "  $gameAlias: String!" + chr(10) + "  $channelsCount: Int!" + chr(10) + ") {" + chr(10) + "  currentUser {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  game(name: $gameAlias) {" + chr(10) + "    boxArtURL" + chr(10) + "    displayName" + chr(10) + "    name" + chr(10) + "    streams(first: $channelsCount) {" + chr(10) + "      edges {" + chr(10) + "        node {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "          previewImageURL" + chr(10) + "          ...FocusableStreamCard_stream" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableStreamCard_stream on Stream {" + chr(10) + "  broadcaster {" + chr(10) + "    displayName" + chr(10) + "    login" + chr(10) + "    hosting {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    broadcastSettings {" + chr(10) + "      title" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    profileImageURL(width: 50)" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  game {" + chr(10) + "    displayName" + chr(10) + "    name" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewImageURL" + chr(10) + "  type" + chr(10) + "  viewersCount" + chr(10) + "}" + chr(10) + ""
        variables: {
            gameAlias: m.top.request.params.gameAlias
            channelsCount: 40
        }
    })

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

sub main()
    ' Holds requests by id
    m.jobsById = {}
    response = invalid
    ' UriFetcher event loop
    while true
        msg = wait(0, m.port)
        mt = type(msg)
        print "Received event type '"; mt; "'"
        ' If a request was made
        if mt = "roSGNodeEvent"
            if msg.getField() = "request"
                context = msg.Getdata()
                rtype = context.type
                if rtype = "getHomePageQuery"
                    getHomePageQuery()
                end if
                if rtype = "getStreamPlayerQuery"
                    getStreamPlayerQuery()
                end if
                if rtype = "getVodPlayerWrapperQuery"
                    getVodPlayerWrapperQuery()
                end if
                if rtype = "getChannelInterstitialQuery"
                    getChannelInterstitialQuery()
                end if
                if rtype = "getFollowingPageQuery"
                    getFollowingPageQuery()
                end if
                if rtype = "getRendezvouzToken"
                    getRendezvouzToken()
                end if
                if rtype = "getOauthToken"
                    getOauthToken()
                end if
                if rtype = "getCategoryQuery"
                    getCategoryQuery()
                end if
                if rtype = "HelixApiRequest"
                    TwitchHelixApiRequest()
                end if
            end if
        end if
    end while
end sub
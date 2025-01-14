sub init()
    '*******************'
    '* Get Node List
    '*******************'
    m.logo = m.top.findNode("logo")
    m.headerRect = m.top.findNode("headerRect")
    m.menuOptions = m.top.findNode("MenuOptions")
    m.top.observeField("focusedChild", "onGetfocus")
    m.top.observeField("updateUserIcon", "handleUserLogin")
    m.top.observeField("buttonSelected", "onMenuSelected")
    m.top.observeField("buttonFocused", "onMenuFocused")
    m.top.menuTextColor = m.global.constants.colors.muted.ice
    m.top.menuFocusColor = m.global.constants.colors.twitch.purple10
end sub

sub onMenuSelected()
    ? "button selected: "; m.top.buttonSelected
end sub

sub onMenuFocused()
    ? "button focused: "; m.top.buttonFocused
end sub

sub onGetfocus()
    if m.top.focusedChild <> invalid and m.top.focusedChild.id = "MenuBar"
        m.menuOptions.setFocus(true)
    end if
end sub

function buildIcon(icon)
    map = {
        "search": m.global.constants.defaultIcons.search
        "settings": m.global.constants.defaultIcons.settings
        "loginpage": get_user_setting("profile_image_url", m.global.constants.defaultIcons.login)
    }
    newItem = createObject("roSGNode", "Button")
    newItem.id = icon
    newItem.textColor = m.top.menuTextColor
    newItem.focusedTextColor = m.top.menuTextColor
    newItem.iconUri = map[icon]
    newItem.focusedIconUri = map[icon]
    newItem.minWidth = 0
    newItem.height = m.top.menuOptionsHeight
    newItem.focusFootprintBitmapUri = "pkg:/images/FocusFootprint.9.png"
    newItem.focusBitmapUri = "pkg:/images/FocusFootprint.9.png"
    newItem.showFocusFootprint = false
    newItem.getchild(3).blendColor = m.top.menuTextColor
    newItem.getchild(3).width = m.top.menuFontSize * 2
    newItem.getchild(3).height = m.top.menuFontSize * 2
    newItem.getchild(4).blendColor = m.top.menuFocusColor
    newItem.getchild(4).width = m.top.menuFontSize * 2
    newItem.getchild(4).height = m.top.menuFontSize * 2
    return newItem
end function

sub updateMenuOptions()
    '*******************'
    '* Include Width of Logo in Menu Option Offset
    '*******************'
    if m.top.MenuOptionsText.count() > 0
        xoffset = m.menuOptions.translation[0] + m.logo.width + m.logo.translation[0]
        yoffset = m.menuOptions.translation[1]
        m.menuOptions.translation = "[" + xoffset.ToStr() + "," + yoffset.ToStr() + "]"
    end if
    icons = []
    if m.top.showSearchIcon
        icons.push(buildIcon("Search"))
    end if
    if m.top.showSettingsIcon
        icons.push(buildIcon("Settings"))
    end if
    if m.top.showLoginIcon
        icons.push(buildIcon("LoginPage"))
    end if
    m.addedTranslation = 0
    menuButtons = []
    for i = 0 to (m.top.menuOptionsText.count() - 1)
        if m.top.menuOptionsText[i] <> ""
            newItem = createObject("roSGNode", "Button")
            font = CreateObject("roSGNode", "Font")
            font.size = m.top.menuFontSize
            font.uri = m.top.menuFontUri
            newItem.minWidth = 245
            newItem.textFont = font
            newItem.focusedTextFont = font
            newItem.textColor = m.top.menuTextColor
            newItem.focusedTextColor = m.top.menuFocusColor
            newItem.iconUri = ""
            newItem.focusedIconUri = ""
            newItem.height = m.top.menuOptionsHeight
            newItem.focusFootprintBitmapUri = "pkg:/images/FocusFootprint.9.png"
            newItem.focusBitmapUri = "pkg:/images/FocusIndicator.9.png"
            newItem.showFocusFootprint = false
            newItem.id = m.top.menuOptionsText[i]
            newItem.text = tr(m.top.menuOptionsText[i])
            menuButtons.push(newItem)
        end if
    end for
    for each menuButton in menuButtons
        m.menuOptions.appendChild(menuButton)
    end for
    for each icon in icons
        m.menuOptions.appendchild(icon)
    end for
end sub

sub handleUserLoginResponse()
    ? "[MenuBar] - handleUserLoginResponse()"
    search = m.loginIconTask.response
    result = { raw: search }
    if search <> invalid and search.data <> invalid
        for each stream in search.data
            set_user_setting("id", stream.id)
            set_user_setting("display_name", stream.display_name)
            set_user_setting("profile_image_url", stream.profile_image_url)
        end for
        for i = 0 to (m.menuOptions.getChildCount() - 1)
            if m.menuOptions.getchild(i).id = "LoginPage"
                m.menuOptions.getChild(i).iconUri = get_user_setting("profile_image_url")
                m.menuOptions.getChild(i).focusedIconUri = get_user_setting("profile_image_url")
                m.top.updateUserIcon = false
            end if
        end for
    end if
end sub

sub handleUserLogin()
    if m.top.updateUserIcon
        if get_setting("active_user", "$default$") <> "$default$"
            ? "[MenuBar] - handleUserLogin()"
            m.loginIconTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
            m.loginIconTask.observeField("response", "handleUserLoginResponse")
            m.loginIconTask.request = {
                type: "TwitchHelixApiRequest"
                params: {
                    endpoint: "users"
                    args: "login=" + get_user_setting("login")
                    method: "GET"
                }
            }
            m.loginIconTask.functionName = m.loginIconTask.request.type
            m.loginIconTask.control = "run"
        else
            for i = 0 to (m.menuOptions.getChildCount() - 1)
                if m.menuOptions.getchild(i).id = "LoginPage"
                    m.menuOptions.getChild(i).iconUri = m.global.constants.defaultIcons.login
                    m.menuOptions.getChild(i).focusedIconUri = m.global.constants.defaultIcons.login
                    m.top.updateUserIcon = false
                end if
            end for
        end if
    end if
end sub
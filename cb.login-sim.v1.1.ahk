#SingleInstance Force
CoordMode, Pixel, Client
CoordMode, Mouse, Client

;; by [CB] Lib
;; i stole some code from the honorable TimmyC
;; made for 1920x1080 and 2560x1440, WindowedFullscreen

;; WARNING: ALWAYS CHECK THE SERVER NUMBER BEFORE DOWNLOADING YOUR CHARACTER
;; the bot just clicks on the top server. if the server you're simming for goes down,
;; then you're getting logged in to a different server.

msgbox 1440 or 1080 ark res. WindowedFullScreen. click anywhere on ark window. hit F1 to start. F3 to close script.

class ArkWindow
{
    Title := ""
    Hwnd := ""
    Dims := { "X": 0, "Y": 0, "Width": 0, "Height": 0}

    Init() {
        this.Title := ArkAscended
        WinActivate, ArkAscended
        WinGet, hWnd, ID, ArkAscended
        WinGetPos, x, y, w, h, ArkAscended

        this.Hwnd := hWnd
        this.Dims.X := x
        this.Dims.Y := y
        this.Dims.Width := w
        this.Dims.Height := h
    }

    CheckPixelColorGeneric(pixObj, ByRef uiControl, ByRef isMatch) {
        PixelGetColor, pixCol, pixObj.x, pixObj.y

        if (pixCol = pixObj.color) {
            GuiControl,,uiControl,1
            isMatch := 1
        } else {
            GuiControl,,uiControl,0
            isMatch := 0
        }
    }

    ClickArk(xPix, yPix) {
        ControlClick, x%xPix% y%yPix%, ArkAscended
    }
}

class SimBot
{
    ArkWindow := {}
    ScreenWidth := 0
    ScreenHeight := 0
    Is1080 := 0
    Is1440 := 0

    Init() {
        this.ArkWindow := new ArkWindow()
        this.ArkWindow.Init()

        this.ScreenWidth := A_ScreenWidth
        this.ScreenHeight := A_ScreenHeight

        this.Is1080 := this.ArkWindow.Dims.Width = 1920 && this.ArkWindow.Dims.Height = 1080 && this.ArkWindow.Dims.Height = this.ScreenHeight
        this.Is1440 := this.ArkWindow.Dims.Width = 2560 && this.ArkWindow.Dims.Height = 1440 && this.ArkWindow.Dims.Height = this.ScreenHeight

        this.InitCoords()
    }

    Start() {
        if (!this.Is1080 && !this.Is1440) {
            msgbox your game resolution must be either 1920x1080 or 2560x1440 and must match your screen resolution

            return
        }

        ; create debug window
        Gui, DebugMenu:New
        Gui, +AlwaysOnTop
        Gui, +ToolWindow

        static MainLoginDetected
        static ServerListDetected
        static GameSelection
        static ModScreen
        static ConnectionFailed
        static JoiningFailed
        static NetworkFailed
        static JoinActive

        Gui, DebugMenu:Add, CheckBox, vMainLoginDetected, main login
        Gui, DebugMenu:Add, CheckBox, vServerListDetected, serverlist
        Gui, DebugMenu:Add, CheckBox, vGameSelection, game selection
        Gui, DebugMenu:Add, CheckBox, vModScreen, mod screen
        Gui, DebugMenu:Add, CheckBox, vConnectionFailed, connection failed
        Gui, DebugMenu:Add, CheckBox, vJoiningFailed, joining failed
        Gui, DebugMenu:Add, CheckBox, vNetworkFailed, network failed
        Gui, DebugMenu:Add, Text, , ------------------
        Gui, DebugMenu:Add, CheckBox, vJoinActive, join btn active
        Gui, DebugMenu:Show, w150 h190, JoinSim : Debug

        ; game ui state
        isMainLoginDetected := 0
        isGameSelection := 0
        isJoinLastActive := 0
        isAtServerList := 0
        isAtModScreen := 0
        isAtConnectionFailed := 0
        isAtJoinFailed := 0
        isAtNetworkFailed := 0

        ; intent state
        isBackingOut := 0
        isWaitingJoinResult := 0

        while (true) {
            ; check for main login screen
            this.ArkWindow.CheckPixelColorGeneric(this.pix_homeScreen, MainLoginDetected, isMainLoginDetected)

            ; check for game selection screen
            this.ArkWindow.CheckPixelColorGeneric(this.pix_gameSelect, GameSelection, isGameSelection)

            ; check for server list
            this.ArkWindow.CheckPixelColorGeneric(this.pix_serverList, ServerListDetected, isServerListDetected)

            ; check for join button active
            this.ArkWindow.CheckPixelColorGeneric(this.pix_joinActive, JoinActive, isJoinActive)

            ; check for mod screen
            this.ArkWindow.CheckPixelColorGeneric(this.pix_modScreen, ModScreen, isAtModScreen)

            ; check for connection failed
            this.ArkWindow.CheckPixelColorGeneric(this.pix_conFailed, ConnectionFailed, isAtConnectionFailed)

            ; check for join failed
            this.ArkWindow.CheckPixelColorGeneric(this.pix_joinFailed, JoinFailed, isAtJoinFailed)

            ; check for network failure
            this.ArkWindow.CheckPixelColorGeneric(this.pix_netFailed, NetworkFailed, isAtNetworkFailed)
            
            if (isMainLoginDetected) {
                this.ArkWindow.ClickArk(this.presstostartX, this.presstostartY) ; Press _ to start
            }

            if (isGameSelection) {
                this.ArkWindow.ClickArk(this.joingameX, this.joingameY) ; Join game
            }

            if (isServerListDetected && !isJoinActive) {
                if (!isBackingOut) {
                    this.ArkWindow.ClickArk(this.serverListTopServerX, this.serverListTopServerY) ; select the server
                } else {
                    this.ArkWindow.ClickArk(this.serverlistbackbuttonX, this.serverlistbackbuttonY) ; back

                    isBackingOut := 0
                }
            }

            if (isServerListDetected && isJoinActive) {
                this.ArkWindow.ClickArk(this.joinbuttonjX, this.joinbuttonjY) ; Join
            }

            if (isAtModScreen) {
                this.ArkWindow.ClickArk(this.modjoinbuttonjX, this.modjoinbuttonjY) ; Join

                isWaitingJoinResult := 1
            }

            if (isAtConnectionFailed) {
                this.ArkWindow.ClickArk(this.conFailedX, this.conFailedY) ; Cancel

                isBackingOut := 1
                isWaitingJoinResult := 0
            }

            if (isAtJoinFailed) {
                this.ArkWindow.ClickArk(this.joinFailedX, this.joinFailedY) ; OK

                isBackingOut := 1
                isWaitingJoinResult := 0
            }

            if (isAtNetworkFailed) {
                this.ArkWindow.ClickArk(this.netFailedX, this.netFailedY) ; OK

                isBackingOut := 1
                isWaitingJoinResult := 0
            }

            Sleep 1
        }
    }

    InitCoords() {
        if (this.Is1080) {
            this.presstostartX := 935
            this.presstostartY := 855
            ; this.joingameX := 500
            ; this.joingameY := 556
            this.joingameX := 520
            this.joingameY := 576
            this.serversearchboxX := 1615
            this.serversearchboxY := 195
            this.ServerUpBattleEyeLogoX := 110
            this.ServerUpBattleEyeLogoY := 330
            this.MultiplayerServers1X := 303
            this.MultiplayerServers1Y := 100
            this.joinbuttonjX := 1690
            this.joinbuttonjY := 945
            this.modjoinbuttonjX := 328
            this.modjoinbuttonjY := 935
            this.serverlistbackbuttonX := 172
            this.serverlistbackbuttonY := 875
            this.serverlistrefreshX := 965
            this.serverlistrefreshY := 940

            this.conFailedX := 978
            this.conFailedY := 730
            this.netFailedX := 869
            this.netFailedY := 369
            this.joinFailedX := 915
            this.joinFailedY := 391

            this.serverListTopServerX := 968
            this.serverListTopServerY := 331

            this.pix_homeScreen := { color: "0xFFFFFF", x: 1117, y: 858 }
            this.pix_gameSelect := { color: "0xFFEA86", x: 942, y: 960 }
            this.pix_serverList := { color: "0xFFFFFF", x: 774, y: 194 }
            this.pix_modScreen := { color: "0xCC800E", x: 1658, y: 539 }
            this.pix_joinActive := { color: "0xFFFFFF", x: 1734, y: 945 }
            this.pix_conFailed := { color: "0xFFF5C1", x: 852, y: 361 }
            this.pix_netFailed := { color: "0xFFF5C1", x: 852, y: 361 }
            this.pix_joinFailed := { color: "0x0000FF", x: 1160, y: 518 }
        } else if (this.Is1440) {
            this.presstostartX := 1269
            this.presstostartY := 1148
            this.joingameX := 697
            this.joingameY := 713
            this.serversearchboxX := 2135
            this.serversearchboxY := 265
            this.ServerUpBattleEyeLogoX := 144
            this.ServerUpBattleEyeLogoY := 437
            this.MultiplayerServers1X := 424
            this.MultiplayerServers1Y := 139
            this.joinbuttonjX := 2255
            this.joinbuttonjY := 1268
            this.modjoinbuttonjX := 436
            this.modjoinbuttonjY := 1245
            this.serverlistbackbuttonX := 218
            this.serverlistbackbuttonY := 1180
            this.serverlistrefreshX := 1290
            this.serverlistrefreshY := 1250
            this.conFailedX := 1427
            this.conFailedY := 979
            this.netFailedX := 1124
            this.netFailedY := 487
            this.joinFailedX := 1213
            this.joinFailedY := 512
            this.serverListTopServerX := 1352
            this.serverListTopServerY := 437

            this.pix_homeScreen := { color: "0xFFFFFF", x: 1124, y: 1145 }
            this.pix_gameSelect := { color: "0xFFEA86", x: 1270, y: 1290 }
            this.pix_serverList := { color: "0xFFFFFF", x: 941, y: 258 }
            this.pix_modScreen := { color: "0xCC800E", x: 2211, y: 601 }
            this.pix_conFailed := { color: "0xFFF5C1", x: 1458, y: 483 }
            this.pix_netFailed := { color: "0xFFF5C1", x: 1458, y: 483 }
            ; this.pix_joinFailed := { color: "0x0000FF", x: 1160, y: 518 }
            this.pix_joinFailed := { color: "0x0000FF", x: 1054, y: 391 }
            this.pix_joinActive := { color: "0xFFFFFF", x: 2290, y: 1261 }
        }
    }
}

F2::
    WinActivate, ArkAscended
    WinGetTitle, winTitle, A
    MouseGetPos, msX, msY, mWin
    PixelGetColor, pixCol, msX, msY

    msgbox color is %pixCol%, x: %msX%, y: %msY%, window: [%winTitle%]
return

F1::
    bot := new SimBot()
    SimBot.Init()
    SimBot.Start()
return

F3::
    ExitApp

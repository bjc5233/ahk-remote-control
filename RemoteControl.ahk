;说明
;  远程控制PC，通过发送http请求使PC执行指定命令
;external
;  date       2019-08-05 19:23:08
;  face       (>﹏<)
;  weather    Shanghai Cloudy 30℃
;========================= 环境配置 =========================
#NoEnv
#Persistent
#ErrorStdOut
#SingleInstance, Force
#include <AHKhttp>
#include <PRINT>
#include <URL>
#Include <TIP>
;========================= 环境配置 =========================



;========================= 初始化 =========================
paths := {}
paths["/"] := Func("Fun_Index")
paths["404"] := Func("Fun_404")
paths["/logo"] := Func("Fun_logo")
paths["/chrome"] := Func("Func_chrome")
paths["/chrome"] := Func("Func_chrome")
paths["/setclip"] := Func("Func_setClip")
paths["/getclip"] := Func("Func_getClip")
paths["/music"] := Func("Func_music")
paths["/direction"] := Func("Func_direction")
paths["/contextCmd"] := Func("Func_contextCmd")
paths["/webpConvert"] := Func("Func_webpConvert")


server := new HttpServer()
server.LoadMimes(A_ScriptDir . "/resources/mime.types")
server.SetPaths(paths)
server.Serve(9999)
url := new URL()
return
;========================= 初始化 =========================






;========================= 业务逻辑 =========================
Func_webpConvert(ByRef req, ByRef res) {
    ;OneNote不支持webp图片的复制, 这里联合chrome插件右键搜执行
    ;   [webp图片转换]-[http://192.168.1.20:9999/webpConvert?image=%s]
    image := req.queries.image
    image := RegExReplace(image, "webp", "jpg")
    res.headers["Content-Type"] := "image/jpeg"
    res.headers["location"] := image
    res.status := 302
}

Func_contextCmd(ByRef req, ByRef res) {
    cmd := req.body
    if (Strlen(cmd)) {
        SendLevel 1     ;配置使SendInput可以触发热键
        SendInput, {MButton}
        WinWaitActive, contextCmd.ahk ahk_class AutoHotkeyGUI, , 2
        if (ErrorLevel = 0) {
            SendInput, %cmd%
            Sleep 100
            SendInput, {Enter}
        }
    }
    res.status := 200
}

Func_direction(ByRef req, ByRef res) {
    bodyMap := ParseBody(req.body)
    direction := bodyMap["direction"]
    if (direction == "up") {
        SendInput, {Up}
    } else if (direction == "down") {
        SendInput, {Down}
    } else if (direction == "left") {
        SendInput, {Left}
    } else if (direction == "right") {
        SendInput, {Right}
    } else if (direction == "pageUp") {
        SendInput, {PgUp}
    } else if (direction == "pageDown") {
        SendInput, {PgDn}
    }
    res.status := 200
}

Func_music(ByRef req, ByRef res) {
    bodyMap := ParseBody(req.body)
    musicAction := bodyMap["action"]
    if (musicAction == "toggle") {
        SendInput, ^!{p}
    } else if (musicAction == "next") {
        SendInput, ^!{Right}
    } else if (musicAction == "prev") {
        SendInput, ^!{Left}
    }
    res.status := 200
}

Func_chrome(ByRef req, ByRef res) {
    bodyMap := ParseBody(req.body)
    mobileUrl := bodyMap["url"]
    if (mobileUrl) {
        mobileUrl := url.Decode(mobileUrl)
        FoundPos := RegExMatch(mobileUrl, "(http|ftp|https|file)://[\w]{1,}([\.\w]{1,})+[\w-_/?&=#%:]*", mobileUrl2) ;校验\分离出url
        if (FoundPos != 0) {
            run, chrome.exe %mobileUrl2%
        } else {
            run, chrome.exe www.baidu.com/s?wd=%mobileUrl%
        }
    }
    res.status := 200
}

Func_setClip(ByRef req, ByRef res) {
    bodyMap := ParseBody(req.body)
    mobileClip := bodyMap["clip"]
    if (mobileClip) {
        Clipboard := url.Decode(mobileClip)
        Tip("remoteControl:文字已复制!")
    }
    res.status := 200
}

Func_getClip(ByRef req, ByRef res) {
    res.SetBodyText(Clipboard)
    res.status := 200
}

Index(ByRef req, ByRef res) {
    res.SetBodyText("remote-control-ahk-http-server")
    res.status := 200
}
Fun_logo(ByRef req, ByRef res, ByRef server) {
    server.ServeFile(res, A_ScriptDir . "/resources/logo.png")
    res.status := 200
}
Fun_404(ByRef req, ByRef res) {
    res.SetBodyText("404: Page not found")
}
;========================= 业务逻辑 =========================







;========================= 公共函数 =========================
ParseBody(body) {
    ;bodyArray := StrSplit(body, "`n")
    bodyArray := StrSplit(body, "&")
    bodyMap := {}
    for i, value in bodyArray {
        pos := InStr(value, "=")
        key := SubStr(value, 1, pos - 1)
        val := SubStr(value, pos + 1)
        bodyMap[key] := val
    }
    return bodyMap
}
;========================= 公共函数 =========================
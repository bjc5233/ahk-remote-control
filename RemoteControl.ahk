;说明
;  远程控制PC，支持云剪切板\PC打开链接\常用快捷键控制(用于音乐和浏览页面)\webp图片自动转换\contextCmd项目
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
global paths := {}
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


global server := new HttpServer()
server.LoadMimes(A_ScriptDir . "/resources/mime.types")
server.SetPaths(paths)
server.Serve(9999)
global contentTypes := LoadContentTypes(A_ScriptDir . "/resources/mime.types")
global url := new URL()
return
;========================= 初始化 =========================






;========================= 业务逻辑 =========================
Func_webpConvert(ByRef req, ByRef res) {
    ;OneNote不支持webp图片的复制, 这里联合chrome插件右键搜执行
    ;   [webp图片转换]-[http://192.168.1.20:9999/webpConvert?image=%s]
    imageUrl := req.queries.image
    print(imageUrl)
    filePath := DownloadSync(imageUrl)
    ;如果是webp图片则进行格式转换为jpg
    if (InStr(filePath, ".webp", true)) {
        imagConvertPath := A_ScriptDir "\resources\imagemagick-convert.exe"
        filePath2 := filePath ".jpg"
        RunWait, %imagConvertPath% %filePath% %filePath2%, , hide
        filePath := filePath2
    }
    print(filePath)
    ;将图片复制到剪切板
    copyImagePath := A_ScriptDir "\resources\copyimg.exe"
    run, %copyImagePath% %filePath%, , hide
    Tip("图片已复制!")
    res.status := 200
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

LoadContentTypes(file) {
	if (!FileExist(file))
		return false

	FileRead, data, % file
	types := StrSplit(data, "`r`n")
	contentTypes := {}
	for i, data in types {
		if(!data)
			continue
		info := StrSplit(data, " ")
		contentType := info[1]
		exts := StrSplit(LTrim(SubStr(data, StrLen(contentType) + 1)), " ")
		contentTypes[contentType] := exts[1]
	}
	return contentTypes
}

DownloadSync(url) {
	xmlHTTP := ComObjCreate("MSXML2.XMLHTTP.6.0")
    xmlHTTP.open("GET", url, false)
    ;xmlHTTP.open("GET", url, true)
    ;xmlHTTP.onreadystatechange := Func("DownloadAsyncReady")
    xmlHTTP.send()

    if (xmlHTTP.readyState != 4)  ; Not done yet.
        return
    if (xmlHTTP.status == 200) {
		contentType := xmlHTTP.getResponseHeader("Content-Type")
		FormatTime, fileName, , yyyyMMddHHmmss
		fileExt := contentTypes[contentType]
		filePath := A_Temp "\" A_ScriptName "-" fileName "." fileExt
		print(filePath)
		
		
		streamObj := ComObjCreate("adodb.stream")
		streamObj.Type := 1			;1-二进制模式 2-文本模式
		streamObj.Mode := 3			;1-读 2-写 3-读写
		streamObj.Open()
		streamObj.Write(xmlHTTP.responseBody)
		streamObj.SaveToFile(filePath, 2)  ;2的意思是覆盖文件
		streamObj.Close()
		return filePath
	}
}

;========================= 公共函数 =========================
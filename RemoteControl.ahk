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
paths["/openChromeUrl"] := Func("Func_openChromeUrl")
paths["/getChromeUrl"] := Func("Func_getChromeUrl")
paths["/setclip"] := Func("Func_setClip")
paths["/getclip"] := Func("Func_getClip")
paths["/music"] := Func("Func_music")
paths["/direction"] := Func("Func_direction")
paths["/contextCmd"] := Func("Func_contextCmd")
paths["/webpConvert"] := Func("Func_webpConvert")
paths["/downPCFile"] := Func("Fun_downPCFile")
paths["/downPCFileName"] := Func("Fun_downPCFileName")
paths["/downClientFile"] := Func("Fun_downClientFile")


global server := new NewHttpServer()
server.LoadMimes(A_ScriptDir . "/resources/mime.types")
server.SetPaths(paths)
server.Serve(9999)
global contentTypes := LoadContentTypes(A_ScriptDir . "/resources/mime.types")
global urlUtil := new URL()
return


#U::    ;Win+U选择文件, 用于/downFile
    global selectedFile :=
    global selectedFileName :=
    FileSelectFile, selectedFile, 3, A_ScriptDir, 选择文件
    if (selectedFile) {
        SplitPath, selectedFile, selectedFileName
    }
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
        WinWaitActive, ContextCmd.ahk ahk_class AutoHotkeyGUI, , 2      ;等待"标题=ContextCmd.ahk, ahk_class=AutoHotkeyGUI"的窗口被激活
        if (ErrorLevel == 0) {
            Sleep 200
            SendInput, %cmd%
            Sleep 200
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

Func_openChromeUrl(ByRef req, ByRef res) {
    bodyMap := ParseBody(req.body)
    clientUrl := bodyMap["url"]
    if (clientUrl) {
        clientUrl := urlUtil.Decode(clientUrl)
        FoundPos := RegExMatch(clientUrl, "(http|ftp|https|file)://[\w]{1,}([\.\w]{1,})+[\w_/?&=#%:-]*", clientUrl2) ;校验\分离出url
        if (FoundPos != 0) {
            run, chrome.exe %clientUrl2%
        } else {
            run, chrome.exe www.baidu.com/s?wd=%clientUrl%
        }
    }
    res.status := 200
}

Func_getChromeUrl(ByRef req, ByRef res) {
	if WinExist("ahk_exe chrome.exe") {
        WinActivate         ;激活上面命令找到的那个窗口
        SendInput, ^l       ;定位到地址栏
        sleep, 100
        SendInput, ^c       ;复制chrome当前地址
        res.SetBodyText(Clipboard)
        res.status := 200
    } else {
        res.status := 404
    }
}

Func_setClip(ByRef req, ByRef res) {
    bodyMap := ParseBody(req.body)
    clientClip := bodyMap["clip"]
    if (clientClip) {
        Clipboard := urlUtil.Decode(clientClip)
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
    res.status := 404
}

Fun_downPCFile(ByRef req, ByRef res) {
    if (!selectedFile) {
        res.SetBodyText("请先在PC上选择文件(Win+U)")
        server.AddHeader(res, "Content-type", "text/plain; charset=utf-8")
        res.status := 404
        return
    }
    server.ServeFile(res, selectedFile)
    server.AddHeader(res, "Content-Disposition", "attachment; filename=" selectedFileName)
    print("/downFile:" selectedFile)
    res.status := 200
}
Fun_downPCFileName(ByRef req, ByRef res) {    ;辅助/downFile路径, 方便客户端获取要下载的文件名
    if (selectedFileName) {
        res.SetBodyText(selectedFileName)
        res.status := 200
    } else {
        res.SetBodyText("请先在PC上选择文件(Win+U)")
        server.AddHeader(res, "Content-type", "text/plain; charset=utf-8")
        res.status := 404
    }
}

Fun_downClientFile(ByRef req, ByRef res) {
    bodyMap := ParseBody(req.body)
    clientFilePath := bodyMap["filePath"]
    clientFileName := bodyMap["fileName"]
    if (!StrLen(clientFilePath) || !StrLen(clientFileName)) {
        res.SetBodyText("/downClientFile=> 需要配置参数filePath fileName")
        res.status := 404
    } else {
        clientFileName := urlUtil.Decode(clientFileName)
        clientFileDownPath := "C:\Users\bjc52\Downloads\" clientFileName
        clientFileDownUrl := "http://192.168.1.24:10000/download?path=" clientFilePath
        DownloadSync(clientFileDownUrl, clientFileDownPath)
        Tip("文件下载成功!")
        res.SetBodyText("/downClientFile=> 文件下载成功:" clientFileDownPath)
        res.status := 200
    }
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


DownloadSync(url, downFilePath:="") {
    ;参考https://docs.microsoft.com/zh-cn/windows/win32/winhttp/winhttprequest
    ;webRequest.setRequestHeader("Content-type", "application/json")
    webRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    webRequest.Open("GET", url, false)
    try {
        webRequest.Send()
    } catch e {
        MsgBox, % e.message 
        return
    }
    if (webRequest.Status == 200) {
        if (!downFilePath) {
            contentType := webRequest.GetResponseHeader("Content-Type")
            fileExt := contentTypes[contentType]
            FormatTime, fileName, , yyyyMMddHHmmss
            downFilePath := A_Temp "\" A_ScriptName "-" fileName "." fileExt
        }
        streamObj := ComObjCreate("adodb.stream")
        streamObj.Type := 1			;1-二进制模式 2-文本模式
        streamObj.Mode := 3			;1-读 2-写 3-读写
        streamObj.Open()
        streamObj.Write(webRequest.ResponseBody)
        streamObj.SaveToFile(downFilePath, 2)  ;2的意思是覆盖文件
        streamObj.Close()
        return downFilePath
    }
}
DownloadSync2(url, downFilePath:="") {
	xmlHTTP := ComObjCreate("MSXML2.XMLHTTP.6.0")
    xmlHTTP.open("GET", url, false)
    ;xmlHTTP.open("GET", url, true)
    ;xmlHTTP.onreadystatechange := Func("DownloadAsyncReady")
    xmlHTTP.send()

    if (xmlHTTP.readyState != 4)  ; Not done yet.
        return
    if (xmlHTTP.status == 200) {
		contentType := xmlHTTP.getResponseHeader("Content-Type")
        if (!downFilePath) {
            FormatTime, fileName, , yyyyMMddHHmmss
            fileExt := contentTypes[contentType]
            downFilePath := A_Temp "\" A_ScriptName "-" fileName "." fileExt
        }
		print("DownloadSync" downFilePath)
        
		streamObj := ComObjCreate("adodb.stream")
		streamObj.Type := 1			;1-二进制模式 2-文本模式
		streamObj.Mode := 3			;1-读 2-写 3-读写
		streamObj.Open()
		streamObj.Write(xmlHTTP.responseBody)
		streamObj.SaveToFile(downFilePath, 2)  ;2的意思是覆盖文件
		streamObj.Close()
		return downFilePath
	}
}
;========================= 公共函数 =========================



;========================= 类重写 =========================
class NewHttpServer extends HttpServer {
    LoadMimes(file) {
        if (!FileExist(file))
            return false

        FileRead, data, % file
        types := StrSplit(data, "`r`n")
        this.mimes := {}
        for i, data in types {
            info := StrSplit(data, " ")
            type := info.Remove(1)
            ; Seperates type of content and file types
            info := StrSplit(LTrim(SubStr(data, StrLen(type) + 1)), " ")

            for i, ext in info {
                this.mimes[ext] := type
            }
        }
        return true
    }
    ServeFile(ByRef response, file) {
        f := FileOpen(file, "r")
        length := f.RawRead(data, f.Length)
        f.Close()

        response.SetBody(data, length)
        response.headers["Content-Type"] := this.GetMimeType(file)
    }
    AddHeader(ByRef response, headKey, headValue) {
        response.headers[headKey] := headValue
    }
}
;========================= 类重写 =========================
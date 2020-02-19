GetSelectedFilePath() {
    savedClip := ClipboardAll
    Clipboard =
    SendInput, ^c
    ClipWait, 0.5
    clipItem := Clipboard
    Clipboard:= % savedClip
    
    filePaths := Object()
    if (StrSplit(clipItem, "`r").MaxIndex()==1) {
        clipItem := RegExReplace(clipItem, "`r`n", "")
        if (IsValidFilePath(clipItem))
            filePaths.Push(clipItem)
    } else {
        Loop, parse, clipItem, `r, `n
        {
            if (IsValidFilePath(A_LoopField))
                filePaths.Push(A_LoopField)
        }
    }
    return filePaths
}

GetSelectedText() {
    savedClip := ClipboardAll
    Clipboard =
    SendInput, ^c
    ClipWait, 0.5
    clipItem := Clipboard
    Clipboard:= % savedClip
	return clipItem
}

IsValidFilePath(filePath) {
    if (!filePath)
        return false
    foundPos := RegExMatch(filePath, "^([a-zA-Z]){1}:\\[^\/:*?<>|]{0,}")
    if (foundPos != 1)
        return false
    IfNotExist, %filePath%
        return false
    return true
}
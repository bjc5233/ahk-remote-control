# ahk-remote-control
> 远程控制PC，支持云剪切板\PC打开链接\文件传输\常用快捷键控制(用于音乐和浏览页面)\webp图片自动转换\contextCmd项目



### 使用说明
1. 运行脚本，会启动HTTP Server，监听9999端口
2. 准备一只局域网内的客户端(如手机-tasker\curl\浏览器)
3. 客户端发送HTTP请求, 在url中指定命令类型, body中指定参数(如http://192.168.1.20:9999/chrome，具体参考命令列表)
4. 如果使用tasker作为客户端，可以导入项目resources\RemoteCtlPC.prj.xml


### 演示
|云剪切板[client-mobile端]|云剪切板[PC端]|
|-|-|
|<img src="https://github.com/bjc5233/ahk-remote-control/raw/master/resources/demo-setclip-mobile.gif"/>|<img src="https://github.com/bjc5233/ahk-remote-control/raw/master/resources/demo-setclip-PC.gif"/></div>|




### 命令列表
|路径|说明与参数|场景与操作|
|-|-|-|
|/openChromeUrl|让PC端chrome中打开指定url<br>body[url=value]|------------------ 场景1<br>1. 查看一篇文章，复制链接(在微信\知乎等APP上都有此选项)<br>2. 自动弹出[tasker-foo](https://github.com/bjc5233/tasker-foo)蓝色小圆点<br>3. 点击小圆点, 弹出剪切板文本快捷操作, 选择[PC浏览器打开]<br>4. 在PC上查看此篇文章<br>------------------ 场景2<br>1. 查看一篇文章，没有"复制链接"选项<br>2. 点击分享->更多->AutoShareCommand(tasker插件)->选择配置[在PC浏览器打开]<br>3. 在PC上查看此篇文章<br>------------------ 场景3<br>1. 长按选中文本, 弹出系统级选项<br>2. 点击分享->AutoShareCommand(tasker插件)->选择配置[在PC浏览器打开]<br>3. 在PC上百度搜索选中的文本|
|/getChromeUrl|获取PC端chrome当前url||
|/setclip|云剪切板: 设置PC端剪切板<br>body[clip=value]|1. 发现一段不错的文字，长按选中复制文本<br>2. 自动弹出[tasker-foo](https://github.com/bjc5233/tasker-foo)蓝色小圆点<br>3. 点击小圆点, 弹出剪切板文本快捷操作, 选择[PC复制到剪切板]<br>4. 在PC上记录这段文字|
|/getclip|云剪切板: 获取PC端剪切板文字|1. 在电脑上看一篇文章，需要出门但有碎片时间, 或者是要上厕所去哈<br>2. 将这片文章的url复制一下(在地址栏Ctrl+V)<br>3. 手机端点击桌面tasker任务快捷方式[获取PC剪切板], 提示[复制成功]<br>4. 打开手机浏览器查看|
|/music|音乐类控制快捷键<br>body[action=value]|1. toggle:音乐启动停止ctrl+alt+p<br>2. next:音乐下一曲ctrl+alt+right<br>3. prev:音乐上一曲ctrl+alt+left|
|/direction|页面浏览类快捷键<br>body[direction=value]|1. up:    ↑   (常用于音量增加)<br>2. down:  ↓   (常用于音量降低)<br>3. right: →   (常用于视频快进)<br>4. left:  ←   (常用于视频后退)<br>5. pageUp:    (常用于文档\网页上翻页)<br>6. pageDown:  (常用于文档\网页上翻页)|
|/contextCmd|向[contextCmd](https://github.com/bjc5233/ahk-context-cmd)程序发送命令，实现更丰富的控制<br>body[value]||
|/webpConvert|OneNote不能复制webp图片，将webp图片转为jpg, 并复制到剪切板<br>/webpConvert?image=%s|可以使用chrome插件[右键搜]配置<br>{[webp图片转换]-[http://192.168.1.20:9999/webpConvert?image=%s]}|
|/downPCFile<br>/downPCFileName|下载PC端指定文件|1. 在PC端Win+U选择文件<br>2. 通过/downFileName接口获取下载文件名(可选)<br>3. 通过/downFile下载文件|
|/downClientFile|让PC端下载客户端指定文件<br>body[filePath=value1&fileName=value2]|1. 环境配置: termux+python+flask(WebServer)<br>2. 选择文件, 发送\分享, 选择AutoShare-上传文件到PC<br>3. 触发tasker执行task-remotePCUploadFile, 发送请求<br>4. PC端得到要下载的客户端文件路径, 执行下载|
|/playClientMusic|让PC端下载播放客户端指定音乐<br>body[filePath=value1&fileName=value2]|1. 环境配置: termux+python+flask(WebServer)<br>2. 选择音乐, 发送\分享, 选择AutoShare-在PC播放音乐<br>3. 触发tasker执行task-remotePCUploadPlayMusic, 发送请求<br>4. PC端下载客户端文件, 调用默认音乐播放器播放|
|/volumeUp<br>/volumeDown|增加\减少PC端10格音量||






### 注意
1. 如果传输数据包含中文, 发送方需配置content-type:application/x-www-form-urlencoded
2. setclip功能注意点：
   * tasker-HTTP-POST功能中，请求创建界面，如果文本包含换行符则不能发送
   * tasker提供的convert-urlencode函数不标准, [空格]会被解析成[+]；需要RegReplace(%clipboard, "\+", "%20")再处理一遍
   * tasker-HTTP-POST中默认使用application/x-www-form-urlencoded编码，修改为text/plain (已经编码过了)



### TODO
1. 文件上传
2. 远程界面端-可以使用html     xxxx:9999则返回此html[界面参考tasker-todo.png   可以进行上述几个命令操作]
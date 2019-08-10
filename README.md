# ahk-remote-control
> 远程控制PC，通过发送http请求使PC执行指定命令



### 说明
1. 在PC上启动HTTP Server，并监听9999端口
2. 需要局域网内的客户端。客户端可以是一台手机(通过tasker App发送请求)、curl、另一台电脑浏览器
3. 客户端发送HTTP请求, 在url中指定命令类型, body中指定参数
4. 配置自己的端口号\命令列表



### 命令列表
1. chrome: 从远程端传递url链接, 在PC的chrome浏览器中打开
   * ========================= 场景1 =========================
   * 查看一篇文章，复制链接(在微信\知乎等APP上都有此选项)
   * 自动弹出[tasker-foo](https://github.com/bjc5233/tasker-foo)蓝色小圆点
   * 点击小圆点, 弹出剪切板文本快捷操作, 选择[PC浏览器打开]
   * 在PC上查看此篇文章
   * ========================= 场景2 =========================
   * 查看一篇文章，没有"复制链接"选项
   * 点击分享->更多->AutoShareCommand(tasker插件)->选择配置[在PC浏览器打开]
   * 在PC上查看此篇文章
   * ========================= 场景3 =========================
   * 长按选中文本, 弹出系统级选项
   * 点击分享->AutoShareCommand(tasker插件)->选择配置[在PC浏览器打开]
   * 在PC上百度搜索选中的文本
2. clip/set: 从远程端传递文字, 并设置到PC的剪切板
   * ========================= 场景1 =========================
   * 发现一段不错的文字，长按选中文本
   * 自动弹出[tasker-foo](https://github.com/bjc5233/tasker-foo)蓝色小圆点
   * 点击小圆点, 弹出剪切板文本快捷操作, 选择[PC复制到剪切板]
   * 在PC上记录这段文字
3. clip/get: 将PC的剪切板文字返回\传递给远程端
   * ========================= 场景1 =========================
   * 在电脑上看一篇文章，需要出门但有碎片时间, 或者是要上厕所去哈
   * 将这片文章的url复制一下(在地址栏Ctrl+V)
   * 手机端点击桌面tasker任务快捷方式[获取PC剪切板], 提示[复制成功]
   * 打开手机浏览器查看
4. music:      body[action={action}]
   * toggle:音乐启动停止ctrl+alt+p
   * next:音乐下一曲ctrl+alt+right
   * prev:音乐上一曲ctrl+alt+left
5. direction     body[direction={direction}]
   * up:    ↑   (常用于音量增加)
   * down:  ↓   (常用于音量降低)
   * right: →   (常用于视频快进)
   * left:  ←   (常用于视频后退)
   * pageUp:    (常用于文档\网页上翻页)
   * pageDown:  (常用于文档\网页上翻页)
6. contextCmd: 向[contextCmd](https://github.com/bjc5233/ahk-context-cmd)程序发送命令，实现更丰富细致的控制




### 注意
1. 如果传输数据包含中文, 发送方需配置content-type:application/x-www-form-urlencoded




### TODO
1. 文件传输
2. 传输演示gif demo
2. 手机端tasker配置文件放在此项目中
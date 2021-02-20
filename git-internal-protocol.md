## Git 底层原理：传输协议分析

### 概要
Git 客户端和服务端交互的协议支持 4 种：本地协议、HTTP 协议、SSH 协议、 Git 协议，在我们的日常开发过程中，接触最多的是 HTTP 协议和 SSH 协议。一般通过如下命令和服务器进行交互：

```bash
# ssh 协议
$ git clone ssh://user@server/project.git
# 或者
$ git clone user@server:project.git

# http(s) 协议
$ git clone https://server/project.git
# 或者带上用户名密码
$ git clone https://user:token@server/project.git
```

> 参考文章：[Git on the Server - The Protocols](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols)。

### Wireshark 抓包分析 git https 传输协议

[Wireshark](https://www.wireshark.org/) 是一个抓包工具，有非常强大的过滤和分析功能，用该工具分析 git 协议流非常方便。

#### 准备工作
本文使用阿里云的代码托管平台 [Codeup](https://codeup.aliyun.com/) 来分析传输协议。当然，你也可以使用 [Github](https://github.com) 或者 [Gitee](https://gitee.com/) 。
> github 使用的是 [http/2 协议](https://developers.google.com/web/fundamentals/performance/http2?hl=zh-cn)。 http/2 协议因为数据帧是二进制格式，对于分析 https 交互并不直观，所以本文使用了 Codeup 作为示例，Codeup 使用的是 http/1.1 协议。

##### 1. 查看服务器 ip 地址
```c
host codeup.aliyun.com
codeup.aliyun.com has address 118.31.165.50
```
服务器 ip 地址为 `118.31.165.50` 。

##### 2. 设置 `SSLKEYLOGFILE` 环境变量
通过设置 `SSLKEYLOGFILE`环境变量，可以保存 TLS 的会话钥匙（Session Key），wireshark 再读取 Session Key 然后实时解析 https 数据流，具体可以参考这篇文章：[Walkthrough: Decrypt SSL/TLS traffic (HTTPS and HTTP/2) in Wireshark](https://joji.me/en-us/blog/walkthrough-decrypt-ssl-tls-traffic-https-and-http2-in-wireshark/#:~:text=The%20second%20method%20to%20decrypt%20SSL%2FTLS%20packets%20is,generate%20TLS%20session%20keys%20out%20to%20that%20file.)。

```bash
export SSLKEYLOGFILE=~/sslkeylog.log
```

##### 3. 设置 Wireshark
首先让 Wireshark 读取 `sslkeylog.log`，打开 Wireshark，点击 `菜单` >`Performances`，在对话框中选择 `Protocol` > `TLS`，设置 `(Pre)-Master-Secret log filename` 为你的 `SSLKEYLOGFILE` 文件路径：

<div align="center">
<img style="height:400px" src="https://img.alicdn.com/imgextra/i4/O1CN01P91BS21uuvs0F0dlB_!!6000000006098-2-tps-1432-1094.png" />
</div>

<!-- ![](./res/wireshark-perferences.png) -->

启动wireshark 监听网卡，设置过滤规则为 <span style="text-shadow: 0 1px #fff; color: #822659; background: #eee;border-radius: 3px;">tls && http && ip.addr == 118.31.165.50</span>，其中 `118.31.165.50`就是获取到的服务器 ip 地址。

#### git clone

做完上面的准备工作后，就可以开始抓包分析了。运行 `git clone` 命令：

```bash
# 确保设置了 SSLKEYLOGFILE 环境变量
# export SSLKEYLOGFILE=~/sslkeylog.log
$ git clone https://codeup.aliyun.com/5ed5e6f717b522454a36976e/Codeup-Demo.git
```
Wireshark 抓包得到如下数据包：

![](https://img.alicdn.com/imgextra/i4/O1CN019piDk81N0hvSwYyKK_!!6000000001508-2-tps-3654-446.png)

点击 `菜单` > `Analyze` > `Follow` > `HTTP Stream` 可以更直观的查看数据交互流：

![](https://img.alicdn.com/imgextra/i2/O1CN01tFheyx1sfF4GEl70e_!!6000000005793-2-tps-3656-2312.png)

接下来分析一下 `git clone` 的交互过程。

##### 第一次交互：引用发现

第一次交互主要起到 `握手` + `获取仓库信息` 的作用。服务端认证用户信息，并告诉客户端对应仓库的所有引用信息，以及相关的仓库信息。

```
首先客户端发起请求（在`Authorization`字段附上了用户名密码）
>>>>>>>>>>>>>>>>>>>>>>>>>>>
GET /5ed5e6f717b522454a36976e/Codeup-Demo.git/info/refs?service=git-upload-pack
>>>>>>>>>>>>>>>>>>>>>>>>>>>


服务端认证用户信息，然后返回引用列表
<<<<<<<<<<<<<<<<<<<<<<<<<<<
001e# service=git-upload-pack
000001163ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 HEAD\0multi_ack thin-pack side-band side-band-64k ofs-delta shallow deepen-since deepen-not deepen-relative no-progress include-tag multi_ack_detailed no-done symref=HEAD:refs/heads/master object-format=sha1 agent=git/2.28.0.agit.6.0
0040f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea refs/heads/develop
004961ee902744d1f5a480e607856d44b104602d6b13 refs/heads/feature/p3c_scan
004fae02248d14bfdc9d4d38b1532cab278d179bc863 refs/heads/feature/sensitive_scan
003f3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 refs/heads/master
00676508471ba8d143e1bfc41c391280a7ef533be57b refs/keep-around/6508471ba8d143e1bfc41c391280a7ef533be57b
0067fe94112642bb8c57f6d08309f376135744fcb24e refs/keep-around/fe94112642bb8c57f6d08309f376135744fcb24e
004d6508471ba8d143e1bfc41c391280a7ef533be57b refs/merge-requests/267112/head
004dfe94112642bb8c57f6d08309f376135744fcb24e refs/merge-requests/267123/head
003c3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 refs/tags/v1.0
0000
<<<<<<<<<<<<<<<<<<<<<<<<<<<
```

服务端返回的信息具有一定的格式（ [pkt-line 格式](#pkt-line-数据流) ），每一行都以一个四位的十六进制值开始，用于指明本行的长度。第二行的 0000 和结尾 0000 告诉 git 已经完成了一个过程。

这次交互里面，根据 0000 出现的位置，可以知道服务端返回的信息里面包含了2部分，第一部分是：

```
001e# service=git-upload-pack
0000
```
表示这次回复的数据类型是 `git-upload-pack`。

第二部分的第一行内容信息比较多：
```
01163ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 HEAD\0multi_ack thin-pack side-band side-band-64k ofs-delta shallow deepen-since deepen-not deepen-relative no-progress include-tag multi_ack_detailed no-done symref=HEAD:refs/heads/master object-format=sha1 agent=git/2.28.0.agit.6.0
```

这段信息主要描述 HEAD 指针信息，以及功能列表信息，比如 `symref=HEAD:refs/heads/master` 表示默认分支为 `master` ，`object-format=sha1` 表示对象使用 `sha1` 校验对象，`agent=git/2.28.0.agit.6.0` 服务器 git 版本信息。

第二部分第二行开始的信息则是 `info/refs` 文件内容。`info/refs` 文件描述了仓库里面的引用信息，包括分支、 tag ，以及一些自定义引用等。

> 值得一提的是，服务器回复的 `info/refs` 文件内容里，除了 `refs/heads/*` 和 `refs/tags/*`，还存在 `refs/keep-around/*` 和 `refs/merge-requests/*` 等引用，这些是 Codeup 平台特有的引用。

你也可以使用`` `git --exec-path`/git-update-server-info`` 命令来生成 `info/refs` 文件：
```bash
$ `git --exec-path`/git-update-server-info && cat .git/info/refs
3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12	refs/heads/master
3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12	refs/remotes/origin/HEAD
f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea	refs/remotes/origin/develop
61ee902744d1f5a480e607856d44b104602d6b13	refs/remotes/origin/feature/p3c_scan
ae02248d14bfdc9d4d38b1532cab278d179bc863	refs/remotes/origin/feature/sensitive_scan
3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12	refs/remotes/origin/master
3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12	refs/tags/v1.0
```

实际上这一段的数据流及格式官方文档里面有详细的说明： [http-protocol.txt](https://github.com/git/git/blob/master/Documentation/technical/http-protocol.txt#L163)，也可以参考本文末的 [git 传输协议格式](#git-传输协议格式)。

##### 第二次交互：请求数据
第二次交互里，客户端把想要的数据告诉给服务端，服务端然后把 pack 包推送回来。
```
客户端发送数据到服务器
>>>>>>>>>>>>>>>>>>>>>>>>>>>
POST /5ed5e6f717b522454a36976e/Codeup-Demo.git/git-upload-pack

00a8want f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea multi_ack_detailed no-done side-band-64k thin-pack ofs-delta deepen-since deepen-not agent=git/2.24.3.(Apple.Git-128)
0032want 61ee902744d1f5a480e607856d44b104602d6b13
0032want ae02248d14bfdc9d4d38b1532cab278d179bc863
0032want 3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12
0032want 3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12
00000009done
>>>>>>>>>>>>>>>>>>>>>>>>>>>


服务器回复 pack 包
<<<<<<<<<<<<<<<<<<<<<<<<<<<
0008NAK
0024\0x02Enumerating objects: 48, done.
0023.Counting objects:   2% (1/48)
0023.Counting objects:   4% (2/48)
...省略...
0024.Counting objects:  97% (47/48)
0024.Counting objects: 100% (48/48)
002b.Counting objects: 100% (48/48), done.
2004.PACK.......0..x...... ....O.}!81.
KY..OQ.q.)....}..C...>..Et,."..)........O.b :o..2G...uhK.s.. 3.+N.	</P..a..L.Y.1...k.r..71..........X...X.......m.B{Z....m.hp......2..u.}.C>/+.Y.j..k...m.>=.M....Z...x...Aj.!.....{.`....B`...m...2.....G.Z..Z.....
....E.O&D"g.V.
...省略...
......,.....$.....x.}Q=k.1...+.MI...,.Ph.PH...OM..,W..A...}M..J5........{.Em....9...a...T.A..G.+..H,.x.)...w6=......I..ay.....7.q......G....1...X.G..s0'H....;..O%.....".....:......d1V....fJ...d....pd..j1JV1o...z..~C_l......%...N..z.L....@.+.V+'...|.=..c:&}'..T....r~...9F+.......7....V(s3....uQ....T7.=F..Gt`i.Z.	n..Vn0006..003b.Total 48 (delta 0), reused 0 (delta 0), pack-reused 0
0000
<<<<<<<<<<<<<<<<<<<<<<<<<<<
```

通过第一次交互里，客户端拿到了远程仓库的引用列表，然后把想要的 `commit-id` （及其提交链）发送给服务端。具体点其实就是 branch 和 tag 对应的 `commit-id` 。数据格式跟上面的服务端回复的引用列表格式类似。

服务器回复的是 HTTP 数据流格式，其中包括了进度、pack 二进制数据等，其第一行的 `NAK` 代表数据开始，

#### git 传输协议格式
##### pkt-line 数据流
pkt-line 数据流用来描述引用信息，每一行的前四个字节代表这一行的十六进制编码的长度，包括这四个字节和数据在内。因为包括自身四个字节，前四个直接一定大于0004，所以 pkt-line 格式定义了3个特殊的编码：
* _**0000**_ ( `flush-pkt` )：代表一段消息的结束。
* _**0001**_ ( `delim-pkt` )：代表一段消息的分节符。
* _**0002**_ ( `response-end-pkt` )：无状态会话时响应结束。

整体来讲，一个 pkt-line 数据流一般由如下几部分组成：
```
PKT-LINE("# service=$servicename" LF)
"0000"
ref_list
"0000"
```

其中
* _**`PKT-LINE`**_ 代表这一行是 pkt-line 格式的。
* _**`servicename`**_ 是服务类型，git clone、git fetch 时是 `git-upload-pack`，git push 则是 `git-receive-pack`。
* _**`ref_list`**_ 是引用信息列表，一定是按照引用名称排序的。

_**`ref_list`**_ 第一个引用一定是 `HEAD` ， `HEAD` 后面一定有支持的功能说明（ capability declarations ）第一条引用信息格式为：

```
PKT-LINE(obj-id SP name NUL cap_list LF)
```
> `cap_list` 是支持的功能列表。
后面的引用信息格式为：

```
PKT-LINE(obj-id SP name LF)

# 或者
PKT-LINE(obj-id SP name LF)
PKT-LINE(obj-id SP name "^{}" LF)
```
> 其中 `name^{}` 是 [git revision](https://git-scm.com/docs/gitrevisions ) 中定义的格式，表示递归该引用找到非 tag 类型的 object 。
> 另外，如果该仓库没有引用时，那 `ref_list` 的内容则是：`PKT-LINE(zero-id SP "capabilities^{}" NUL cap-list LF)` 。

pkt-line 官方说明见：[http-protocol.txt](https://github.com/git/git/blob/master/Documentation/technical/http-protocol.txt#L163)。

##### sideband 格式
前四个字节和 pkt-line 格式相同，代表这一行的数据长度。第五位用于标志消息类型，_`0x01`_ 代表是packfile 数据，_`0x02`_ 代表是进度消息，_`0x03`_ 代表是错误信息。


如下绘制了git clone 的 https 协议交互图：

#### git fetch

#### git push

### 分析 git ssh 传输协议

#### git clone

#### git fetch

#### git push

### 



wireshark 过滤条件
tls && ip.addr == 118.31.165.50



http(s)://，ssh://，git://



```
HTTP/1.1 200 OK
Server: Tengine
Date: Thu, 18 Feb 2021 12:48:44 GMT
Content-Type: application/x-git-upload-pack-advertisement
Content-Length: 1015
Connection: keep-alive
Cache-Control: no-cache

001e# service=git-upload-pack
000001163ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 HEADmulti_ack thin-pack side-band side-band-64k ofs-delta shallow deepen-since deepen-not deepen-relative no-progress include-tag multi_ack_detailed no-done symref=HEAD:refs/heads/master object-format=sha1 agent=git/2.28.0.agit.6.0
0040f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea refs/heads/develop
004961ee902744d1f5a480e607856d44b104602d6b13 refs/heads/feature/p3c_scan
004fae02248d14bfdc9d4d38b1532cab278d179bc863 refs/heads/feature/sensitive_scan
003f3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 refs/heads/master
00676508471ba8d143e1bfc41c391280a7ef533be57b refs/keep-around/6508471ba8d143e1bfc41c391280a7ef533be57b
0067fe94112642bb8c57f6d08309f376135744fcb24e refs/keep-around/fe94112642bb8c57f6d08309f376135744fcb24e
004d6508471ba8d143e1bfc41c391280a7ef533be57b refs/merge-requests/267112/head
004dfe94112642bb8c57f6d08309f376135744fcb24e refs/merge-requests/267123/head
003c3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 refs/tags/v1.0
0000
```


```
00a8want f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea multi_ack_detailed no-done side-band-64k thin-pack ofs-delta deepen-since deepen-not agent=git/2.24.3.(Apple.Git-128)
0032want 61ee902744d1f5a480e607856d44b104602d6b13
0032want ae02248d14bfdc9d4d38b1532cab278d179bc863
0032want 3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12
0032want 3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12
00000009done

```



ssh 是建立在tcp之上的。
最后协商成功之后，将会生成一个对称加密 会话密钥key 以及一个 会话ID ，在这里要特别强调，这个是对称加密密钥key，



从服务器拉取 拉取 info/refs 文件内容。
```bash
`git --exec-path`/git-update-server-info && cat .git/info/refs
3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12	refs/heads/master
3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12	refs/remotes/origin/HEAD
f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea	refs/remotes/origin/develop
61ee902744d1f5a480e607856d44b104602d6b13	refs/remotes/origin/feature/p3c_scan
ae02248d14bfdc9d4d38b1532cab278d179bc863	refs/remotes/origin/feature/sensitive_scan
3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12	refs/remotes/origin/master
3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12	refs/tags/v1.0
```

上面使用wireshark 抓取到的协议叫智能（smart）协议，实际上 Git 1.6.6 之前的版本（2010年前）一直使用哑(Dumb)协议。使用哑协议的版本库很难保证安全性和私有化，而且只能架设只读版本库，目前已经很少使用了，哑协议的交互过程可以参考《[Git Internals - Transfer Protocols](https://git-scm.com/book/en/v2/Git-Internals-Transfer-Protocols)》。
### 参考资料

* https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols
* https://git-scm.com/book/en/v2/Git-Internals-Transfer-Protocols
* https://wangdoc.com/ssh/client.html
* https://github.com/gcla/termshark
* https://github.com/git/git/blob/master/Documentation/technical/http-protocol.txt
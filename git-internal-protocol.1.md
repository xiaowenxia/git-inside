## Git 底层原理：传输协议分析（一）

### 目录

* [概要](#概要)
* [git https 传输协议分析](#git-https-传输协议分析)
    - [准备工作](#准备工作)
    - [git clone](#git-clone)
    - [git fetch](#git-fetch)
    - [git push](#git-push)
* [git ssh 传输协议分析](#git-ssh-传输协议分析)
* [总结](#总结)
* [参考资料](#参考资料)

### 概要
本文通过分析 git 的 http 协议开始，由浅入深循序渐进的展开 Git 传输协议的分析。

> 参考文章：[Git on the Server - The Protocols](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols)。

### git https 传输协议分析

[Wireshark](https://www.wireshark.org/) 是一个抓包工具，有非常强大的过滤和分析功能，用该工具分析 git 协议流非常方便。

> 不借助 Wireshark ，设置 `GIT_TRACE_CURL` 环境变量也能够查看到 Git 的传输协议过程，具体看 [GIT_TRACE_CURL](https://git-scm.com/docs/git#Documentation/git.txt-codeGITTRACECURLcode) 或《 Git 底层原理：传输协议分析（二）》。

#### 准备工作
本文使用阿里云的代码托管平台 [Codeup](https://codeup.aliyun.com/) 来分析传输协议。当然，你也可以使用 [Github](https://github.com) 或者 [Gitee](https://gitee.com/) 。
> github 使用更高效的 [http/2 协议](https://developers.google.com/web/fundamentals/performance/http2?hl=zh-cn)。 http/2 协议因为数据帧是二进制格式，对于分析 https 交互并不直观，所以本文使用基于 http/1.1 协议的 Codeup 作为示例。

##### 1. 查看服务器 ip 地址
```c
host codeup.aliyun.com
codeup.aliyun.com has address 118.31.165.50
```
服务器 ip 地址为 `118.31.165.50` 。

##### 2. 设置 `SSLKEYLOGFILE` 环境变量
通过设置 `SSLKEYLOGFILE`环境变量，可以保存 TLS 的会话钥匙（ `Session Key` ），wireshark 再读取 `Session Key` 然后实时解析 https 数据流，具体可以参考这篇文章：[Walkthrough: Decrypt SSL/TLS traffic (HTTPS and HTTP/2) in Wireshark](https://joji.me/en-us/blog/walkthrough-decrypt-ssl-tls-traffic-https-and-http2-in-wireshark/#:~:text=The%20second%20method%20to%20decrypt%20SSL%2FTLS%20packets%20is,generate%20TLS%20session%20keys%20out%20to%20that%20file.)。
如下设置：
```bash
# 该命令只在当前终端生效。
export SSLKEYLOGFILE=~/sslkeylog.log
```

##### 3. 设置 Wireshark
首先让 Wireshark 读取 `sslkeylog.log`，打开 Wireshark，点击 `菜单` >`Performances`，在对话框中选择 `Protocol` > `TLS`，设置 `(Pre)-Master-Secret log filename` 为你的 `SSLKEYLOGFILE` 文件路径：

<div align="center">
<img src="https://img.alicdn.com/imgextra/i4/O1CN01P91BS21uuvs0F0dlB_!!6000000006098-2-tps-1432-1094.png" width="600"/>
</div>

启动 Wireshark 监听网卡，设置过滤规则为 `tls && http && ip.addr == 118.31.165.50` ，其中 `118.31.165.50`就是获取到的服务器 ip 地址。

#### git clone

做完上面的准备工作后，就可以开始抓包分析了。运行 `git clone` 命令：

```bash
# 确保设置了 SSLKEYLOGFILE 环境变量
# export SSLKEYLOGFILE=~/sslkeylog.log
$ git clone https://codeup.aliyun.com/5ed5e6f717b522454a36976e/Codeup-Demo.git
```
Wireshark 抓包得到如下数据包：

![](https://img.alicdn.com/imgextra/i4/O1CN019piDk81N0hvSwYyKK_!!6000000001508-2-tps-3654-446.png)
> 一开始有个 `Unautherized` 的过程，这个是 git 在尝试匿名访问。

点击 `菜单` > `Analyze` > `Follow` > `HTTP Stream` 可以更直观的查看数据交互流，这些数据是 HTTP 内容（不包括TLS）：

![](https://img.alicdn.com/imgextra/i2/O1CN01tFheyx1sfF4GEl70e_!!6000000005793-2-tps-3656-2312.png)

接下来分析一下 `git clone` 的交互过程。

##### 第一次交互：引用发现

第一次交互主要起到 `握手` + `获取仓库引用信息` 的作用。服务端认证用户信息，并告诉客户端对应仓库的所有引用信息，以及相关的功能信息。

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
...省略...
003c3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 refs/tags/v1.0
0000
<<<<<<<<<<<<<<<<<<<<<<<<<<<
```

**客户端** 发起的 GET 请求，URL 为 `$GIT_URL/info/refs?service=git-upload-pack`。

**服务端** 返回的信息按照 pkt-line 格式编排，信息主要是远程仓库的引用信息。pkt-line 格式定义每一行的前四个字节代表这一行的十六进制编码的长度，同时也定义前四个字节 _`0000`_ 为一点消息的结束。详细说明见文末的 [pkt-line 格式](#pkt-line-格式)。
这次交互里面，根据 _`0000`_ 出现的位置，可以知道服务端返回的信息里面包含了2部分，第一部分是固定字段，表示这次回复的服务类型是 `git-upload-pack`。
第二部分的第一行内容信息比较多：
```
01163ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 HEAD\0multi_ack thin-pack side-band side-band-64k ofs-delta shallow deepen-since deepen-not deepen-relative no-progress include-tag multi_ack_detailed no-done symref=HEAD:refs/heads/master object-format=sha1 agent=git/2.28.0.agit.6.0
```

这段信息主要描述 HEAD 指针信息，以及功能列表（ capability declarations ）信息，比如 `symref=HEAD:refs/heads/master` 表示默认分支为 `master` ，`object-format=sha1` 表示对象使用 `sha1` 校验对象，`agent=git/2.28.0.agit.6.0` 服务器 git 版本信息。

第二部分第二行开始的信息则是 `info/refs` 文件内容。`info/refs` 文件描述了仓库里面的引用信息，包括分支、 tag ，以及一些自定义引用等。

> * 值得一提的是，本示例中服务器回复的 `info/refs` 文件内容里，除了 `refs/heads/*` 和 `refs/tags/*`，还存在 `refs/keep-around/*` 和 `refs/merge-requests/*` 等引用，这些是 Codeup 平台特有的引用。
> * 你可以使用`` `git --exec-path`/git-update-server-info`` 命令来生成 `info/refs` 文件。

实际上这一段的数据流及格式官方文档里面有详细的说明： [http-protocol.txt](https://github.com/git/git/blob/master/Documentation/technical/http-protocol.txt#L163)，也可以参考本文末的 [引用数据流](#引用发现数据格式)。

##### 第二次交互：请求数据
第二次交互里，客户端把想要的数据告诉给服务端，服务端然后把 pack 包推送给客户端。
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
0024\2Enumerating objects: 48, done.
0023\2Counting objects:   2% (1/48)
...省略...
002b\2Counting objects: 100% (48/48), done.
2004\1PACK.......0..x...... ....O.}!81.
KY..OQ.q.)....}..C...>..Et,."..)........O.b :o..2G...uhK.s.. 3.+N.	</P..a..L.Y.1...k.r..71..........X...X.......m.B{Z....m.hp......2..u.}.C>/+.Y.j..k...m.>=.M....Z...x...Aj.!.....{.`....B`...m...2.....G.Z..Z.....
...省略...
......,.....$.....x.}Q=k.1...+.MI...,.Ph.PH...OM..,W..A...}M..J5........{.Em....9...a...T.A..G.+..H,.x.)...w6=......I..ay.....7.q......G....1...X.G..s0'H....;..O%.....".....:......d1V....fJ...d....pd..j1JV1o...z..~C_l......%...N..z.L....@.+.V+'...|.=..c:&}'..T....r~...9F+.......7....V(s3....uQ....T7.=F..Gt`i.Z.	n..Vn
0006\1.
003b\2Total 48 (delta 0), reused 0 (delta 0), pack-reused 0
0000
<<<<<<<<<<<<<<<<<<<<<<<<<<<
```

通过第一次交互里，**客户端** 拿到了远程仓库的引用列表，然后在第二次交互里把想要的 `commit-id` （及其提交链）发送给服务端。
客户端发起的是 POST 请求，URL 为 `$GIT_URL/git-upload-pack` ，POST 内容为想要（ _`"want"`_ ）的 `commit-id` 和已有（ _`"have"`_ ）的 `commit-id`，其实就是 branch 和 tag 对应的 `commit-id` 。数据格式跟上面的服务端回复的引用列表格式类似，具体见 [git-upload-pack 数据流格式](#git-upload-pack-数据流格式)。

**服务端** 会根据 _`"want"`_ 和 _`"have"`_ 的情况来决定回复最小可用的数据包给客户端，这也是智能（smart）协议的作用所在，相关的机制见 [http-protocol.txt](https://github.com/git/git/blob/master/Documentation/technical/http-protocol.txt#L420) 。
服务端回复的是 HTTP 数据流格式（ HTTP stream ），其中包括了进度、pack 二进制数据等。第一行的 `NAK` 代表数据开始，后面的数据则使用了 side-band 格式（类似于 pkg-line 格式），来描述传输进度、数据包等。 side-band 格式前四个字节也是用于表示长度，第五个字节用于标志消息类型，_`0x01`_ 代表是packfile 数据，_`0x02`_ 代表是进度消息，_`0x03`_ 代表是错误信息。

#### git fetch

用 Wireshark 抓包看看 git fetch 过程：

![](https://img.alicdn.com/imgextra/i2/O1CN01RnN1z21QUQTWDXiAY_!!6000000001979-2-tps-3654-440.png)

可以看到，交互过程和 [`git clone`](#git-clone) 是一样的，不同的是，客户端请求数据时，除了想要（ _`"want"`_ ）的 commit-id ，还带上了已有（ _`"have"`_ ）的 commit-id ，服务端回复数据时，也添加了 `ACK` 字段来告诉客户端我回复的是哪些数据。

```
客户端请求数据
>>>>>>>>>>>>>>>>>>>>>>>>>>>
POST /5ed5e6f717b522454a36976e/Codeup-Demo.git/git-upload-pack HTTP/1.1

00b4want 113cc207f5a226e066f1119b51e57e2b8fbd8e28 multi_ack_detailed no-done side-band-64k thin-pack include-tag ofs-delta deepen-since deepen-not agent=git/2.24.3.(Apple.Git-128)
00000032have 61ee902744d1f5a480e607856d44b104602d6b13
0032have ae02248d14bfdc9d4d38b1532cab278d179bc863
0032have f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea
0009done
>>>>>>>>>>>>>>>>>>>>>>>>>>>

服务端返回数据
<<<<<<<<<<<<<<<<<<<<<<<<<<<
0038ACK 61ee902744d1f5a480e607856d44b104602d6b13 common
0038ACK ae02248d14bfdc9d4d38b1532cab278d179bc863 common
0038ACK f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea common
0031ACK f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea
0023\x02Enumerating objects: 3, done.
0022\x02Counting objects:  33% (1/3)
0029\x02Counting objects: 100% (3/3), done.
01d4\x01PACK..........x...K.. ...=.{c..<...U^.UH,5....x..z.=.=...d..D.\.i:. 8..h..CT.(.h
...省略...
.MM.r...../.k	......^.........P.@.z.@3Z.q.1.-....a.s..+g.6k@.....U..0..Sd._.H..lU.Q.=f....&.@.P\......b..7./..?{..t.V).7..Ndz5x.+I-.....L..6.B......./m...X.A.003a\x02Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
0006\x01.
0000
<<<<<<<<<<<<<<<<<<<<<<<<<<<
```

#### git push

用 Wireshark 抓包看看 `git push` 过程：

![](https://img.alicdn.com/imgextra/i4/O1CN01N6XA251GnzEOtt5PY_!!6000000000668-2-tps-3654-440.png)

##### 第一次交互：引用发现

```
客户端发起引用发现请求
>>>>>>>>>>>>>>>>>>>>>>>>>>>
GET /5ed5e6f717b522454a36976e/Codeup-Demo.git/info/refs?service=git-receive-pack HTTP/1.1
>>>>>>>>>>>>>>>>>>>>>>>>>>>


服务端返回引用信息列表
<<<<<<<<<<<<<<<<<<<<<<<<<<<
001f# service=git-receive-pack
000000caf82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea refs/heads/develop.report-status report-status-v2 delete-refs side-band-64k quiet atomic ofs-delta push-options object-format=sha1 agent=git/2.28.0.agit.6.0
004961ee902744d1f5a480e607856d44b104602d6b13 refs/heads/feature/p3c_scan
...省略...
003c3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 refs/tags/v1.0
0000
<<<<<<<<<<<<<<<<<<<<<<<<<<<
```

引用发现交互和 `git clone` 是类似的，不同的地方是服务类型为 `git-receive-pack`，请求的 URL 为 `$GIT_URL/info/refs?service=git-receive-pack`。

##### 第二次交互：推送数据
```
客户端推送数据
>>>>>>>>>>>>>>>>>>>>>>>>>>>
POST /5ed5e6f717b522454a36976e/Codeup-Demo.git/git-receive-pack HTTP/1.1

00a5113cc207f5a226e066f1119b51e57e2b8fbd8e28 b4a87307c6b56064d623851fe018b94d25e68e13 refs/heads/master. report-status side-band-64k agent=git/2.24.3.(Apple.Git-128)0000PACK.........
x...K
.0.@.9E...L&3).x.|&.E[..=.......o.f.LJm.P.....(1..M$...s.P.#.....j%..3...tD.JD.jTR/-.%......;..c.!.Q.......\...Q0$.B.O...Q.y..{t......pj<0....'.....R....2....J.x...........`...v....m.f..9..R.R.	.t..g....x.+I-..K.,...+.LI5...;*....1.:.I.;.9...p.v.Bg
>>>>>>>>>>>>>>>>>>>>>>>>>>>


服务端返回成功
<<<<<<<<<<<<<<<<<<<<<<<<<<<
0030.000eunpack ok
0019ok refs/heads/master
00000000
<<<<<<<<<<<<<<<<<<<<<<<<<<<
```
第二次交互里，客户端发起的 POST 请求 URL 为：`$GIT_URL/git-receive-pack` ，其内容格式：


### git ssh 传输协议分析


ssh 是建立在tcp之上的。
最后协商成功之后，将会生成一个对称加密 会话密钥key 以及一个 会话ID ，在这里要特别强调，这个是对称加密密钥key，

### 总结

* 相对于 TCP 、 HTTP 、 Protobuf 等协议，Git 传输协议定义的比较随意，且扩展性和通用性比较差。不过仔细想想也没有问题，只要能保证正常传输 Git 数据包那就已经达到目的了。

* 上面讲了一堆的细节，实际上 Git 传输协议可以更简单的表述（ [@jiangxin](https://github.com/jiangxin) ）：
<div align="center">
<img src="https://img.alicdn.com/imgextra/i1/O1CN01R59KkQ265t7GvMW5U_!!6000000007611-2-tps-2506-1284.png" width="800" />
</div>

### 参考资料

* https://github.com/git/git/blob/master/Documentation/technical/http-protocol.txt
* https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols
* https://git-scm.com/book/en/v2/Git-Internals-Transfer-Protocols
* https://wangdoc.com/ssh/client.html
* https://github.com/gcla/termshark
* [Walkthrough: Decrypt SSL/TLS traffic (HTTPS and HTTP/2) in Wireshark](https://joji.me/en-us/blog/walkthrough-decrypt-ssl-tls-traffic-https-and-http2-in-wireshark/#:~:text=The%20second%20method%20to%20decrypt%20SSL%2FTLS%20packets%20is,generate%20TLS%20session%20keys%20out%20to%20that%20file.)
## Git 底层原理：传输协议分析（二）

### 目录

* [概要](#概要)
* [git 传输协议格式](#git-传输协议格式)
    - [ pkt-line 格式](#pkt-line-格式)
    - [side-band 格式](#side-band-格式)
    - [能力列表 capabilities list]()
    - [引用发现数据格式](#引用发现数据格式)
    - [git-upload-pack 数据流格式](#git-upload-pack-数据流格式)
    - [git-receive-pack 数据流格式](#git-receive-pack-数据流格式)
* [更多信息](#更多信息)
    - [git 支持 4 种交互协议](#git-支持-4-种交互协议)
    - [哑协议](#哑协议)
    - [protocol v2](#protocol-v2)
* [相关环境变量](#相关环境变量)
    - [GIT_TRACE_PACKET](#GIT-TRACE-PACKET)
    - [GIT_TRACE_PACKFILE](#GIT-TRACE-PACKFILE)
    - [GIT_TRACE_CURL](#GIT-TRACE-CURL)
* [相关命令](#相关命令)
    - [git-update-server-info](#git-update-server-info)
* [相关源码](#相关源码)
* [总结](#总结)
* [参考资料](#参考资料)

### 概要

工欲善其事，必先利其器。
上一篇文章讲了 git 传输协议的相关流程和要点，本文算上一篇文章的总结帖，涉及了传输协议格式、环境变量、子命令等，并附上了相关的源码说明。

### Git 传输协议格式

#### pkt-line 格式
pkt-line 数据流用来描述引用信息，每一行的前四个字节代表这一行的十六进制编码的长度，包括这四个字节和数据在内。因为包括自身四个字节，前四个直接一定大于0004，所以 pkt-line 格式定义了3个特殊的编码：
* _**0000**_ ( `flush-pkt` )：代表一段消息的结束。
* _**0001**_ ( `delim-pkt` )：代表一段消息的分节符。
* _**0002**_ ( `response-end-pkt` )：无状态会话时响应结束。

#### side-band 格式
side-band 格式用来传递 pack 包数据和进度的。前四个字节和 pkt-line 格式相同，代表这一行的数据长度。第五位用于标志消息类型，_`0x01`_ 代表是packfile 数据，_`0x02`_ 代表是进度消息，_`0x03`_ 代表是错误信息。

#### 引用发现数据格式
_`引用数据`_ 由服务端发送给客户端。整体来讲，一个 **引用数据格式** 一般由如下几部分组成：
```
PKT-LINE("# service=$servicename" LF)
"0000"
ref_list
"0000"
```

其中
* _`PKT-LINE`_ 代表这一行是 pkt-line 格式的。
* _`servicename`_ 是服务类型，git clone、git fetch 是 `git-upload-pack`，git push 则是 `git-receive-pack`。
* _`ref_list`_ 是引用信息列表，一定是按照引用名称排序的。

_`ref_list`_ 第一个引用一定是 `HEAD` ， `HEAD` 后面一定有支持的功能说明（ capability declarations ）第一条引用信息格式为：

```
PKT-LINE(obj-id SP name NUL cap_list LF)
```
> 其中 `cap_list` 是支持的功能列表（ capability list ）。

后面的引用信息格式为：

```
PKT-LINE(obj-id SP name LF)

# 或者
PKT-LINE(obj-id SP name LF)
PKT-LINE(obj-id SP name "^{}" LF)
```

> * 其中 `name^{}` 是 [git revision](https://git-scm.com/docs/gitrevisions ) 中定义的格式，表示递归该引用找到非 tag 类型的 object 。
> * 另外，如果该仓库没有引用时，那 `ref_list` 的内容则是：`PKT-LINE(zero-id SP "capabilities^{}" NUL cap-list LF)` 。

pkt-line 官方说明见：[http-protocol.txt](https://github.com/git/git/blob/master/Documentation/technical/http-protocol.txt#L163)。

#### git-upload-pack 数据流格式
_`git-upload-pack 请求数据`_ 由客户端发送给服务端，表示客户端需要（ _`"want"`_ ）哪些 `commit-id` ，同时也会说明自己有（ _`"have"`_ ）哪些 `commit-id`。git-upload-pack 请求数据格式相对简单，请求数据一定会有个 _`"want"`_ ，且第一条需要带上功能说明（ capability declarations ）：

```
PKT-LINE("want" SP obj-id SP cap_list LF)
PKT-LINE("want" SP obj-id LF)
PKT-LINE("want" SP obj-id LF)
"0000"
PKT-LINE("have" SP obj-id LF)
PKT-LINE("have" SP obj-id LF)
"0000" / PKT-LINE("done" LF)
```

_`git-upload-pack 回复数据`_由服务端回复给客户端，

#### git-receive-pack 数据流格式


### 更多信息
#### git 支持 4 种交互协议
Git 客户端和服务端交互的协议支持 4 种：`本地协议`、 `http 协议`、 `ssh 协议`、 `git 协议`，在我们的日常开发过程中，接触最多的是 `http 协议` 和 `ssh 协议` 。
根据 URL 的前缀可以知道使用的是什么协议： _`file://`_ 、 _`https://`_ 、 _`ssh://`_ 、 _`git://`_ 。通过如下命令和服务器进行交互：

```bash
# 本地协议
$ git clone /path/to/project.git
# 或者
$ git clone file:///path/to/project.git

# ssh 协议
$ git clone ssh://user@server/project.git
# 或者
$ git clone user@server:project.git

# http(s) 协议
$ git clone https://server/project.git
# 或者带上用户名密码
$ git clone https://user:token@server/project.git

# git 协议
$ git clone git://git/project.git
```
* `本地协议` 一般用于共享目录的开发模式，不过需要有文件系统访问权限，安全性不能保障。
* `git 协议` 默认使用 `9418` 端口，但是没有认证过程，数据传输过程也不加密，安全性也不能保障。

#### 哑协议
上面使用 Wireshark 抓取到的协议叫智能（ smart ）协议，实际上 Git 1.6.6 之前的版本（2010年前）一直使用哑（ Dumb ）协议。使用哑协议的版本库很难保证安全性和私有化，而且只能架设只读版本库，目前已经很少使用了，哑协议的交互过程可以参考《[Git Internals - Transfer Protocols](https://git-scm.com/book/en/v2/Git-Internals-Transfer-Protocols)》。

#### protocol v2

Git 目前已经有新的 [protocol v2](https://github.com/git/git/blob/master/Documentation/technical/protocol-v2.txt) 协议，支持更高阶的特性，比如能力广播、断电续传等。

### 相关环境变量

除了 `GIT_TRACE`用于查看 Git 运行日志，Git 还提供了几个非常有意思的环境变量用于查看和调试传输协议。

#### `GIT_TRACE`


#### `GIT_TRACE_PACKET`
`GIT_TRACE_PACKET=true`：显示协议交互数据，不过不会显示 PACK 包内容。输出的信息是经过格式化的，并不是原始数据，不过这个比较容易理解和阅读。

<div align="center">
<img src="https://img.alicdn.com/imgextra/i3/O1CN013WmZbH1vh1SLd3J3l_!!6000000006203-2-tps-2332-1480.png" width="800"/>
</div>

#### `GIT_TRACE_PACKFILE`
`GIT_TRACE_PACKFILE=<file-path>`：把协议交互中的 PACK 包保存到指定文件中，如果设置为 `GIT_TRACE_PACKFILE=true` ，那就显示在标准输出。

#### `GIT_TRACE_CURL`
显示 curl 交互信息，包括 `TLS` + `HTTP` + `Git 协议`，该数据和使用 Wireshark 抓到的信息基本相同。

<div align="center">
<img src="https://img.alicdn.com/imgextra/i2/O1CN01B3sjB41QkSKz32eGb_!!6000000002014-2-tps-2332-1480.png" width="800"/>
</div>

### 相关命令

#### git-update-server-info

该命令可以生成 `info/refs` 引用信息。

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

### 相关源码

### 参考资料

* https://github.com/git/git/blob/master/Documentation/technical/http-protocol.txt
* https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols
* https://git-scm.com/book/en/v2/Git-Internals-Transfer-Protocols
* https://wangdoc.com/ssh/client.html
* https://github.com/gcla/termshark
* [Walkthrough: Decrypt SSL/TLS traffic (HTTPS and HTTP/2) in Wireshark](https://joji.me/en-us/blog/walkthrough-decrypt-ssl-tls-traffic-https-and-http2-in-wireshark/#:~:text=The%20second%20method%20to%20decrypt%20SSL%2FTLS%20packets%20is,generate%20TLS%20session%20keys%20out%20to%20that%20file.)
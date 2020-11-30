# git 底层对象

> 本仓库里面的图片大部分都是引用自其它的文章 :smile: 。

从根本上来讲， Git 是一个内容寻址（content-addressable）文件系统，git 底层实际上是由一个个对象（object）组成的，git 的用户操作实际上是操作 git 底层对象。git 牛逼之处就是他提供了高度抽象且丰富的操作命令，让用户可以无感知实现非常自由的版本控制和工作流。

git 的底层对象分为4种：
* **blob 对象**：保存着文件快照。
* **tree 对象**：记录着目录结构和 blob 对象索引。
* **commit 对象**：包含着指向前述 tree 对象的指针和所有提交信息。
* **tag 对象**：记录tag。


<a name="j2PnP"></a>
### 查看object文件的内容
使用 `git cat-file` 可以查看 `object` 文件的内容，但是查看的内容是转换过的：
```bash
 $ git cat-file -p aa548c4d7910229712ba3a41e74c6db872e8ab64
100644 blob c30106543ed8f32af334362fa82e3a4ad71ef20f	home.md
```
可以使用 [zlib-flate](http://manpages.ubuntu.com/manpages/trusty/man1/zlib-flate.1.html) 命令解压看到真实内容：
```bash
$ zlib-flate -uncompress < .git/objects/aa/548c4d7910229712ba3a41e74c6db872e8ab64 | hexdump -C
00000000  74 72 65 65 20 33 35 00  31 30 30 36 34 34 20 68  |tree 35.100644 h|
00000010  6f 6d 65 2e 6d 64 00 c3  01 06 54 3e d8 f3 2a f3  |ome.md....T>..*.|
00000020  34 36 2f a8 2e 3a 4a d7  1e f2 0f                 |46/..:J....|
0000002b
```
> tree 对象 文件格式请看：[tree 对象](https://juejin.im/post/6874840619332665357#heading-16)。
> 需要安装 qpdf 才能正常使用 [zlib-flate](http://manpages.ubuntu.com/manpages/trusty/man1/zlib-flate.1.html) 命令：apt install qpdf 。


### 索引文件
索引文件默认路径为：`.git/index`。索引文件用来存储变更文件的相关信息，当运行 `git add` 命令时会添加变更文件的信息到索引文件中。

> 同时也有一个叫 `.git/index.lock` 的文件，该文件存在时表示当前工作区被锁定，无法进行提交操作。

使用 `hexdump` 命令可以查看到索引文件内容：
```
$ hexdump -C .git/index 
00000000  43 52 49 44 01 00 00 00  01 00 00 00 ae 73 c4 f2  |CRID.........s..|
00000010  ce 32 c9 6f 13 20 0d 56  9c e8 cf 0d d3 75 10 c8  |.2.o. .V.....u..|
00000020  94 ad 4c 5f f4 5c 42 06  94 ad 4c 5f f4 5c 42 06  |..L_.\B...L_.\B.|
00000030  00 03 01 00 91 16 d2 04  b4 81 00 00 ee 03 00 00  |................|
00000040  ee 03 00 00 0b 00 00 00  a3 f4 a0 66 c5 46 39 78  |...........f.F9x|
00000050  1e 30 19 a3 20 42 e3 82  84 ee 31 54 09 00 52 45  |.0.. B....1T..RE|
00000060  41 44 4d 45 2e 6d 64 00                           |ADME.md.|
```

`.git/index` 索引文件使用二进制存储相关内容，该文件由 **文件头 + 变更文件信息** 组成：
![image.png](https://img.alicdn.com/tfs/TB1T.NsZoz1gK0jSZLeXXb9kVXa-2526-1594.png)

<a name="NEN6x"></a>
### pack文件
pack文件用来合并压缩多个object对象的，可以方便进行网络传输（推送到远程仓库）。<br />`*.pack` 文件格式：<br />![image.png](https://ucc.alicdn.com/pic/developer-ecology/d6efb1160bf74b40887a74cf1ad43c16.png)
> 该图片来自于：[https://developer.aliyun.com/article/761663](https://developer.aliyun.com/article/761663) 。


<br />`*.idx` 文件格式：<br />![image.png](https://ucc.alicdn.com/pic/developer-ecology/941607f49ac44958876d511c5b831ed2.png)
> 该图片来自于：[https://developer.aliyun.com/article/761663](https://developer.aliyun.com/article/761663) 。


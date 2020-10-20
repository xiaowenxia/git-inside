# git 底层对象

<a name="UYXQf"></a>
## 底层原理
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



<a name="YOJoN"></a>
### 索引文件
索引文件格式为：<br />![image.png](https://img.alicdn.com/tfs/TB1T.NsZoz1gK0jSZLeXXb9kVXa-2526-1594.png)
> 详细说明请见：[源码解析：Git的第一个提交是什么样的 - 索引文件](https://juejin.im/post/6874840619332665357#heading-18)。



<a name="NEN6x"></a>
### pack文件
pack文件用来合并压缩多个object对象的，可以方便进行网络传输（推送到远程仓库）。<br />`*.pack` 文件格式：<br />![image.png](https://ucc.alicdn.com/pic/developer-ecology/d6efb1160bf74b40887a74cf1ad43c16.png)
> 该图片来自于：[https://developer.aliyun.com/article/761663](https://developer.aliyun.com/article/761663) 。


<br />`*.idx` 文件格式：<br />![image.png](https://ucc.alicdn.com/pic/developer-ecology/941607f49ac44958876d511c5b831ed2.png)
> 该图片来自于：[https://developer.aliyun.com/article/761663](https://developer.aliyun.com/article/761663) 。


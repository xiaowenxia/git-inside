## Git 底层原理：Git 底层文件存储格式

Git 底层文件有 Git 对象、索引文件、pack 文件、分支/引用、HEAD 指针等，
在[《Git 底层原理： Git 对象》](./git-internal.1.md)里面有讲解到，Git 是一个文件系统，最小单元是 Git 对象，Git 对象又分为 4 种：`blob`、`tree`、`commit`、`tag`，那这些对象具体是以什么形式存储的？

首先按照[《Git 底层原理： Git 对象》](./git-internal.1.md)里面提到的步骤初始化一个简单的 git 仓库，查看生成的 git 对象：

```bash
$ find .git/objects -type f | sort
.git/objects/03/2ddd9205d65abd773af1610038c764f46a0b12      # tag
.git/objects/10/da3741b6e365b6795335e1e2d3ed5820e794cd      # tree | 第二次提交
.git/objects/39/fb0fbcac51f66b514fbd589a5b2bc0809ce664      # tree: doc/ | 第二次提交
.git/objects/41/20b5f61a582cb12d4dcdaab71c7ef1862dbbca      # tree | 第一次提交
.git/objects/45/c7a584f300657dba878a542a6ab3b510b63aa3      # blob | changelog
.git/objects/52/3d41ce82ea993e7c7df8be1292b2eac84d4659      # commit | 第一次提交
.git/objects/56/64e303b5dc2e9ef8e14a0845d9486ec1920afd      # blob | README.md
.git/objects/6f/b38b7118b554886e96fa736051f18d63a80c85      # blob | 第一次提交 | file.txt
.git/objects/a0/e96b5ee9f1a3a73f340ff7d1d6fe2031291bb0      # commit | 第二次提交
.git/objects/ae/c2e48cbf0a881d893ccdd9c0d4bbaf011b5b23      # blob | 第二次提交 | file.txt
```

### Git 对象

为了减少存储大小，git 对象都是使用 [zlib](http://zlib.net/) 压缩存储的。git 对象由 `<type>` + `<size>` + `<content>` 组成：

- `<type>`: git 对象类型，有如下 4 种：`blob`、`tree`、`commit`、`tag`。
- `<size>`: git 对象的内容大小。
- `<content>`: git 对象内容。

如下是 4 种对象的数据存储格式：

![](https://img.alicdn.com/imgextra/i3/O1CN01Prj90h1qr21f8nMgE_!!6000000005548-2-tps-2060-1784.png)

这里可能会有人有疑惑，Git 对象并没有对自身数据做校验（checksum），这样会不会有人对数据进行修改？这个其实不用担心，所有的 Git 对象都会组成一个图（Graph），按照指向关系可以这么理解：`refs` --> `tag 对象 ` --> `commit 对象` --> `tree 对象` --> `blob 对象`（实际上更为复杂），对象之间通过对方的 sha1 值来确定指向关系，所以要是篡改了对象的内容，那指向关系就会被破坏掉，[`git fsck`](https://git-scm.com/docs/git-fsck) 命令就会提示 `"hash mismatch"`。

#### 查看对象存储格式

git 提供了 `cat-file` 来解析 git 对象，并输出格式化可阅读的内容：

```bash
# 查看对象内容
$ git cat-file -p 6fb38
100644 blob 5664e303b5dc2e9ef8e14a0845d9486ec1920afd	README.md
040000 tree 39fb0fbcac51f66b514fbd589a5b2bc0809ce664	doc
100644 blob aec2e48cbf0a881d893ccdd9c0d4bbaf011b5b23	file.txt

# 查看对象类型
$ git cat-file -t 6fb38
tree

#查看对象存储的内容大小
$ git cat-file -s 6fb38
103
```

同时，`cat-file` 也支持输出未格式化的内容：

```bash
# 查看未格式化的内容
$ git cat-file tree 10da374
100644 README.mdVd���.���E�Hn��
�40000 doc9���Q�kQO�X�[+����d100644 file.txt��䌿
��<���Ի�%
```

如果你想要不依赖 git 命令来查看 git 对象，可以使用 zlib 的一个解压工具：[zlib-flate](http://manpages.ubuntu.com/manpages/trusty/man1/zlib-flate.1.html) 来解压 git 对象，以 `file.txt` 第一次提交生成的 blob 对象 `6fb38b7` 为例：

```bash
$ zlib-flate -uncompress < .git/objects/6f/b38b7118b554886e96fa736051f18d63a80c85
blob 11git-inside
```

> 根据上面的 blob 存储格式可以知道，其中 `"blob"` 是对象类型，`"11"` 是文件大小，`"git-inside"` 是文件内容。

这里提供一下 4 种对象的原始数据，仅供参考：

```bash
# 查看 blob 对象内容
$ zlib-flate -uncompress < .git/objects/6f/b38b7118b554886e96fa736051f18d63a80c85
blob 11git-inside

# 查看 tree 对象内容，因为内容是二进制格式，这里使用 hexdump 格式化输出
$ zlib-flate -uncompress < .git/objects/10/da3741b6e365b6795335e1e2d3ed5820e794cd | hexdump -C
00000000  74 72 65 65 20 31 30 33  00 31 30 30 36 34 34 20  |tree 103.100644 |
00000010  52 45 41 44 4d 45 2e 6d  64 00 56 64 e3 03 b5 dc  |README.md.Vd....|
00000020  2e 9e f8 e1 4a 08 45 d9  48 6e c1 92 0a fd 34 30  |....J.E.Hn....40|
00000030  30 30 30 20 64 6f 63 00  39 fb 0f bc ac 51 f6 6b  |000 doc.9....Q.k|
00000040  51 4f bd 58 9a 5b 2b c0  80 9c e6 64 31 30 30 36  |QO.X.[+....d1006|
00000050  34 34 20 66 69 6c 65 2e  74 78 74 00 ae c2 e4 8c  |44 file.txt.....|
00000060  bf 0a 88 1d 89 3c cd d9  c0 d4 bb af 01 1b 5b 23  |.....<........[#|

# 查看 commit 对象内容
$ zlib-flate -uncompress < .git/objects/a0/e96b5ee9f1a3a73f340ff7d1d6fe2031291bb0
commit 220tree 10da3741b6e365b6795335e1e2d3ed5820e794cd
parent 523d41ce82ea993e7c7df8be1292b2eac84d4659
author xiaowenxia <775117471@qq.com> 1606913178 +0800
committer xiaowenxia <775117471@qq.com> 1606913178 +0800

second commit

# 查看 tag 对象内容
$ zlib-flate -uncompress < .git/objects/03/2ddd9205d65abd773af1610038c764f46a0b12
tag 148object a0e96b5ee9f1a3a73f340ff7d1d6fe2031291bb0
type commit
tag v0.0.2
tagger xiaowenxia <775117471@qq.com> 1606913178 +0800

this is annotated tag
```

> 这里使用到了 hexdump，[hexdump](https://www.man7.org/linux/man-pages/man1/hexdump.1.html) 是一个 UNIX 命令，用来格式化输出二进制数据。

### 索引文件

索引文件默认路径为：`.git/index`。索引文件用来存储暂存区的相关文件信息，当运行 `git add` 命令时会把工作区的变更文件信息添加到该索引文件中。索引文件以如下的格式存储暂存区内容：

![](https://img.alicdn.com/imgextra/i3/O1CN01IDu59O1U9auyFw6YI_!!6000000002475-2-tps-2414-1376.png)

> 读过源码的同学会发现，其实还有一个叫`.git/index.lock`的文件，该文件存在时表示当前工作区被锁定，代表有 git 进程正在操作该仓库。

#### 查看索引文件存储格式

使用 `ls-files` 可以读取索引文件存储的文件信息：

```bash
$ git ls-files --stage
100644 5664e303b5dc2e9ef8e14a0845d9486ec1920afd 0	README.md
100644 45c7a584f300657dba878a542a6ab3b510b63aa3 0	doc/changelog
100644 aec2e48cbf0a881d893ccdd9c0d4bbaf011b5b23 0	file.txt
```

当然，`ls-files` 的输出内容也是经过格式化的。跟 Git 对象 不一样，索引文件 `.git/indx` 并没有经过 zlib 压缩，使用 `hexdump` 工具就可以直接查看原始数据：

```
$ hexdump -C .git/index
00000000  44 49 52 43 00 00 00 02  00 00 00 03 5f cb 65 22  |DIRC........_.e"|
00000010  22 be 40 2c 5f cb 65 22  22 be 40 2c 01 00 00 04  |".@,_.e"".@,....|
00000020  01 3e 09 e3 00 00 81 a4  00 00 01 f6 00 00 00 14  |.>..............|
00000030  00 00 00 04 56 64 e3 03  b5 dc 2e 9e f8 e1 4a 08  |....Vd........J.|
00000040  45 d9 48 6e c1 92 0a fd  00 09 52 45 41 44 4d 45  |E.Hn......README|
00000050  2e 6d 64 00 5f cb 65 26  01 bd 63 4e 5f cb 65 26  |.md._.e&..cN_.e&|
00000060  01 bd 63 4e 01 00 00 04  01 3e 09 f4 00 00 81 a4  |..cN.....>......|
00000070  00 00 01 f6 00 00 00 14  00 00 00 07 45 c7 a5 84  |............E...|
00000080  f3 00 65 7d ba 87 8a 54  2a 6a b3 b5 10 b6 3a a3  |..e}...T*j....:.|
00000090  00 0d 64 6f 63 2f 63 68  61 6e 67 65 6c 6f 67 00  |..doc/changelog.|
000000a0  00 00 00 00 5f cb 65 1f  17 f9 45 e9 5f cb 65 1f  |...._.e...E._.e.|
000000b0  17 f9 45 e9 01 00 00 04  01 3e 08 92 00 00 81 a4  |..E......>......|
000000c0  00 00 01 f6 00 00 00 14  00 00 00 1a ae c2 e4 8c  |................|
000000d0  bf 0a 88 1d 89 3c cd d9  c0 d4 bb af 01 1b 5b 23  |.....<........[#|
000000e0  00 08 66 69 6c 65 2e 74  78 74 00 00 54 52 45 45  |..file.txt..TREE|
000000f0  00 00 00 35 00 33 20 31  0a 10 da 37 41 b6 e3 65  |...5.3 1...7A..e|
00000100  b6 79 53 35 e1 e2 d3 ed  58 20 e7 94 cd 64 6f 63  |.yS5....X ...doc|
00000110  00 31 20 30 0a 39 fb 0f  bc ac 51 f6 6b 51 4f bd  |.1 0.9....Q.kQO.|
00000120  58 9a 5b 2b c0 80 9c e6  64 ac 8f 88 7a 1e a4 d0  |X.[+....d...z...|
00000130  b9 83 8d 83 72 4e 7b 71  d2 d8 a0 a5 3d           |....rN{q....=|
```

索引文件大部分内容都是以二进制存储的，可读性很差，喜欢钻研的同学可以去看源码。

### pack 文件

pack 文件用来合并压缩多个 object 对象的，可以方便进行网络传输（推送到远程仓库）。<br />`*.pack` 文件格式：<br />![image.png](https://ucc.alicdn.com/pic/developer-ecology/d6efb1160bf74b40887a74cf1ad43c16.png)

> 该图片来自于：[https://developer.aliyun.com/article/761663](https://developer.aliyun.com/article/761663) 。

<br />`*.idx` 文件格式：<br />![image.png](https://ucc.alicdn.com/pic/developer-ecology/941607f49ac44958876d511c5b831ed2.png)

> 该图片来自于：[https://developer.aliyun.com/article/761663](https://developer.aliyun.com/article/761663) 。

### HEAD 等指针文件

HEAD 具体路径为 `.git/HEAD` ，`HEAD` 实际上是一个指针，指向具体的引用或者 `commit-id` ，比如 HEAD 指向 `master` 分支时是如下内容：

```bash
$ cat .git/HEAD
ref: refs/heads/master
```

如果 checkout 了一个特定的 `commit-id` 时，那 HEAD 的值是这个 `commit-id`。

```bash
$ git checkout 523d41ce82ea993e7c7df8be1292b2eac84d4659
$ cat .git/HEAD
523d41ce82ea993e7c7df8be1292b2eac84d4659
```

另外，如果我 checkout 了指定的 `tag` 时，那 HEAD 的值是这个 `tag` 对应的 `commit-id`。
同样的，`.git/ORIG_HEAD`、`.git/FETCH_HEAD` 也是这样的存储方式。

### 引用

Git 引用名义上是指针，实际上是一个很简单的文件，这个文件存储的是指向的提交的 `commit-id`：

```bash
$ cat .git/refs/heads/master
a0e96b5ee9f1a3a73f340ff7d1d6fe2031291bb0
```

### 附录

##### 相关的 Git 源码

> 基于 git v2.29.2 版本。

- Git 对象：
  - 写入 Git 对象源码： `sha1-file.c` > [`write_object_file()`](https://github.com/git/git/blob/v2.29.2/sha1-file.c#L1931)。
  - 读取 Git 对象源码： `sha1-file.c` > [`read_object_file_extended()`](https://github.com/git/git/blob/v2.29.2/sha1-file.c#L1621)
- 索引文件：
  - 解析 索引文件：`read-cache.c` > [`read_index_from`](https://github.com/git/git/blob/v2.29.2/read-cache.c#L2277)
  - 工作区锁定：[`lockfile.c`](https://github.com/git/git/blob/v2.29.2/lockfile.c)。

```c
/* 索引文件 header */
struct cache_header {
	uint32_t hdr_signature;
	uint32_t hdr_version;
	uint32_t hdr_entries;
};

/* 文件（entry）的存储格式 */
struct ondisk_cache_entry {
	struct cache_time ctime;
	struct cache_time mtime;
	uint32_t dev;
	uint32_t ino;
	uint32_t mode;
	uint32_t uid;
	uint32_t gid;
	uint32_t size;
	unsigned char data[GIT_MAX_RAWSZ + 2 * sizeof(uint16_t)];
	char name[FLEX_ARRAY];
};
```

### 参考资料

- https://stackoverflow.com/questions/14790681/what-is-the-internal-format-of-a-git-tree-object
- https://stackoverflow.com/questions/4084921/what-does-the-git-index-contain-exactly
- https://gist.github.com/masak/2415865
- https://linux.die.net/man/1/git-pack-objects

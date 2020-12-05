<h1 style="margin-top: 30px; margin-bottom: 15px; padding: 0px 100px; font-size: 22px; text-align: center; position: relative; font-weight: bold; color: black; line-height: 1.1em; padding-top: 12px; padding-bottom: 12px; margin: 70px 30px 30px; border: 1px solid #000; width: 60%; margin: 0 auto" data-id="heading-2"><span style="float: left; display: block; width: 60%; border-top: 1px solid #000; height: 1px; line-height: 1px; margin-left: -5px; margin-top: -17px;"> </span><span class="prefix" style="display: block; width: 3px; margin: 0 0 0 5%; height: 3px; line-height: 3px; overflow: hidden; background-color: #000; box-shadow: 3px 0 #000, 0 3px #000, -3px 0 #000, 0 -3px #000;"></span><span class="content" style="display: block; -webkit-box-reflect: below 0em -webkit-gradient(linear,left top,left bottom, from(rgba(0,0,0,0)),to(rgba(255,255,255,0.1)));">Git 底层原理：Git 对象</span><span class="suffix" style="display: block; width: 3px; margin: 0 0 0 95%; height: 3px; line-height: 3px; overflow: hidden; background-color: #000; box-shadow: 3px 0 #000, 0 3px #000, -3px 0 #000, 0 -3px #000;"></span><span style="float: right; display: block; width: 60%; border-bottom: 1px solid #000; height: 1px; line-height: 1px; margin-right: -5px; margin-top: 16px;"> </span></h1>
<br />

> 了解 git 内部原理其实很有用，比如意外删除了分支怎么办？如何更改历史提交记录？二进制大文件占用太多磁盘空间怎么清理等等。

git 实际上是一个内容文件系统，载体是 git 的对象，存储的是一个个的内容版本。git 仓库就像一个书架，书架上放着的是一本本书，对于 git 来讲，这一本本书就是 git 对象，存储的是书的每一个版本的内容。

Git 对象 是 Git 的最小组成单位，git 的所有核心底层命令实际上都是在操作 git 对象。比如 git add 命令，就是把文件快照存储成 `blob` 对象，`git commit` 命令，就是把提交的文件列表和提交信息分别存储成 `tree` 对象和 `commit` 对象，`git checkout -b`创建分支命令，就是创建一个指针指向 `commit` 对象。

本文会从一个空的仓库开始，一步一步讲解 git 的底层对象和内部原理。


### <span style="color: #41B883; border-left:4px solid #41B883; padding-left: 5px; padding-right: 5px">0x01</span> 首先初始化工程
```bash
# 初始化工程
$ git init
Initialized empty Git repository in /Users/xxx/workspace/git-inside/.git/
# 查看目录结构
$ tree -a
└── .git
    ├── HEAD
    ├── config
    ├── description
    ├── hooks
    │   ├── applypatch-msg.sample
    │   ├── ......                  # 省略
    │   └── update.sample
    ├── info
    │   └── exclude
    ├── objects
    │   ├── info
    │   └── pack
    └── refs
        ├── heads
        └── tags
```

git 初始化时，实际上是在仓库下创建了一个 `.git` 目录的隐藏目录，以及一些默认的文件：
* `HEAD`: `HEAD` 指针，指向当前的操作分支。
* `config`: 存储的本地仓库的配置。
* `description`: 用来存储仓库名称以及仓库的描述信息。
* `hooks/*`: git 钩子，git 钩子可以做非常有用的事情，也是构建 git 工作流中不可或缺的部分。具体看 [git 钩子](https://git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E9%92%A9%E5%AD%90)。
* `info/exclude`: 该文件的功能和 [.gitignore](https://git-scm.com/docs/gitignore) 一样，都是配置 git 忽略本地文件。
* `objects/*`: git 的底层对象。
* `refs/heads` 和 `refs/tags` : git 引用，实现了git 的分支策略，具体看 [git 引用](https://git-scm.com/book/en/v2/Git-Internals-Git-References)。

### <span style="color: #41B883; border-left:4px solid #41B883; padding-left: 5px; padding-right: 5px">0x02</span> 添加一个文件

使用 `git add` 命令把当前工作区的变更提交到暂存区：
```bash
# 添加文件
$ echo "git-inside" > file.txt

# 把文件添加到暂存区中
$ git add file.txt
```
此时查看 `.git/` 工作目录：

```bash
$ tree .git/objects
.git/objects
├── 6f
│   └── b38b7118b554886e96fa736051f18d63a80c85
├── info
└── pack
```

可以看到新生成了一个 git 对象，路径为`.git/objects/6f/b38b7118b554886e96fa736051f18d63a80c85`。
> git 对象的文件路径和名称根据文件内容的 [sha1](https://en.wikipedia.org/wiki/SHA-1) 值决定，取 sha1 值的第一个字节的 hex 值为目录，其他字节的 hex 值为名称。

为了减少存储大小，git 对象都是使用 [zlib](http://zlib.net/) 压缩存储的。git 提供了 [cat-file](https://git-scm.com/docs/git-cat-file) 命令用来格式化查看 git 对象内容：

```bash
# 查看 git 对象内容
$ git cat-file -p 6fb38b7118b554886e96fa736051f18d63a80c85
git-inside
# 查看 git 对象类型
$ git cat-file -t 6fb38b7118b554886e96fa736051f18d63a80c85
blob
```
可以看到 `6fb38b7`（上述 git 对象的 sha1 值简写） 对象类型为 `blob` 对象，`blob` 对象存储变更文件的内容快照。
> 根据 sha1 的散列特性，使用 sha1 的前 7 个字符就基本可以表示该 sha1 值。Github、Gitlab 也一样。

此时查看 `.git/` 目录下，会新增一个 index 文件（索引文件）：
```bash
$ file .git/index
.git/index: Git index, version 2, 1 entries
```
`index` 文件存储暂存区的文件列表，`index`文件代表了 git 的一个重要的概念：暂存区。`index` 文件的详细说明可以查看 [索引文件](https://github.com/xiaowenxia/git-first-commit#%E7%B4%A2%E5%BC%95%E6%96%87%E4%BB%B6) 。
`index` 文件使用二进制方式存储暂存区信息，通过 git 提供的 [ls-files](https://git-scm.com/docs/git-ls-files) 底层命令可以查看索引文件的格式化输出：

```bash
$ git ls-files -t
H file.txt
```

> 有兴趣的同学可以使用 `hexdump -C` 命令查看索引文件的二进制内容。

### <span style="color: #41B883; border-left:4px solid #41B883; padding-left: 5px; padding-right: 5px">0x03</span> 提交到本地版本库

使用 `git commit` 命令可以把暂存区的变动提交到本地版本库中：

```bash
$ git commit -m "first commit"
[master (root-commit) 523d41c] first commit
 1 file changed, 1 insertion(+)
 create mode 100644 file.txt
```

> 其中 `100644` 是指的文件模式，`100644` 表明这是一个普通文件。 其他情况比如 `100755` 表示可执行文件，`120000` 表示符号链接。

查看 `.git/objects` 目录下，会新增 2 个 git 对象：

```bash
$  tree .git/objects
.git/objects
├── 41
│   └── 20b5f61a582cb12d4dcdaab71c7ef1862dbbca
├── 52
│   └── 3d41ce82ea993e7c7df8be1292b2eac84d4659
├── 6f
│   └── b38b7118b554886e96fa736051f18d63a80c85
├── info
└── pack
```
分别是 `523d41c` 和 `4120b5f` 。

使用 `git cat-file` 可以看到 2 个 对象的类型和内容：
```bash
# 523d41c 是一个 commit 对象
$ git cat-file -t 523d41c
commit
$ git cat-file -p 523d41c
tree 4120b5f61a582cb12d4dcdaab71c7ef1862dbbca
author xiaowenxia <775117471@qq.com> 1606913178 +0800
committer xiaowenxia <775117471@qq.com> 1606913178 +0800

first commit

# 4120b5f 是一个 tree 对象
$ git cat-file -t 4120b5f
commit
$ git cat-file -p 4120b5f
100644 blob 6fb38b7118b554886e96fa736051f18d63a80c85	file.txt
```

> 也可以使用 `git cat-file -p 523d41c^{tree}` 来查看 `4120b5f` 的内容，`523d41c^{tree}` 和 `4120b5f` 是等效的，更多请查看 [git revisions](https://git-scm.com/docs/gitrevisions)。

这里新出现了 2 种新的 git 对象类型，分别是 `tree` 对象（`523d41c`） 和 `commit` 对象（`4120b5f`），tree 对象用来记录目录结构和 blob 对象索引，commit 对象包含着指向前述 tree 对象的指针和所有提交信息。

操作到这里，git 的底层对象一共生成了 3 个，分别是：

* `6fb38b7`: blob 对象。
* `4120b5f`: tree 对象，指向 `6fb38b7`。
* `523d41c`: commit 对象，指向 `4120b5f`。

他们之间的关系是：
![](https://img.alicdn.com/tfs/TB1UzBK4XP7gK0jSZFjXXc5aXXa-1818-608.png)

### <span style="color: #41B883; border-left:4px solid #41B883; padding-left: 5px; padding-right: 5px">0x04</span> 提交第二个版本

我们继续提交代码和文件：

```bash
$ echo "append content" > file.txt
$ echo "git" > README.md
$ mkdir doc && echo "v0.0.1" > changelog
$ git add -A
$ git commit -m "second commit"
[master 17036d5] second commit
 3 files changed, 3 insertions(+)
 create mode 100644 README.md
 create mode 100644 doc/changelog
```
该提交为 `file.txt` 添加了内容，同时新增了子目录：`doc/`，并新增了 `README.md` 和 `doc/changelog` 2个文件。
查看 git 对象列表：

```bash
$ tree .git/objects
.git/objects
├── 10
│   └── da3741b6e365b6795335e1e2d3ed5820e794cd      # tree | 第二次提交
├── 17
│   └── 036d5689723955d2be5d34a2cc85cb316975ce      # commit | 第二次提交
├── 39
│   └── fb0fbcac51f66b514fbd589a5b2bc0809ce664      # tree | 第二次提交
├── 41
│   └── 20b5f61a582cb12d4dcdaab71c7ef1862dbbca      # tree | 第一次提交
├── 45
│   └── c7a584f300657dba878a542a6ab3b510b63aa3      # blob | changelog
├── 52
│   └── 3d41ce82ea993e7c7df8be1292b2eac84d4659      # commit | 第一次提交
├── 56
│   └── 64e303b5dc2e9ef8e14a0845d9486ec1920afd      # blob | README.md
├── 6f
│   └── b38b7118b554886e96fa736051f18d63a80c85      # blob | 第一次提交 | file.txt
├── ae
│   └── c2e48cbf0a881d893ccdd9c0d4bbaf011b5b23      # blob | 第二次提交 | file.txt
├── info
└── pack
```

可以看到除了原先的 `6fb38b7`、`4120b5f`、`523d41c`，又新增了：
* `10da374`: tree 对象，指向 `README.md` ( `5664e30` ) 、`file.txt` ( `aec2e48` )、`doc/` ( `39fb0fb` )。
* `17036d5`: commit 对象，指向 `10da374`、`523d41c`。
* `39fb0fb`：tree 对象，指向 `changelog` ( `45c7a58` )。
* `45c7a58`: blob 对象， 存储 `changelog` 内容快照。
* `5664e30`: blob 对象，存储 `README.md` 内容快照。
* `aec2e48`: blob 对象，存储更改的 `file.txt` 内容快照。

查看新增的 2 个 tree 对象：

```bash
$ git cat-file -p 10da374
100644 blob 5664e303b5dc2e9ef8e14a0845d9486ec1920afd	README.md
040000 tree 39fb0fbcac51f66b514fbd589a5b2bc0809ce664	doc
100644 blob aec2e48cbf0a881d893ccdd9c0d4bbaf011b5b23	file.txt

$ git cat-file -p 39fb0fb
100644 blob 45c7a584f300657dba878a542a6ab3b510b63aa3	changelog
```

这里有必要说明一下，Git 使用 tree 对象来存储目录结构，不同的目录对应不同的 tree 对象，这次提交里面，顶层目录对应的 tree 是 `10da374`，`doc/` 目录对应的 tree 是 `39fb0fb`。

继续查看 commit 对象 `17036d5` 内容：

```bash
$ git cat-file -p 17036d5
tree 10da3741b6e365b6795335e1e2d3ed5820e794cd
parent 523d41ce82ea993e7c7df8be1292b2eac84d4659
author xiaowenxia <775117471@qq.com> 1607008935 +0800
committer xiaowenxia <775117471@qq.com> 1607008935 +0800

second commit
```

仔细的同学会发现，`17036d5` 跟第一次提交生成的 commit 对象（`523d41c`）相比，多了一个 `parent` 字段。`parent` 字段是用来指向上一次提交的，一般是1个 parent ，有些情况下会是多个 parent ，比如 merge 这种情况。

我们再总结一下这些对象之间的关系：
![](https://img.alicdn.com/tfs/TB11Phx4aL7gK0jSZFBXXXZZpXa-1928-1174.png)

如图所示，每一次提交可以是一个文件，也可以是多个文件和多个目录，一次提交就是一次版本（ [revision](https://git-scm.com/docs/gitrevisions) ）。
同时这里又引申出来了 git 的一个非常重要的概念，每一次新的提交都会指向上一个提交，这样多个提交就组成了一个提交链。这个提交链使用到了一个非常有名的算法：[merkle tree](https://baike.baidu.com/item/%E6%A2%85%E5%85%8B%E5%B0%94%E6%A0%91/22456281)，感兴趣的同学可以去深入了解，这里就不深入讲解了。`merkle tree` 有一个重要的特性就是单独更改其中一个节点的内容就会破坏掉这个tree，也就是说 `merkle tree` 的节点是不可更改的。git 就是通过 `merkle tree` 来保证每个版本都是连续有效的。
> 这就是为什么很难修改 git 的历史提交记录的原因，如果要修改某一个提交，那同时还需要修改这个提交之后的所有提交，这样才能保证 `merkle tree` 是有效成立的。
> 另外，区块链也是基于 `merkle tree` 来保证数据可靠性的。

可以猜想一下，如果继续提交代码，那 git 对象会是如下的关系：

![](https://img.alicdn.com/tfs/TB10t4y4oY1gK0jSZFMXXaWcVXa-2148-1366.png)

按照先后时间顺序单独看 `commit` 对象之间的关系：

<div align="center"><img src="https://img.alicdn.com/tfs/TB1afJx4oY1gK0jSZFCXXcwqXXa-500-216.png" width=200 /></div> 

这个 `commit` 对象关系图非常重要，git 分支策略就是围绕着这个关系图来运作的，这里暂且不做展开。

### <span style="color: #41B883; border-left:4px solid #41B883; padding-left: 5px; padding-right: 5px">0x05</span> 打标签

上面的操作涉及了 3 种 git 对象，分别是 `blob`、`tree`、`commit` 对象，其实 git 还存在一个 `tag` 类型的对象，用来存储带注释的标签。
使用如下命令创建标签：
```bash
$ git tag "v0.0.2" -m "this is annotated tag"

# 查看 git 对象 和 引用
$ tree .git/objects .git/refs
.git/objects
├── 10
│   └── da3741b6e365b6795335e1e2d3ed5820e794cd      # tree | 第二次提交
├── 17
│   └── 036d5689723955d2be5d34a2cc85cb316975ce      # commit | 第二次提交
├── 39
│   └── fb0fbcac51f66b514fbd589a5b2bc0809ce664      # tree | 第二次提交
├── 41
│   └── 20b5f61a582cb12d4dcdaab71c7ef1862dbbca      # tree | 第一次提交
├── 45
│   └── c7a584f300657dba878a542a6ab3b510b63aa3      # blob | changelog
├── 52
│   └── 3d41ce82ea993e7c7df8be1292b2eac84d4659      # commit | 第一次提交
├── 56
│   └── 64e303b5dc2e9ef8e14a0845d9486ec1920afd      # blob | README.md
├── 5c
│   └── d9a3bcc12a1cf3bd47ab9c7c426e51aad0f30a      # tag
├── 6f
│   └── b38b7118b554886e96fa736051f18d63a80c85      # blob | 第一次提交 | file.txt
├── ae
│   └── c2e48cbf0a881d893ccdd9c0d4bbaf011b5b23      # blob | 第二次提交 | file.txt
├── info
└── pack
.git/refs
├── heads
│   └── master
└── tags
    └── v0.0.2                                      # tag 引用
```

此时新增了一个 `5cd9a3b` 的对象，同时在 `.git/refs/` 中增加了名为 `v0.0.2` 的标签。使用如下命令查看他们的内容：

```bash
# 查看 v0.0.2 的内容
$ cat .git/refs/tags/v0.0.2
5cd9a3bcc12a1cf3bd47ab9c7c426e51aad0f30a

# 查看 5cd9a3b 的类型
$ git cat-file -t 5cd9a3b
tag

# 查看 5cd9a3b 的内容
$ git cat-file -p 5cd9a3b
object 17036d5689723955d2be5d34a2cc85cb316975ce
type commit
tag v0.0.2
tagger xiaowenxia <775117471@qq.com> 1607012401 +0800

this is annotated tag
```

`.git/refs/tags/v0.0.2` 是 Git 的一个重要的概念：[引用](https://git-scm.com/book/en/v2/Git-Internals-Git-References)。这个引用实际上是一个指针，内容为 `5cd9a3b` 的 sha1 值，代表指向 `5cd9a3b` 。而 `5cd9a3b` 是一个 tag 对象，指向第二次提交的 commit 对象：`17036d5`。

tag 对象相对比较独立，不参与构建文件系统，只是单纯的存储信息。

### <span style="color: #41B883; border-left:4px solid #41B883; padding-left: 5px; padding-right: 5px">0xFF</span> 总结

到这里其实应该已经 Git 底层对象有一个深刻的了解了。从根本上来讲，git 底层实际上是由一个个对象（object）组成的，git 底层对象分为4种：
* **blob 对象**：保存着文件快照，数据结构参考： [blob 对象](https://github.com/xiaowenxia/git-first-commit#blob-%E5%AF%B9%E8%B1%A1)。
* **tree 对象**：记录着目录结构和 blob 对象索引，其数据结构参考： [tree 对象](https://github.com/xiaowenxia/git-first-commit#tree-%E5%AF%B9%E8%B1%A1)。
* **commit 对象**：包含着指向前述 tree 对象的指针和所有提交信息，数据结构参考：[commit 对象](https://github.com/xiaowenxia/git-first-commit#commit-%E5%AF%B9%E8%B1%A1)。
* **tag 对象**：记录带注释的 tag 。

git 擅长的一点是提供了很多丰富抽象的子命令来操作这些 git 对象，比如上面的一系列操作：

* `git add`：实际上是把当前工作区的文件快照保存下来，产出是 blob 对象。
* `git commit`：保存暂存区的文件层级关系和提交者信息，产出是 tree 对象 和 commit 对象。
* `git tag -m`：保存 tag 标签的信息，产出是 tag 对象。

这些是上层命令，实际上 git 还提供了非常丰富的底层命令：
* [`git-hash-object`](https://git-scm.com/docs/git-hash-object)：把输入内容存储成 blob 对象。
* [`git-cat-file`](https://git-scm.com/docs/git-cat-file)：读取并格式化输出对象。
* [`git-count-objects`](https://git-scm.com/docs/git-count-objects)：计算对象数量。
* [`git-write-tree`]()：把存储区的文件结构存储成 tree 对象。
* [`git-read-tree`](https://git-scm.com/docs/git-read-tree)：把 tree 对象读取到暂存区。
* [`git-commit-tree`](https://git-scm.com/docs/git-commit-tree)：根据输入信息（tree、父提交、author、commiter、日期等）存储成 commit 对象。
* [`git-ls-tree`](https://git-scm.com/docs/git-ls-tree)：读取并格式化输出 tree 对象。

最后，我们用一张图来总结上述的一系列步骤生成的对象之间的关系：

![](https://img.alicdn.com/tfs/TB1LrGcoIieb18jSZFvXXaI3FXa-2880-1390.png)

### 参考资料
* https://git-scm.com/book/en/v2/Git-Internals-Git-Objects
* https://maryrosecook.com/blog/post/git-from-the-inside-out
* https://matthew-brett.github.io/curious-git/git_object_types.html
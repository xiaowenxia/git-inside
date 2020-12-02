## git 内部原理
了解 git 内部原理其实很有用，比如意外删除了分支怎么办？二进制大文件占用太多磁盘空间怎么清理等等。

git 实际上是一个内容文件系统，载体是 git 的对象，存储的是一个个的内容版本。git 仓库就像一个书架，书架上放着的是一本本书，对于 git 来讲，这一本本书就是 git 对象，存储的是书的每一个版本的内容。

![](https://www.zz101z.com/uploads/2019/0328/5c9c305b11a44.jpg)

git 的所有核心底层命令实际上都是在操作 git 对象。比如 git add 命令，就是把文件快照存储成 `blob` 对象，`git commit` 命令，就是把提交信息存储成 `tree` 对象，`git checkout -b`创建分支命令，就是创建一个指针指向 `commit` 对象。

本文一步一步讲解 git 的内部实现原理。

<blockquote>
<p>不知道各位有没有体会，总感觉之前的代码写的很 low 逼，想抽点空来折腾折腾自己还是很有乐趣的。<strong>重构还是很有乐趣的</strong>。手工狗头镇楼！</p>
</blockquote>


<div>
<pre data-tool="mdnice编辑器" style="margin-top: 10px;margin-bottom: 10px;border-radius: 5px;" data-darkmode-color-16069084740659="rgb(163, 163, 163)" data-darkmode-original-color-16069084740659="rgb(0,0,0)"><span style="display: block;background: url(&quot;https://img.alicdn.com/tfs/TB1oxKyosieb18jSZFvXXaI3FXa-450-130.png&quot;) 10px 10px / 40px no-repeat rgb(40, 44, 52);height: 30px;width: 100%;margin-bottom: -7px;border-radius: 5px;" data-darkmode-color-16069084740659="rgb(0,0,0)" data-darkmode-original-color-16069084740659="rgb(0,0,0)" data-darkmode-bgimage-16069084740659="1" class="js_darkmode__bg__0 js_darkmode__28" data-style="display: block; background: url(&quot;https://img.alicdn.com/tfs/TB1oxKyosieb18jSZFvXXaI3FXa-450-130.png&quot;) 10px 10px / 40px no-repeat rgb(40, 44, 52); height: 30px; width: 100%; margin-bottom: -7px; border-radius: 5px;"></span><code style="overflow-x: auto;padding: 16px;color: #abb2bf;display: -webkit-box;font-family: Operator Mono, Consolas, Monaco, Menlo, monospace;font-size: 12px;-webkit-overflow-scrolling: touch;padding-top: 15px;background: #282c34;border-radius: 5px;" data-darkmode-color-16069084740659="rgb(171, 178, 191)" data-darkmode-original-color-16069084740659="rgb(171, 178, 191)" data-darkmode-bgcolor-16069084740659="rgb(49, 54, 63)" data-darkmode-original-bgcolor-16069084740659="rgb(40, 44, 52)" data-style="overflow-x: auto; padding: 15px 16px 16px; color: rgb(171, 178, 191); display: -webkit-box; font-family: &quot;Operator Mono&quot;, Consolas, Monaco, Menlo, monospace; font-size: 12px; background: rgb(40, 44, 52); border-radius: 5px;" class="js_darkmode__29">所有符合征文活动要求的参与文章，都将获得「&nbsp;掘金首页热门推荐」，更有机会获得掘金官方微博、微信公众号等渠道推荐，让更多用户可以看到你的文章。<br data-darkmode-color-16069084740659="rgb(171, 178, 191)" data-darkmode-original-color-16069084740659="rgb(171, 178, 191)" data-darkmode-bgcolor-16069084740659="rgb(49, 54, 63)" data-darkmode-original-bgcolor-16069084740659="rgb(40, 44, 52)"></code></pre>
</div>


<h3 style="color: inherit;line-height: inherit;padding: 0px;margin: 1.6em 0px;font-weight: bold;border-bottom: 2px solid rgb(65, 105, 225);font-size: 1.3em;" data-darkmode-color-16069092717197="rgb(163, 163, 163)" data-darkmode-original-color-16069092717197="rgb(62, 62, 62)"><span style="font-size: inherit;line-height: inherit;margin: 0px;display: inline-block;font-weight: normal;background: rgb(65, 105, 225);color: rgb(255, 255, 255);padding: 3px 10px 1px;border-top-right-radius: 3px;border-top-left-radius: 3px;margin-right: 3px;" data-darkmode-color-16069092717197="rgb(255, 255, 255)" data-darkmode-original-color-16069092717197="rgb(255, 255, 255)" data-darkmode-bgcolor-16069092717197="rgb(65, 105, 225)" data-darkmode-original-bgcolor-16069092717197="rgb(65, 105, 225)">CPU 如何选择线程的？</span><span style="display: inline-block;vertical-align: bottom;border-bottom: 36px solid rgb(239, 235, 233);border-right: 20px solid transparent;" data-darkmode-color-16069092717197="rgb(163, 163, 163)" data-darkmode-original-color-16069092717197="rgb(62, 62, 62)" data-style="display: inline-block; vertical-align: bottom; border-bottom: 36px solid rgb(239, 235, 233); border-right: 20px solid transparent;" class="js_darkmode__18"> </span></h3>
##### 0x01: 首先初始化工程
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

9 directories, 16 files
```

git 初始化时，实际上是在仓库下创建了一个 `.git` 目录的隐藏目录，以及一些默认的文件：
* `HEAD`: `HEAD` 指针，指向当前的操作分支，具体看 [HEAD](./git-refs.md#HEAD)。
* `config`: 存储的本地仓库的配置，具体看 [git 的配置说明](./git-config.md)。
* `description`: `description` 用来存储仓库名称以及仓库的描述信息。具体看 [./git/description](./git-internal-files.md#.git/description)。
* `hooks/*`: git 钩子，git 钩子可以做非常有用的事情，也是git 工作流中不可或缺的部分。具体看 [git 钩子](./git-hooks.md)。
* `info/exclude`: 该文件的功能和 [.gitignore](./git-internal-files.md#.gitignore) 一样，都是配置 git 忽略本地文件。
* `objects/*`: git 的底层对象，具体看 [git 底层对象](./git-internal-objects.md)。
* `refs/heads` 和 `refs/tags` : git 引用，实现了git 的分支策略，具体看 [git 引用](./git-refs.md)。

##### 0x02: 添加一个文件
使用 `git add` 命令把当前工作区的变更提交到暂存区：
```bash
# 添加文件
$ date > file.txt
# 把文件添加到版本系统中
$ git add file.txt
```
此时查看 `.git/` 工作目录：

```bash
$ tree .git/objects
.git/objects
├── 03
│   └── a2c367f71427facbc39e40a274ccef13c735e7
├── info
└── pack
```

可以看到新生成了一个 git 对象，路径为`.git/objects/03/a2c367f71427facbc39e40a274ccef13c735e7`。
> git 对象的文件路径和名称根据文件内容的 [sha1](https://en.wikipedia.org/wiki/SHA-1) 值决定，取 sha1 值的第一个字节的 hex 值为目录，其他字节的 hex 值为名称。

为了减少存储大小，git 对象都是使用 [zlib](http://zlib.net/) 压缩存储的。git 对象的详细说明可以参考这里：[git 对象](./git-internal-objects.md) 。git 提供了 [cat-file](./git-internal-commands.md#git-cat-file) 命令用来格式化查看 git 对象内容：

```bash
# 查看 git 对象内容
$ git cat-file -p 03a2c367f71427facbc39e40a274ccef13c735e7
2020年11月29日 星期日 17时19分27秒 CST
# 查看 git 对象类型
$ git cat-file -t 03a2c367f71427facbc39e40a274ccef13c735e7
blob
```
可以看到：
* `03a2c36`（上述 git 对象的 sha1 值简写） 对象类型为 `blob` 对象，`blob` 对象存储变更文件的内容快照。
* `03a2c36` 对象内容为 `file.txt` 的文件内容。
> 根据 sha1 的散列特性，使用 sha1 的前 7 个字符就基本可以表示该 sha1 值。Github、Gitlab 也是这么表示的。

#### 0x03: 索引文件
此时查看 `.git/` 目录下，会新增一个 index 文件（索引文件）：
```bash
$ file .git/index
.git/index: Git index, version 2, 1 entries
```
`index` 文件存储暂存区的文件列表，`index`文件代表了 git 的一个重要的概念：暂存区，`index` 文件的详细说明可以查看 [索引文件](./git-internal-objects.md#索引文件) 。
`index` 文件使用二进制方式存储暂存区信息，通过 git 提供的 [ls-file](./git-internal-commands.md#git-ls-files) 底层命令可以查看索引文件的格式化输出：

```bash
$ git ls-files -t
H file.txt
```

> 其中 `H` 代表是新文件。
> 有兴趣的同学可以使用 `hexdump -C` 命令查看索引文件的二进制内容。

#### 0x04: 提交到本地版本库

使用 `git commit` 命令可以把暂存区的变动提交到本地版本库中：

```bash
$ git commit -m "first commit"
[master (root-commit) dcc0bad] first commit
 1 file changed, 1 insertion(+)
 create mode 100644 file.txt
```

查看 `.git/objects` 目录下，会新增 2 个 git 对象：

```bash
.git/objects
├── 03
│   └── a2c367f71427facbc39e40a274ccef13c735e7
├── 38
│   └── 3853c60d5ded795357557a370b49812f1b2f66
├── dc
│   └── c0badca8c9af73f7180ed73b649f7d26992f96
├── info
└── pack
```
分别是 `383853c` 和 `dcc0bad` 。

使用 `git cat-file` 可以看到 2 个 对象的类型和内容：
```bash
$ git cat-file -t 383853c
tree
$ git cat-file -p 383853c
100644 blob 03a2c367f71427facbc39e40a274ccef13c735e7	file.txt

$ git cat-file -t dcc0bad
commit
$ git cat-file -p dcc0bad
tree 383853c60d5ded795357557a370b49812f1b2f66
author xiaowenxia <775117471@qq.com> 1606645217 +0800
committer xiaowenxia <775117471@qq.com> 1606645217 +0800

first commit
```
这里新出现了 2 种新的 git 对象类型，分别是 `tree` 对象 和 `commit` 对象，tree 对象用来记录目录结构和 blob 对象索引，commit 对象包含着指向前述 tree 对象的指针和所有提交信息。
# vscode 的版本管理都用了哪些 git 命令

<a name="QGQSf"></a>

## vscode 打开一个代码库时，或者点击刷新时

```bash
[2022-07-29T09:51:41.593Z] > git status -z -uall [49ms]
[2022-07-29T09:51:41.602Z] > git symbolic-ref --short HEAD [5ms]
[2022-07-29T09:51:41.612Z] > git for-each-ref --format=%(refname)%00%(upstream:short)%00%(objectname)%00%(upstream:track)%00%(upstream:remotename)%00%(upstream:remoteref) refs/heads/master refs/remotes/master [7ms]
[2022-07-29T09:51:41.624Z] > git remote --verbose [5ms]
[2022-07-29T09:51:41.625Z] > git for-each-ref --sort -committerdate --format %(refname) %(objectname) %(*objectname) [10ms]
[2022-07-29T09:51:41.638Z] > git config --get commit.template [4ms]
```

<a name="yXzz6"></a>

### git rev-parse --show-toplevel

显示 work tree 的绝对路径，也就是你的本地代码的路径。

```bash
$ git rev-parse --show-toplevel
/Users/xxw/workspace/aone/agit/git
```

<a name="p3jiX"></a>

### git rev-parse--git-dir --git-common-dir

显示代码库的路径，一般情况下，代码库路径都是 .git 这个隐藏目录，当然这个目录也是可以配置的。

```bash
$ git rev-parse --git-dir --git-common-dir
.git
.git
```

<a name="Qfu3W"></a>

### git status -z -uall

获取当前工作目录与版本库的差异。<br />[git status](https://git-scm.com/docs/git-status) 是用于展示当前 worktree 跟版本的差异的，`--uall` 代表同时输出不在版本库的文件差异。一般情况下展示是这样的，我们很容易看懂：

```bash
$ git status
位于分支 topic/0173-midx-fixup-deleting-packfile
您的分支与上游分支 'origin/topic/0173-midx-fixup-deleting-packfile' 一致。

未跟踪的文件:
  （使用 "git add <文件>..." 以包含要提交的内容）
	configure~
	null.d

提交为空，但是存在尚未跟踪的文件（使用 "git add" 建立跟踪）
```

如果添加 `-z` 参数，那就会输出方便程序识别的数据格式：

```bash
$ git status -uall -z | hexdump -C
00000000  3f 3f 20 63 6f 6e 66 69  67 75 72 65 7e 00 3f 3f  |?? configure~.??|
00000010  20 6e 75 6c 6c 2e 64 00                           | null.d.|
00000018
```

默认的数据格式见：[Porcelain Format Version 1](https://git-scm.com/docs/git-status#_porcelain_format_version_1) 。
<a name="EwseU"></a>

### git symbolic-ref --short HEAD

获取当前仓库所在的分支。<br />[git symbolic-ref](https://git-scm.com/docs/git-symbolic-ref) 是用来读写符号引用的，符号引用是指内容以 `ref: refs/`开头的文件，比如 .git/HEAD 和 `.git/refs/remotes/origin/HEAD` ：

```bash
$ cat .git/HEAD
ref: refs/heads/topic/0173-midx-fixup-deleting-packfile

$ cat .git/refs/remotes/origin/HEAD
ref: refs/remotes/origin/master
```

`--short`表示输出短字符，比如符号引用内容为 `refs/heads/master` ，那添加 `--short` 的输出则为 `master` 。

> oh-my-zsh 默认的 git 插件，也是使用这条命令来获取当前分支。

<a name="xp89O"></a>

### git for-each-ref

vscode 使用`git for-each-ref`来获取本地分支和远程分支的差异。<br />[git for-each-ref](https://git-scm.com/docs/git-for-each-ref) 会遍历所有匹配格式的引用，然后按照 `--format` 的格式输出数据。<br />比如

`git for-each-ref --sort -committerdate --format %(refname) %(objectname) %(*objectname)`

```bash
$ git for-each-ref --sort -committerdate --format "%(refname) %(objectname) %(*objectname)"
refs/heads/master 2e107853ff54bc3cb52188163452a6fe00d67502
refs/merge_request/1158314 9a61e6009333616ee122287f35b01972fb239b59
refs/remotes/origin/HEAD 9a61e6009333616ee122287f35b01972fb239b59
```

<a name="cl9fS"></a>

### git remote --verbose

常用命令，查看远程仓库的地址：

```bash
$ git remote --verbose
origin	git@codeup.aliyun.com:5ed5e6f717b522454a36976e/xiaowenxia1/bit.git (fetch)
origin	git@codeup.aliyun.com:5ed5e6f717b522454a36976e/xiaowenxia1/bit.git (push)
```

<a name="J2UJO"></a>

### git config --get commit.template

获取提交模板。<br />git 支持配置`commit.template`，指定一个模板文件，git commit 时，默认按照这个模板来编写 commit 信息。

<a name="dog1o"></a>

### git check-ignore -v -z --stdin

检查哪些文件是被 gitignore 的。[https://git-scm.com/docs/git-check-ignore](https://git-scm.com/docs/git-check-ignore) 。

```bash
xxw@xxwPC > echo ".bit/" | git check-ignore -v -z --stdin | hexdump -C
00000000  2e 67 69 74 69 67 6e 6f  72 65 00 37 35 00 2e 62  |.gitignore.75..b|
00000010  69 74 00 2e 62 69 74 2f  0a 00                    |it..bit/..|
0000001a
```

`-v` 输出更多信息，比如对应的 .gitignore 文件的第几行。`-z` 是使用 NUL 替代回车。`--stdin` 代表文件/目录从标准输入读取。

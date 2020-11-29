
```
$ tree .git/refs
.git/refs
├── heads
│   └── master
├── merge-requests
│   └── 267123
│       └── head
├── remotes
│   └── origin
│       └── HEAD
└── tags
```


heads
merge-requests

gerrit

remotes

tags

### HEAD

HEAD是一个指针，指向当前的操作分支。

使用 `cat .git/HEAD` 命令可以查看 `HEAD` 内容：
```bash
$ cat .git/HEAD
ref: refs/heads/main
```
HEAD有很多方便的用法，比如：
```bash
# 查看当前分支的日志
$ git log HEAD
# 恢复上一次提交到工作区
$ git reset HEAD^
```
同时，`HEAD` 作为 [revisions](./git-revisions.md) 时，也有很多奇妙的用法，比如 `HEAD^` 代表上一次提交、`HEAD~6` 代表往回追溯6个版本的那个提交等。

FETCH_HEAD
ORIG_HEAD
COMMIT_EDITMSG

### git describe
> 参考：https://git-scm.com/docs/git-describe

git 的 describe 命令是用来给一个 refs 添加方面阅读的描述信息，
git-describe - Give an object a human readable name based on an available ref
# git 的特殊技巧

<a name="BVhPV"></a>
### 可以 clone 本地仓库

```bash
$ git clone /home/git/repositories/801/038/000/38801.git
```

<a name="ZrIcR"></a>
### 修改本地提交者信息

<br />

### 本地有 Untracked Files 时，如何做一个 patch 包

```bash
# -N 表示实际上并没有把文件添加到暂存区
$ git add -N .
# git diff 生成 patch 文件
$ git diff > xxx.patch
# 恢复
$ git reset
```
如下显示：
![](https://img.alicdn.com/tfs/TB1VW780hD1gK0jSZFsXXbldVXa-2484-1884.png)


### git clone --bare

```bash
$ git clone --bare git@github.com:xiaowenxia/git-inside.git
Cloning into bare repository 'git-inside.git'...
...

# 查看目录
$ tree git-inside.git 
git-inside.git
|-- HEAD
|-- branches
|-- config
|-- description
|-- hooks
|   |-- applypatch-msg.sample
|   |-- ......
|   |-- prepare-commit-msg.sample
|   `-- update.sample
|-- info
|   `-- exclude
|-- objects
|   |-- info
|   `-- pack
|       |-- pack-0381ae2bc198d3ad1f6483eaf2ebf80fe6cd9b26.idx
|       `-- pack-0381ae2bc198d3ad1f6483eaf2ebf80fe6cd9b26.pack
|-- packed-refs
`-- refs
    |-- heads
    `-- tags

9 directories, 18 files
```


### 查看 commit-id 属于哪个分支

```bash
$ git branch -r --contains e784be434c9133cef107185925af22cd620a8e5e
origin/feature/wiki
origin/releases/20201015194918032_r_release_62648_t-force-stone-code
```

### 查看某人的所有提交（所有分支）
```bash
$ git log --all --author="775117471@qq.com"
commit 59cabcd911a3a7460d53c850ee2c69372397cec9 (HEAD -> main, origin/main, origin/HEAD)
Author: xiaowenxia <775117471@qq.com>
Date:   Tue Nov 3 20:07:30 2020 +0800

    add some git tips

commit 834afb32e8e9825e80c7910dbd9379e1be77629a
Author: xiaowenxia <775117471@qq.com>
Date:   Mon Nov 2 15:09:43 2020 +0800

    Add `git-refs`.
```

### 如何在 vscode 中查看已经提交的代码 diff

```bash
# reset 到前面 7 个提交
$ git reset --soft HEAD~7

# 恢复
$ git pull
```

如下所示：
![](https://img.alicdn.com/tfs/TB1A08J2AL0gK0jSZFtXXXQCXXa-3092-2098.png)

### cherry-pick 多个提交
```bash
# 中间使用三个点（...）代表 pick 多个提交，这些提交必须是连续的
$ git cherry-pick 33fbcded...4f17fa9f

# 不连续的提交则需要单独指定 commit-id
$ git cherry-pick 33fbcded 4f17fa9f 820b38b4
```
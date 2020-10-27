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
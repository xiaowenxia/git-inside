# git hooks

> 官方Git 钩子说明：[https://git-scm.com/docs/githooks](https://git-scm.com/docs/githooks) 。

<br />


Git 能在特定的重要动作发生时触发自定义脚本，该脚本可以是Shell、Ruby、Python等，这些脚本就是 Git Hooks（git 钩子）。钩子都被存储在 Git 工作目录下的 `hooks` 子目录中：
```bash
$ tree .git/hooks
.git/hooks
├── applypatch-msg.sample
├── commit-msg.sample
├── fsmonitor-watchman.sample
├── post-update.sample
├── pre-applypatch.sample
├── pre-commit.sample
├── pre-merge-commit.sample
├── pre-push.sample
├── pre-rebase.sample
├── pre-receive.sample
├── prepare-commit-msg.sample
└── update.sample

0 directories, 12 files
```
git hooks 的生命周期图解：<br />       ![image.png](https://img.alicdn.com/tfs/TB1587tZBr0gK0jSZFnXXbRRXXa-1020-767.png)
> 该图片来自：[https://delicious-insights.com/fr/articles/git-hooks/](https://delicious-insights.com/fr/articles/git-hooks/) 。



<a name="7q280"></a>
#### 提交工作流的钩子
| **hook** | **触发点** | **说明** |
| :---: | --- | --- |
| `pre-commit` | 提交信息**前**运行 | 它用于检查即将提交的快照，如果该钩子以非零值退出，Git 将放弃此次提交，不过你可以用 `git commit --no-verify` 来绕过这个环节。 |
| `prepare-commit-msg` | 在启动提交信息编辑器之前，默认信息被创建之后运行 | 它允许你编辑提交者所看到的默认信息。 该钩子接收一些选项：存有当前提交信息的文件的路径、提交类型和修补提交的提交的 SHA-1 校验。 它对一般的提交来说并没有什么用；然而对那些会自动产生默认信息的提交，如提交信息模板、合并提交、压缩提交和修订提交等非常实用。 你可以结合提交模板来使用它，动态地插入信息。 |
| `commit-msg` | 提交信息时运行 | 钩子接收一个参数，此参数即上文提到的，存有当前提交信息的临时文件的路径。 如果该钩子脚本以非零值退出，Git 将放弃提交，因此，可以用来在提交通过前验证项目状态或提交信息。 在本章的最后一节，我们将展示如何使用该钩子来核对提交信息是否遵循指定的模板。 |
| `post-commit` | 整个提交过程完成后运行 | 它不接收任何参数，但你可以很容易地通过运行 `git log -1 HEAD` 来获得最后一次的提交信息。 该钩子一般用于通知之类的事情。 |



<a name="ebpZR"></a>
#### 电子邮件工作流钩子
| **hook** | **触发点** | **说明** |
| :---: | --- | --- |
| `applypatch-msg` | 应用补丁前运行 | 它接收单个参数：包含请求合并信息的临时文件的名字。 如果脚本返回非零值，Git 将放弃该补丁。 你可以用该脚本来确保提交信息符合格式，或直接用脚本修正格式错误。 |
| `pre-applypatch` | 应用补丁后、产生提交之前运 | 你可以用这个脚本运行测试或检查工作区。 如果有什么遗漏，或测试未能通过，脚本会以非零值退出，中断 `git am` 的运行，这样补丁就不会被提交。 |
| `post-applypatch` | 提交产生后运行 | `git am` 运行期间最后被调用的钩子。 你可以用它把结果通知给一个小组或所拉取的补丁的作者。 但你没办法用它停止打补丁的过程。 |



<a name="Oeeq0"></a>
#### 其他客户端钩子
| **hook** | **触发点** | **说明** |
| :---: | --- | --- |
| `pre-rebase` | rebase 前 | 以非零值退出可以中止变基的过程。 你可以使用这个钩子来禁止对已经推送的提交变基。 |
| `post-rewrite` | 运行会替换提交记录的命令时调用 | 比如：`git commit --amend` 和 `git rebase`。它唯一的参数是触发重写的命令名，同时从标准输入中接受一系列重写的提交记录。 这个钩子的用途很大程度上跟 `post-checkout` 和 `post-merge` 差不多。 |
| `post-checkout` | 在 `git checkout` 成功运行后 | 你可以根据你的项目环境用它调整你的工作目录。 其中包括放入大的二进制文件、自动生成文档或进行其他类似这样的操作。 |
| `post-merge` | 在 `git merge` 成功运行后 | 你可以用它恢复 Git 无法跟踪的工作区数据，比如权限数据。 这个钩子也可以用来验证某些在 Git 控制之外的文件是否存在，这样你就能在工作区改变时，把这些文件复制进来。 |
| `pre-push` | 在 `git push` 运行期间， 更新了远程引用但尚未传送对象时被调用 | 它接受远程分支的名字和位置作为参数，同时从标准输入中读取一系列待更新的引用。 你可以在推送开始之前，用它验证对引用的更新操作（一个非零的退出码将终止推送过程）。 |
| `pre-auto-gc` | 在垃圾回收（`git gc --auto`）开始之前被调用 | 可以用它来提醒你现在要回收垃圾了，或者依情形判断是否要中断回收。 |



<a name="Kt210"></a>
#### 服务端钩子
| **hook** | **触发点** | **说明** |
| :---: | ---| --- |
| `pre-receive` | 来自客户端的推送操作时 |  它从标准输入获取一系列被推送的引用。如果它以非零值退出，所有的推送内容都不会被接受。 你可以用这个钩子阻止对引用进行非快进（`non-fast-forward`）的更新，或者对该推送所修改的所有引用和文件进行访问控制。 |
| `update` | update 脚本和 pre-receive 脚本十分类似，不同之处在于它会为每一个准备更新的分支各运行一次。 | 假如推送者同时向多个分支推送内容，`pre-receive` 只运行一次，相比之下 `update` 则会为每一个被推送的分支各运行一次。 它不会从标准输入读取内容，而是接受三个参数：引用的名字（分支），推送前的引用指向的内容的 `SHA-1` 值，以及用户准备推送的内容的 `SHA-1` 值。 如果 `update` 脚本以非零值退出，只有相应的那一个引用会被拒绝；其余的依然会被更新。 |
| `post-receive` | 整个接收过程完结以后运行 | 可以用来更新其他系统服务或者通知用户。 它接受与 `pre-receive` 相同的标准输入数据。 它的用途包括给某个邮件列表发信，通知持续集成（`continous integration`）的服务器， 或者更新问题追踪系统（`ticket-tracking system`） —— 甚至可以通过分析提交信息来决定某个问题（`ticket`）是否应该被开启，修改或者关闭。 该脚本无法终止推送进程，不过客户端在它结束运行之前将保持连接状态， 所以如果你想做其他操作需谨慎使用它，因为它将耗费你很长的一段时间。 |


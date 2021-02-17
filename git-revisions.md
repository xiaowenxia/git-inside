## Git Revisions

> 参考原文链接：[https://git-scm.com/docs/gitrevisions](https://git-scm.com/docs/gitrevisions) 。

**`git revisions`** （Git 修订版本）代表特定的版本或范围，revisions 可以高效的定位你想要的提交，git 命令很多参数都支持 revisions 。

revisions 的具体格式有一整套匹配规则：
```bash
----------------------------------------------------------------------
|    Commit-ish/Tree-ish    |                Examples
----------------------------------------------------------------------
|  1. <sha1>                | dae86e1950b1277e545cee180551750029cfe735
|  2. <describeOutput>      | v1.7.4.2-679-g3bee7fb
|  3. <refname>             | master, heads/master, refs/heads/master
|  4. <refname>@{<date>}    | master@{yesterday}, HEAD@{5 minutes ago}
|  5. <refname>@{<n>}       | master@{1}
|  6. @{<n>}                | @{1}
|  7. @{-<n>}               | @{-1}
|  8. <refname>@{upstream}  | master@{upstream}, @{u}
|  9. <rev>^                | HEAD^, v1.5.1^0
| 10. <rev>~<n>             | master~3
| 11. <rev>^{<type>}        | v0.99.8^{commit}
| 12. <rev>^{}              | v0.99.8^{}
| 13. <rev>^{/<text>}       | HEAD^{/fix nasty bug}
| 14. :/<text>              | :/fix nasty bug
----------------------------------------------------------------------
|       Tree-ish only       |                Examples
----------------------------------------------------------------------
| 15. <rev>:<path>          | HEAD:README.txt, master:sub-directory/
----------------------------------------------------------------------
|         Tree-ish?         |                Examples
----------------------------------------------------------------------
| 16. :<n>:<path>           | :0:README, :README
----------------------------------------------------------------------
```
> 来自 StackOverflow 的 一份回答：[What are commit-ish and tree-ish in Git?](https://stackoverflow.com/questions/23303549/what-are-commit-ish-and-tree-ish-in-git) 。

#### _`<sha1>`_
object 对象名称。
示例：
- _`dae86e1950b1277e545cee180551750029cfe735`_
- _`dae86e`_

#### _`<describeOutput>`_
`git describe` 的输出。

示例：
- _`v1.7.4.2-679-g3bee7fb`_

#### _`<refname>`_
引用名称。

示例：
- _`master`_
- _`heads/master`_
- _`refs/heads/master`_

#### _`@`_
单独一个 `@` 表示 `HEAD` ，及当前分支。

#### _`[<refname>]@{<date>}`_
设置引用名称，同时设置时间过滤条件。

示例：
- _`master@{yesterday}`_
- _`HEAD@{5 minutes ago}`_
- _`refs/heads/master@{1979-02-26 18:30:00}`_

#### _`<refname>@{<n>}`_
设置引用名称，同时设置倒数第 n 个版本。 0 代表最新的版本。

示例：
- _`HEAD@{0}`_
- _`master@{1}`_
- _`refs/heads/master@{10}`_

#### _`@{<n>}`_
跟 _`<refname>@{<n>}`_ 一样，省略了 refname 表示 refname 默认为 HEAD 。<br />

#### _`@{-<n>}`_

#### _`[<branchname>]@{upstream}`_
指定远程仓库分支名称。_`@{upstream}`_ 可以简化成 _`@{u}`_ 。

示例：
- _`master@{upstream}`_
- _`@{u}`_

#### _`[<branchname>]@{push}`_
指定分支名称，指示该分支将会push到远程仓库中。

示例：
- _`master@{push}`_
- _`@{push}`_

#### _`<rev>^[<n>]`_
在 revision 后面添加 _`^`_ 符号，表示获取第 n 个父级对象( parent )，没有设置 n 时，表示第一个父级对象，_`^0`_ 表示 commit 本身。

示例：
- _`HEAD^`_
- _`v1.5.1^0`_
- _`HEAD^3`_

#### _`<rev>~[<n>]`_


#### _`<rev>^{<type>}`_
在 revision 后面添加 _`^{<type>}`_ 符号表示递归该引用直到找到对应类型（_`<type>`_）的 object 对象。

示例：
- _`v0.99.8^{commit}`_
- _`dae86e1950b1277e545cee180551750029cfe735^{tree}`_

#### _`<rev>^{}`_
表示递归该引用直到找到类型为tag的 object 对象。

示例：
- _`v0.99.8^{}`_
- _`dae86e1950b1277e545cee180551750029cfe735^{}`_

#### _`<rev>^{/<text>}`_
匹配 _`<text>`_，等效于 _`:/<text>`_ 。

示例：
- _`HEAD^{/fix nasty bug}`_

#### _`:/<text>`_
正则表达式匹配字符串。

示例：
- _`:/fix nasty bug`_
- _`:/^foo`_

#### _`<rev>:<path>`_
匹配文件/目录名称。

示例：
- _`HEAD:README`_
- _`master:./README`_

#### _`:[<n>:]<path>`_

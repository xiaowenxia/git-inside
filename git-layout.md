## Git 目录结构

Git 仓库有两种形式：
* 工作目录中的 `.git` 目录。这种是我们经常接触的Git仓库形式。
* 裸仓库，目录一般是 `<project>.git`。裸仓库没有工作区（working tree），一般是存在于服务器中，用于给用户仓库交互和存储的。

> 注：有些仓库底下没有.git目录，但是有一个 `.git` 文本文件，其内容格式为 `gitdir: <path>` ，代表指向真正的 `.git` 目录。这种情况经常用在 git submodule 中。

### Git 仓库文件结构

#### objects/
仓库的所有对象都存储在`objects/`目录中。
> * 定义了 `GIT_COMMON_DIR` 环境变量时， `objects/` 目录路径则为：`$GIT_COMMON_DIR/objects`。
> * 一般来讲，objects/ 目录中记录了所有的仓库对象，但是有些特殊情况（存在 `objects/info/alternates` 文件，或者定义 `GIT_ALTERNATE_OBJECT_DIRECTORIES` 环境变量时），可以引用仓库外部的对象，具体参见：[gitrepository-layout.txt#L40](https://github.com/git/git/blob/master/Documentation/gitrepository-layout.txt#L40)。

#### objects/[0-9a-f][0-9a-f]/
松散对象（'unpacked' or 'loose' objects）。新创建的对象都是存在这些目录中，对象的文件名称时对象内容的sha1值，取sha1值的前2个字符作为子目录。

#### objects/pack/
pack文件存储位置。该目录下还存在 `*.idx` 文件，为对应的 `*.pack` 文件的索引文件。

#### objects/info/
记录`objects` 目录的说明。

#### objects/info/packs
git 哑协议（dumb transports）会使用到的文件。

#### objects/info/alternates
该文件记录外部对象目录，一行记录一个目录路径。

#### objects/info/http-alternates
当仓库是HTTP协议传输时，该文件记录的是URLs，这些URLs存储外部的对象。


#### refs/
git 引用，该目录下存储 git 的所有引用。 
`git prune` 命令会清除掉那些不被 git references 引用到的对象。

> 定义了 `GIT_COMMON_DIR` 环境变量时， `refs/` 目录路径则为：`$GIT_COMMON_DIR/refs/`，但是 `refs/bisect` 、 `refs/rewritten` 、 `refs/worktree` 这3个文件不会受 `GIT_COMMON_DIR` 影响。

#### refs/heads/<name>
记录 git 的分支（branch）。

#### refs/tags/<name>
记录 git 的标签（tag）。

#### refs/remotes/<name>
记录远程分支。

#### refs/replace/<obj-sha1>
records the SHA-1 of the object that replaces `<obj-sha1>`.

#### packed-refs/
记录的和 `refs/heads/`, `refs/tags/` 一样的内容，但是记录效率更高。

> 跟`refs/` 目录一样，定义了 `GIT_COMMON_DIR` 环境变量时， `packed-refs/` 目录路径则为：`$GIT_COMMON_DIR/packed-refs/`


#### HEAD
记录当前激活的分支，其内容指向具体的分支（`refs/heads/<name>`）。一个git仓库一定会有一个HEAD文件。HEAD 文件也可以直接记录一个commit-id，这种情况就是常见的'detached HEAD.'，当检出特定的commit-id时（ `git checkout <commit-id>` ）就会变成这样。

> * 很多时候可以通过HEAD文件来判断仓库的默认分支。
> * HEAD指向不存在的分支也是可以的。


#### config
本地仓库配置，通过`git config --local`查看或者设置。该文件的路径也受环境变量 `GIT_COMMON_DIR` 控制。


#### config.worktree
多工作区时的工作区配置文件。


#### branches/
用于 'git fetch' 、 'git pull' 、 'git push'，不过这个目录已经不再用了。


#### hooks/

git 钩子目录。 `git init` 时，会默认创建一些简单的 hooks 文件。该目录也受环境变量 `GIT_COMMON_DIR` 控制。

#### common/
当仓库是多工作区时，不同的工作区共享 `common/` 目录下的文件。

#### index
索引文件，裸仓库（bare repository）下不存在 index 文件。

#### sharedindex.<SHA-1>

共享索引文件（shared index ），被`index`文件或者临时index文件（temporary index）引用。只在分割索引模式（split index mode）中有效。

#### info/
仓库描述信息目录。文件目录受环境变量 `GIT_COMMON_DIR` 控制。


#### info/refs
跟`objects/info/packs`一样，用于哑协议。

#### info/grafts

#### info/exclude
一般情况，这个文件描述哪些文件排除在版本控制之外，和 `.gitignore` 文件功能类似，但是 `.gitignore` 文件可以存在每个目录下面。

#### info/attributes
定义路径的属性，和`.gitattributes`文件功能类似。

#### info/sparse-checkout
记录 sparse checkout 时的匹配信息。
#### remotes
记录 'git fetch' 、 'git pull' 、 'git push' 命令时的远程 URL 和引用名称。这个目录现在已经不用了。

#### logs/
存储引用的历史变更记录。该目录也受环境变量 `GIT_COMMON_DIR` 控制，不过 `logs/HEAD` 文件除外。

#### logs/refs/heads/`<name>`
分支的历史变更记录。

#### logs/refs/tags/`<name>`
标签的历史变更记录。

#### shallow
跟 `info/grafts` 一样的功能，但是只用于内部。

#### commondir
该文件存在时，如果没有定义 GIT_COMMON_DIR 环境变量，那 GIT_COMMON_DIR 会被设置成commondir的内容。

#### modules
存储 git submodule 的仓库。

#### worktrees

#### worktrees/`<id>`/gitdir

#### worktrees/`<id>`/locked

#### worktrees/`<id>`/config.worktree

### 仓库目录
* [gitrepository-layout](https://github.com/git/git/blob/master/Documentation/gitrepository-layout.txt)
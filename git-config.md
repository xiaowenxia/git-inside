### git 的配置说明

> 参考 [Pro Git](https://git-scm.com/book/en/v2) 的 [Customizing Git - Git Configuration](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)

### git 的 3 种配置
git 有 3 种配置，分别为当前工作区配置、全局配置、系统配置，各自的配置文件分别为：
* 当前工作区配置文件：`<repo>/.git/config`。
* 全局配置文件：`~/.gitconfig`。
* 系统配置文件：`/etc/gitconfig`。

`git config` 命令，分别可以使用 `--local` 、 `--global` 、 `--system` 来设置对应的git 配置：
```bash
# 查看当前工作区配置
$ git config --local --list
# 查看全局配置
$ git config --global --list
# 查看系统配置
$ git config --system --list
# 查看当前生效的配置
$ git config --list
```

### 常见的配置项

```bash
# 配置用户名
$ git config --global user.name "xiaowenxia"
# 配置邮箱
$ git config --global user.email "775117471@qq.com"
# 配置自动颜色
$ git config --global color.ui auto
# 配置默认的编辑器为vim
$ git config --global core.editor vim
```

### git config


<details>
<summary>命令说明（点击展开）</summary>

    usage: git config [<options>]

    Config file location
        --global              use global config file
        --system              use system config file
        --local               use repository config file
        --worktree            use per-worktree config file
        -f, --file <file>     use given config file
        --blob <blob-id>      read config from given blob object

    Action
        --get                 get value: name [value-regex]
        --get-all             get all values: key [value-regex]
        --get-regexp          get values for regexp: name-regex [value-regex]
        --get-urlmatch        get value specific for the URL: section[.var] URL
        --replace-all         replace all matching variables: name value [value_regex]
        --add                 add a new variable: name value
        --unset               remove a variable: name [value-regex]
        --unset-all           remove all matches: name [value-regex]
        --rename-section      rename section: old-name new-name
        --remove-section      remove a section: name
        -l, --list            list all
        -e, --edit            open an editor
        --get-color           find the color configured: slot [default]
        --get-colorbool       find the color setting: slot [stdout-is-tty]

    Type
        -t, --type <>         value is given this type
        --bool                value is "true" or "false"
        --int                 value is decimal number
        --bool-or-int         value is --bool or --int
        --path                value is a path (file or directory name)
        --expiry-date         value is an expiry date

    Other
        -z, --null            terminate values with NUL byte
        --name-only           show variable names only
        --includes            respect include directives on lookup
        --show-origin         show origin of config (file, standard input, blob, command line)
        --default <value>     with --get, use default value when missing entry
</detail>
</br>
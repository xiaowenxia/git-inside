## git 的配置说明

> 参考 [Pro Git](https://git-scm.com/book/en/v2) 的 [Customizing Git - Git Configuration](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)。更详细的配置项说明见：https://git-scm.com/docs/git-config 。

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
</details>
</br>

### 更多配置项

#### core.editor
git 默认使用环境变量 `VISUAL` 或 `EDITOR` 作为默认的编辑器，用户可以通过配置 `core.editor` 设置默认的编辑器。

#### commit.template
`commit.template` 可以让你配置 `git commit` 时的提交信息的模板文件：
```bash
# 配置 commit 模板文件为 ~/.gitmessage.txt
$ git config --global commit.template ~/.gitmessage.txt
# 提交时，则会显示模板
$ git commit
```

#### core.pager
配置默认的查看git 输出的工具，比如 `git log`、 `git diff`等，默认为 [less](https://man7.org/linux/man-pages/man1/less.1.html)，当然你也可以配置成其他的翻页工具：
```bash
# 配置成 more
$ git config --global core.pager more
# 配置为空，则不使用翻页工具
$ git config --global core.pager ''
```

#### user.signingkey
设置你的 [GPG](https://docs.gitlab.com/ee/user/project/repository/gpg_signed_commits/#:~:text=You%20can%20use%20a%20GPG%20key%20to%20sign,used%20for%20all%20OpenPGP%2FPGP%2FGPG%20related%20material%20and%20implementations.) 签名id：
```bash
$ git config --global user.signingkey <gpg-key-id>
```

#### core.excludesfile
设置全局 ignore 的文件，该配置项相当于全局的 [.gitignore](https://git-scm.com/docs/gitignore) 文件。

```bash
$ git config --global core.excludesfile ~/.gitignore_global
```

#### help.autocorrect
git 命令如果输入有误时，会提示是否存在类似的命令，比如：

```bash
# 故意输错 chekcout，则提示相似的 checkout 命令
$ git chekcout master
git: 'chekcout' is not a git command. See 'git --help'.

The most similar command is
    checkout
```
`help.autocorrect` 则可以让 git 自动纠正命令并执行：
```bash
$ git chekcout master
WARNING: You called a Git command named 'chekcout', which does not exist.
Continuing under the assumption that you meant 'checkout'
in 0.1 seconds automatically...
```

#### color.ui
设置 git 命令输出是否带有颜色。
git 还支持更细颗粒度的颜色输出配置：
```
color.branch
color.diff
color.interactive
color.status
```

#### core.autocrlf

Windows 和 Linux/MacOS 的换行符是有差异的，Windows的换行符是 `CRLF`，Linux/MacOS 的换行符是`LF`，如果用户在 Windows 上提交代码，那 checkout 到Linux/MacOS 平台上则会有显示问题，开启 `core.autocrlf` 配置项则可以让 git 根据平台自动转换换行符。

```bash
$ git config --global core.autocrlf true
```

#### core.attributesFile
设置 .gitattributes 文件路径。

#### 配置 merge 或者 diff 工具
git 还支持配置 merge 或者 diff 工具，比如如下的配置：
```bash
$ git config --global merge.tool extMerge
$ git config --global mergetool.extMerge.cmd \
  'extMerge "$BASE" "$LOCAL" "$REMOTE" "$MERGED"'
$ git config --global mergetool.extMerge.trustExitCode false
$ git config --global diff.external extDiff
```

详细配置说明请参考 [Customizing Git - Git Configuration](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)。
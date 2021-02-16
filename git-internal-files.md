## Git 的特殊文件

### .gitignore
配置忽略的文件或目录

### .gitattribute
> 参考官方手册：https://git-scm.com/docs/gitattributes

`.gitattribute` 可以为每个目录定义想要的属性，同时也支持匹配方式来设定一组目录。一个简单的示例：

```bash
a*	foo !bar -baz

(in .gitattributes)
abc	foo bar baz

(in t/.gitattributes)
ab*	merge=filfre
abc	-foo -bar
*.c	frotz

```

#### gitattributes 文件存储路径
* 仓库
    * `$GIT_DIR/info/attributes`
    * 根目录
    * 子目录
* 用户全局路径：`$HOME/.config/git/gitattributes`
    也可以通过配置项 `core.attributesFile` 配置文件路径，参考 [git-config](https://git-scm.com/docs/git-config)。
* 系统路径：/etc/gitattributes

定义 `gitattributes` ，除了 `.gitattribute` 文件，也可以是 `$GIT_DIR/info/attributes`。

`.gitattribute` 格式非常简单，每一行定义一个或一组属性，中间使用空格作为分隔符：

```
pattern attr1 attr2 ...
pattern2 attr1 attr2 ...
```

> 开头、结尾的空格都会忽略，(`#`)开头的行也会被忽略，双引号(`"`)开头的 `pattern` 使用 C 语言风格。后一行的属性会覆盖前面的属性。

每个路径的属性都有如下状态：

* Set
    设置属性为 `true`。
* Unset
    设置该属性为 `false`。
* 设置成某个值
* Unspecified
gitattributes 支持的属性有：

路径的匹配规则和`.gitignore`几乎是一样的。

#### .gitattribute 的优先级
`.gitattribute` 的优先级由高到低分别是：
* `$GIT_DIR/info/attributes`
* 路径下的 `.gitattribute`
* 上级目录下的 `.gitattribute`
* 更上级目录的`.gitattribute`
* 根目录下的 `.gitattribute`
* 全局的`.gitattribute`
* 系统的`.gitattribute`

比如存在如下文件：

```bash
# 系统
/etc/gitattributes          #1

# 全局
/User/xxx/.gitattributes    #2

# 本地仓库
├── .git
|   ├── ......
│   ├── info
│   │   └── .gitattributes  #3
|   └── ......
├── .gitattributes          #4
├── ......
└── subdir
    ├── .gitattributes      #5
    └── subdirx
        └── .gitattributes  #6
```

那优先级分别是 `#3` > `#6` > `#5` > `#4` > `#2` > `#1`。

通过 `git check-attr` 查看 `.gitattribute`文件内容信息，命令参考 [git check-attr](./git-internal-commands.md#git-check-attr)。

#### .gitkeep
了解 git 底层原理的人应该比较清楚，git 无法追踪一个空的文件夹，当用户需要追踪(track)一个空的文件夹的时候，按照惯例，大家会把一个称为 `.gitkeep` 的文件放在这些文件夹里。

#### .gitmodules


#### .git/description
`.git/description` 文件用来存储仓库名称以及仓库的描述信息。默认的值为：
```
Unnamed repository; edit this file 'description' to name the repository.
```

也可以改成类似如下的值：

```
git-inside This is git-inside
```

有些Git 工具（比如 [GitWeb](https://git-scm.com/book/zh/v2/%E6%9C%8D%E5%8A%A1%E5%99%A8%E4%B8%8A%E7%9A%84-Git-GitWeb) ）通过读取该文件来获取仓库名称以及仓库的说明信息。git hooks 也会读取 `.git/description` 来获取仓库名称。
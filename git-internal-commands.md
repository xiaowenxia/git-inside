# git 底层命令

<a name="OS6wF"></a>
## 目录
* [git cat-file](#git-cat-file)
* [git ls-files](#git-ls-files)
* [git ls-tree](#git-ls-tree)
* [git read-tree](#git-read-tree)
* [git write-tree](#git-write-tree)
* [git commit-tree](#git-commit-tree)
* [git mktree](#git-mktree)
* [git diff-tree](#git-diff-tree)
* [git gc](#git-gc)
* [git verify-pack](#git-verify-pack)
* [git hash-object](#git-hash-object)
* [git show-index](#git-show-index)
* [git show-ref](#git-show-ref)
* [git update-ref](#git-update-ref)
* [git rev-parse](#git-rev-parse)
* [git rev-list](#git-rev-list)
* [git for-each-ref](#git-for-each-ref)
* [git var](#git-var)
* [git diff-tree](#git-diff-tree)
* [git merge-base](#git-merge-base)
* [git ref-log](#git-ref-log)
* [git blame](#git-blame)
* [git check-attr](#git-check-attr)
* [git count-objects](#git-count-objects)
* [git fsck](#git-fsck)

## 底层命令
<a name="h2UUt"></a>

### git cat-file
查看objects文件。

<details>
<summary>命令说明（点击展开）</summary>

    usage: git cat-file (-t [--allow-unknown-type] | -s [--allow-unknown-type] | -e | -p | <type> | --textconv | --filters) [--path=<path>] <object>
    or: git cat-file (--batch | --batch-check) [--follow-symlinks] [--textconv | --filters]

    <type> can be one of: blob, tree, commit, tag
        -t                    show object type
        -s                    show object size
        -e                    exit with zero when there's no error
        -p                    pretty-print object's content
        --textconv            for blob objects, run textconv on object's content
        --filters             for blob objects, run filters on object's content
        --path <blob>         use a specific path for --textconv/--filters
        --allow-unknown-type  allow -s and -t to work with broken/corrupt objects
        --buffer              buffer --batch output
        --batch[=<format>]    show info and content of objects fed from the standard input
        --batch-check[=<format>]
                            show info about objects fed from the standard input
        --follow-symlinks     follow in-tree symlinks (used with --batch or --batch-check)
        --batch-all-objects   show all objects with --batch or --batch-check
</details>

</br>

示例
```bash
# 查看 objects 文件类型
$ git cat-file -t 56ec1a0729533fbd8d38b7964b6f8ca2cace70ba
commit

# 查看 objects 文件大小
$ git cat-file -s 56ec1a0729533fbd8d38b7964b6f8ca2cace70ba
243

# 查看 objects 文件（格式化）内容
$ git cat-file -p 56ec1a0729533fbd8d38b7964b6f8ca2cace70ba
tree 7f9adb36c3e987d1ca9d40ba538afd8cbc74e942
parent cf22ff3d15d718603f93c36f13d848e00d841def
author chenan.xxw <chenan.xxw@alibaba-inc.com> 1599545250 +0800
committer chenan.xxw <chenan.xxw@alibaba-inc.com> 1599545250 +0800

update README.md

# 也可以通过 tag 或 branch 名称查看 object 文件
$ git cat-file -t v0.1.0
tag
$ git cat-file -p v0.1.0
object c5b97d5ae6c19d5c5df71a34c7fbeeda2479ccbc
type commit
tag v0.1.0
tagger Scott Chacon <schacon@gmail.com> 1290556430 -0800

tagging initial release of libgit2
```


<a name="5M8In"></a>

### git ls-files
查看index文件内容。

<details>
<summary>命令说明（点击展开）</summary>

    usage: git ls-files [<options>] [<file>...]
        -z                    paths are separated with NUL character
        -t                    identify the file status with tags
        -v                    use lowercase letters for 'assume unchanged' files
        -f                    use lowercase letters for 'fsmonitor clean' files
        -c, --cached          show cached files in the output (default)
        -d, --deleted         show deleted files in the output
        -m, --modified        show modified files in the output
        -o, --others          show other files in the output
        -i, --ignored         show ignored files in the output
        -s, --stage           show staged contents' object name in the output
        -k, --killed          show files on the filesystem that need to be removed
        --directory           show 'other' directories' names only
        --eol                 show line endings of files
        --empty-directory     don't show empty directories
        -u, --unmerged        show unmerged files in the output
        --resolve-undo        show resolve-undo information
        -x, --exclude <pattern>
                            skip files matching pattern
        -X, --exclude-from <file>
                            exclude patterns are read from <file>
        --exclude-per-directory <file>
                            read additional per-directory exclude patterns in <file>
        --exclude-standard    add the standard git exclusions
        --full-name           make the output relative to the project top directory
        --recurse-submodules  recurse through submodules
        --error-unmatch       if any <file> is not in the index, treat this as an error
        --with-tree <tree-ish>
                            pretend that paths removed since <tree-ish> are still present
        --abbrev[=<n>]        use <n> digits to display SHA-1s
        --debug               show debugging data
</details>

</br>

示例

```bash
$ git ls-files
.gitignore
Makefile
README
README.md
cache.h
cat-file.c
commit-tree.c
init-db.c
read-cache.c
read-tree.c
show-diff.c
update-cache.c
write-tree.c

# 使用 hexdump 可以查看到index文件内容
$ hexdump -C .git/index
```

<a name="CFLvH"></a>

### git ls-tree
查看树内容，可以是 commit-id ，也可以是 tree-id ，也可以是 [git revisions](./git-revisions.md) 格式。

<details>
<summary>命令说明（点击展开）</summary>

    usage: git ls-tree [<options>] <tree-ish> [<path>...]

        -d                    only show trees
        -r                    recurse into subtrees
        -t                    show trees when recursing
        -z                    terminate entries with NUL byte
        -l, --long            include object size
        --name-only           list only filenames
        --name-status         list only filenames
        --full-name           use full path names
        --full-tree           list entire tree; not just current directory (implies --full-name)
        --abbrev[=<n>]        use <n> digits to display SHA-1s
</details>

</br>
示例

```bash
$ git ls-tree bace6b8b2d3058e3cc0495f5edfb235ed8cff21e
100644 blob c30106543ed8f32af334362fa82e3a4ad71ef20f	home.md
100644 blob c3d45c3c479ebc458accbbd82c6483aecb35e516	main.md
040000 tree fec352d6a6f669a3e1b035202911245e1d73e8ac	subdir

# size、全路径格式
$ git ls-tree -l --full-name bace6b8b2d3058e3cc0495f5edfb235ed8cff21e
100644 blob c30106543ed8f32af334362fa82e3a4ad71ef20f      16	home.md
100644 blob c3d45c3c479ebc458accbbd82c6483aecb35e516      18	main.md
040000 tree fec352d6a6f669a3e1b035202911245e1d73e8ac       -	subdir

$ git ls-tree --full-name HEAD
100644 blob c30106543ed8f32af334362fa82e3a4ad71ef20f	home.md
100644 blob c3d45c3c479ebc458accbbd82c6483aecb35e516	main.md
040000 tree fec352d6a6f669a3e1b035202911245e1d73e8ac	subdir

# git revision 格式
$ git ls-tree --full-name HEAD^{tree}
100644 blob c30106543ed8f32af334362fa82e3a4ad71ef20f	home.md
100644 blob c3d45c3c479ebc458accbbd82c6483aecb35e516	main.md
040000 tree fec352d6a6f669a3e1b035202911245e1d73e8ac	subdir
```


<a name="AAHtb"></a>

### git read-tree
把tree的信息（可以是多个）写入到索引（index）中。

<details>
<summary>命令说明（点击展开）</summary>

    usage: git read-tree [(-m [--trivial] [--aggressive] | --reset | --prefix=<prefix>) [-u [--exclude-per-directory=<gitignore>] | -i]] [--no-sparse-checkout] [--index-output=<file>] (--empty | <tree-ish1> [<tree-ish2> [<tree-ish3>]])

        --index-output <file>
                            write resulting index to <file>
        --empty               only empty the index
        -v, --verbose         be verbose

    Merging
        -m                    perform a merge in addition to a read
        --trivial             3-way merge if no file level merging required
        --aggressive          3-way merge in presence of adds and removes
        --reset               same as -m, but discard unmerged entries
        --prefix <subdirectory>/
                            read the tree into the index under <subdirectory>/
        -u                    update working tree with merge result
        --exclude-per-directory <gitignore>
                            allow explicitly ignored files to be overwritten
        -i                    don't check the working tree after merging
        -n, --dry-run         don't update the index or the work tree
        --no-sparse-checkout  skip applying sparse checkout filter
        --debug-unpack        debug unpack-trees
        --recurse-submodules[=<checkout>]
                            control recursive updating of submodules
</details>

</br>

示例

```bash
$ git read-tree 7fc6c35263716bad0d1df5a814766e8f1fd20345
$ git ls-files
home.md
main.md
subdir/deeper.md

$ git read-tree HEAD^
home.md
main.md
```

### git write-tree
把存储区的文件结构存储成 tree 对象。

<details>
<summary>命令说明（点击展开）</summary>

usage: git write-tree [--missing-ok] [--prefix=<prefix>/]

    --missing-ok          allow missing objects
    --prefix <prefix>/    write tree object for a subdirectory <prefix>
</details>

</br>

```bash
# 待补充
```

### git commit-tree
把 tree 对象读取到暂存区。

<details>
<summary>命令说明（点击展开）</summary>

usage: git commit-tree [(-p <sha1>)...] [-S[<keyid>]] [-m <message>] [-F <file>] <sha1>

</details>

</br>

```bash
# 待补充
```

### git mktree
根据输入（`ls-tree`的输出格式）来生成 tree 对象。

<summary>命令说明（点击展开）</summary>

usage: git mktree [-z] [--missing] [--batch]

    -z                    input is NUL terminated
    --missing             allow missing objects
    --batch               allow creation of more than one tree

</details>

</br>
```bash
# 待补充
```

### git diff-tree
比较 2 个tree 对象 的差异并格式化输出。

<summary>命令说明（点击展开）</summary>

usage: git diff-tree [--stdin] [-m] [-c] [--cc] [-s] [-v] [--pretty] [-t] [-r] [--root] [<common-diff-options>] <tree-ish> [<tree-ish>] [<path>...]
  -r            diff recursively
  --root        include the initial commit as diff against /dev/null

common diff options:
  -z            output diff-raw with lines terminated with NUL.
  -p            output patch format.
  -u            synonym for -p.
  --patch-with-raw
                output both a patch and the diff-raw format.
  --stat        show diffstat instead of patch.
  --numstat     show numeric diffstat instead of patch.
  --patch-with-stat
                output a patch and prepend its diffstat.
  --name-only   show only names of changed files.
  --name-status show names and status of changed files.
  --full-index  show full object name on index lines.
  --abbrev=<n>  abbreviate object names in diff-tree header and diff-raw.
  -R            swap input file pairs.
  -B            detect complete rewrites.
  -M            detect renames.
  -C            detect copies.
  --find-copies-harder
                try unchanged files as candidate for copy detection.
  -l<n>         limit rename attempts up to <n> paths.
  -O<file>      reorder diffs according to the <file>.
  -S<string>    find filepair whose only one side contains the string.
  --pickaxe-all
                show all files diff when -S is used and hit is found.
  -a  --text    treat all files as text.

</details>

</br>
```bash
# 待补充
```


<a name="UDzYk"></a>

### git gc
打包压缩操作，将多个 object 对象打包成 pack 文件对象。

<details>
<summary>命令说明（点击展开）</summary>

    usage: git gc [<options>]

        -q, --quiet           suppress progress reporting
        --prune[=<date>]      prune unreferenced objects
        --aggressive          be more thorough (increased runtime)
        --auto                enable auto-gc mode
        --force               force running gc even if there may be another gc running
        --keep-largest-pack   repack all other packs except the largest pack

</details>
</br>

```bash
$ git gc
Enumerating objects: 43, done.
Counting objects: 100% (43/43), done.
Delta compression using up to 12 threads
Compressing objects: 100% (43/43), done.
Writing objects: 100% (43/43), done.
Total 43 (delta 15), reused 26 (delta 0)
Computing commit graph generation numbers: 100% (10/10), done.
```


<a name="hPrtl"></a>

### git verify-pack
查看 pack 包内容。<br />

<details>
<summary>命令说明（点击展开）</summary>

    usage: git verify-pack [-v | --verbose] [-s | --stat-only] <pack>...

        -v, --verbose         verbose
        -s, --stat-only       show statistics only
</details>
</br>

示例
```bash
# 查看简略信息
$ git verify-pack -s objects/pack/pack-eebc99ef678d342a5e2aa34c32ec21e488f3bc32.idx
non delta: 28 objects
chain length = 1: 2 objects
chain length = 2: 11 objects
chain length = 3: 2 objects

# 查看详细内容
$ git verify-pack -v objects/pack/pack-eebc99ef678d342a5e2aa34c32ec21e488f3bc32.idx
b0316411f58dc6dd18c700e04f9d3f7f99c17c41 commit 243 162 12
56ec1a0729533fbd8d38b7964b6f8ca2cace70ba commit 243 163 174
cf22ff3d15d718603f93c36f13d848e00d841def commit 236 155 337
1bac831942f9cd24f9ced4d8fe72988eb584f85c commit 233 153 492
9b6e8ecd34cf3fc023123aaab660e58c4f6b705a commit 243 161 645
......
259a84fd251cdabdbbb93b382575fba00ea3614d blob   6170 2572 33450
49cfa9e43a2a86952e2a93c5a8485da30d5dd306 blob   5423 2189 36022
921f981353229db0c56103a52609d35aff16f41b blob   1441 741 38211
non delta: 28 objects
chain length = 1: 2 objects
chain length = 2: 11 objects
chain length = 3: 2 objects
objects/pack/pack-eebc99ef678d342a5e2aa34c32ec21e488f3bc32.pack: ok
```


<a name="D5x8u"></a>

### git hash-object
计算并生成 object 文件。<br />

<details>
<summary>命令说明（点击展开）</summary>

    usage: git hash-object [-t <type>] [-w] [--path=<file> | --no-filters] [--stdin] [--] <file>...
    or: git hash-object  --stdin-paths

        -t <type>             object type
        -w                    write the object into the object database
        --stdin               read the object from stdin
        --stdin-paths         read file names from stdin
        --no-filters          store file as is without filters
        --literally           just hash any random garbage to create corrupt objects for debugging Git
        --path <file>         process file as it were from this path
</details>
</br>

* `--literally` 参数：可以对任意数据（可能是垃圾数据）创建松散对象，防止被 git 阻止或过滤。这种方式主要用于调试 git。

示例

```bash
# 仅计算内容的 hash 值
$ echo "test" | git hash-object --stdin -w --literally
9daeafb9864cf43055ae93beb0afd6c7d144bfa4

# 计算内容的 hash 值并写入成 object 文件
$ ll objects/9d/aeafb9864cf43055ae93beb0afd6c7d144bfa4
-r--r--r-- 1 root root 20 Sep 28 09:55 objects/9d/aeafb9864cf43055ae93beb0afd6c7d144bfa4
$ git cat-file -p 9daeafb9864cf43055ae93beb0afd6c7d144bfa4
test
```


<a name="nKiGC"></a>

### git show-index
从标准输入（stdio）中读取打包索引文件（`*.idx`）内容，解析并显示打包文件的索引信息。

<details>
<summary>命令说明（点击展开）</summary>

    usage: git show-index
</details>
</br>

示例

```bash
$ cat .git/objects/pack/pack-b433cf40a267c0fd6b9c4b8afff213eb9ef4a6fe.idx  | git show-index
11588816 003e02611d63514e51b57eb6575e47475290ed26 (fe575e7e)
11472110 00c99364e50d82189b7894fed6c6dda039cb1930 (55daba02)
11271595 010f8bc628b084496e8ef448b87f05b938321793 (0ee48b3f)
11499040 01122c9bab3033b286caf034e740429bda3910a3 (dc88ce00)
9818594 01742e3d4d110b1dbbee737fe42deb834f61a682 (cff383fc)
11589160 01afc6e92ae59469d19befb2dfe2083718e163dc (278f7124)
10666903 01dc8ba07ced44ea1cb6bbf2372a9d77259cdc49 (d2cfe47d)
10624256 01dfc33db0dd549a00d78daa612d827fd219f31d (2be74112)
7243969 01f2ca67cc81936fed349cf46bcd58cc13ee7fcc (f31729b5)
12537 02468694dfbbdf3e1535630afd2fc646c8de503d (96501cb8)
......
```


<a name="2odx3"></a>

### git show-ref
列出本地引用（ref）。<br />

<details>
<summary>命令说明（点击展开）</summary>

    usage: git show-ref [-q | --quiet] [--verify] [--head] [-d | --dereference] [-s | --hash[=<n>]] [--abbrev[=<n>]] [--tags] [--heads] [--] [<pattern>...]
    or: git show-ref --exclude-existing[=<pattern>]

        --tags                only show tags (can be combined with heads)
        --heads               only show heads (can be combined with tags)
        --verify              stricter reference checking, requires exact ref path
        --head                show the HEAD reference, even if it would be filtered out
        -d, --dereference     dereference tags into object IDs
        -s, --hash[=<n>]      only show SHA1 hash using <n> digits
        --abbrev[=<n>]        use <n> digits to display SHA-1s
        -q, --quiet           do not print results to stdout (useful with --verify)
        --exclude-existing[=<pattern>]
                            show refs from stdin that aren't in local repository
</details>
</br>

```bash
$ git show-ref
52855ba8f5c7e8410db2277ca1b00c4e1d1c2721 refs/heads/master
52855ba8f5c7e8410db2277ca1b00c4e1d1c2721 refs/remotes/origin/HEAD
52855ba8f5c7e8410db2277ca1b00c4e1d1c2721 refs/remotes/origin/master
```


<a name="RFGzC"></a>

### git update-ref
更新引用（ref）的内容为指定的对象名称或 sha1 值。<br />

<details>
<summary>命令说明（点击展开）</summary>

    usage: git update-ref [<options>] -d <refname> [<old-val>]
    or: git update-ref [<options>]    <refname> <new-val> [<old-val>]
    or: git update-ref [<options>] --stdin [-z]

        -m <reason>           reason of the update
        -d                    delete the reference
        --no-deref            update <refname> not the one it points to
        -z                    stdin has NUL-terminated arguments
        --stdin               read updates from stdin
        --create-reflog       create a reflog
</details>
</br>

```bash
$ git update-ref HEAD 52855ba8f5c7e8410db2277ca1b00c4e1d1c2721
```


<a name="mIaJ6"></a>

### git rev-parse
把 [revisions](#PVM6y) 解析成 commit-id ，除此之外，还有其他的功能。

<details>
<summary>命令说明（点击展开）</summary>

    usage: git rev-parse --parseopt [<options>] -- [<args>...]
    or: git rev-parse --sq-quote [<arg>...]
    or: git rev-parse [<options>] [<arg>...]

</details>
</br>

```bash
# 显示 revisions 的 sha1 值
$ git rev-parse HEAD
de1acbdbcb7549b7eff8646f9d9cfb308d6bb90b
$ git rev-parse master^{tree}
06a04ed5cae14951e376336d8eadd59f75be3f9c

# 显示git的工作目录
$ git rev-parse --git-dir
.git
# 显示工作区目录
$ git rev-parse --show-toplevel
/Users/xxw/workspace/aone/force-stone

# 显示相对于工作区根目录的相对路径
$ cd vendor/github.com/pkg
$ git rev-parse --show-prefix
vendor/github.com/pkg/

# 显示从当前目录(cd)后退(up)到工作区的根目录的深度
$ git rev-parse --show-cdup
../../../
```


<a name="NcEOk"></a>

### git rev-list
按照时间顺序输出历史的 commit-id 。

<details>
<summary>命令说明（点击展开）</summary>

    usage: git rev-list [OPTION] <commit-id>... [ -- paths... ]
    limiting output:
        --max-count=<n>
        --max-age=<epoch>
        --min-age=<epoch>
        --sparse
        --no-merges
        --min-parents=<n>
        --no-min-parents
        --max-parents=<n>
        --no-max-parents
        --remove-empty
        --all
        --branches
        --tags
        --remotes
        --stdin
        --quiet
    ordering output:
        --topo-order
        --date-order
        --reverse
    formatting output:
        --parents
        --children
        --objects | --objects-edge
        --unpacked
        --header | --pretty
        --[no-]object-names
        --abbrev=<n> | --no-abbrev
        --abbrev-commit
        --left-right
        --count
    special purpose:
        --bisect
        --bisect-vars
        --bisect-all
</details>
</br>

```bash
# 显示 master 分支的历史版本
$ git rev-list master
52855ba8f5c7e8410db2277ca1b00c4e1d1c2721
b16a0f533bbda973eb28fbfbc91a7dbb345d38d1
983f2892bebdaa7422895a2583cd32fab54c0ea5
7ba6884d2f1c40caf5ba40136c85c3c413c3488b
585815f7b473f015cf99aeba71b5f37219494d90
3e17226d70bca16ff54647bda3444764c8062922
174b8333509496687fa9baf570b0ebe4459289fb
84c83efa85ddfa026d3db955dac212c3376bd101
93af3cd9281510c1d64d806c30b77ca508942859
32067c28ccc498b8059fb37823aedfb9a2d5527c

# 显示 master 分支历史版本，同时显示 objects
$ git rev-list master --objects
...
29885ee583595d9080b841625d7b2d16f0fb34d2 internal
81a035a831bf13dc28cb86373e23c20d48b08c7c internal/diff
05bb5447d0c6d121103ff75cfde889cd5f790794 internal/diff/diff.go
7248748b8897d3e28421387b5133632c0cd772dd internal/service
a0995fd53aeb7748b7618e5427844bbedf20c832 internal/service/diff
...
```


### git for-each-ref
查看引用列表。
<details>
<summary>命令说明（点击展开）</summary>

    usage: git for-each-ref [<options>] [<pattern>]
    or: git for-each-ref [--points-at <object>]
    or: git for-each-ref [(--merged | --no-merged) [<commit>]]
    or: git for-each-ref [--contains [<commit>]] [--no-contains [<commit>]]

        -s, --shell           quote placeholders suitably for shells
        -p, --perl            quote placeholders suitably for perl
        --python              quote placeholders suitably for python
        --tcl                 quote placeholders suitably for Tcl

        --count <n>           show only <n> matched refs
        --format <format>     format to use for the output
        --color[=<when>]      respect format colors
        --sort <key>          field name to sort on
        --points-at <object>  print only refs which points at the given object
        --merged <commit>     print only refs that are merged
        --no-merged <commit>  print only refs that are not merged
        --contains <commit>   print only refs which contain the commit
        --no-contains <commit>
                            print only refs which don't contain the commit
        --ignore-case         sorting and filtering are case insensitive

</details>
</br>

```bash
$ git for-each-ref
ccbe4719bd6d81a40343a97cfb49a094af30ccaf commit refs/heads/master
ccbe4719bd6d81a40343a97cfb49a094af30ccaf commit refs/remotes/origin/HEAD
785b6024cfa7e95359eb5b0fe8cfc7c8e6c4905e commit refs/remotes/origin/cmn/config-snapshot
b63157de51a6caeffe067d3410b0a3f375b94390 commit refs/remotes/origin/cmn/go-http
...... # 省略
ccbe4719bd6d81a40343a97cfb49a094af30ccaf commit refs/tags/v31.3.0
```

### git var
查看 Git 当前生效的变量。
<details>
<summary>命令说明（点击展开）</summary>

usage: git var (-l | <variable>)
</details>
</br>

```bash
$ git var -l
credential.helper=osxkeychain
color.ui=auto
# 省略
alias.co=checkout
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
core.ignorecase=true
core.precomposeunicode=true
GIT_COMMITTER_IDENT=xiaowenxia <775117471@qq.com> 1607157829 +0800
GIT_AUTHOR_IDENT=xiaowenxia <775117471@qq.com> 1607157829 +0800
GIT_EDITOR=vi
GIT_PAGER=less
```

### git diff-tree

比较 2 个tree 对象 的差异并格式化输出。

<details>
<summary>命令说明（点击展开）</summary>

    usage: git diff-tree [--stdin] [-m] [-c] [--cc] [-s] [-v] [--pretty] [-t] [-r] [--root] [<common-diff-options>] <tree-ish> [<tree-ish>] [<path>...]
    -r            diff recursively
    --root        include the initial commit as diff against /dev/null

    common diff options:
    -z            output diff-raw with lines terminated with NUL.
    -p            output patch format.
    -u            synonym for -p.
    --patch-with-raw
                    output both a patch and the diff-raw format.
    --stat        show diffstat instead of patch.
    --numstat     show numeric diffstat instead of patch.
    --patch-with-stat
                    output a patch and prepend its diffstat.
    --name-only   show only names of changed files.
    --name-status show names and status of changed files.
    --full-index  show full object name on index lines.
    --abbrev=<n>  abbreviate object names in diff-tree header and diff-raw.
    -R            swap input file pairs.
    -B            detect complete rewrites.
    -M            detect renames.
    -C            detect copies.
    --find-copies-harder
                    try unchanged files as candidate for copy detection.
    -l<n>         limit rename attempts up to <n> paths.
    -O<file>      reorder diffs according to the <file>.
    -S<string>    find filepair whose only one side contains the string.
    --pickaxe-all
                    show all files diff when -S is used and hit is found.
    -a  --text    treat all files as text.

</details>
</br>

```bash
git diff-tree a0e96b5ee9f1a3a73f340ff7d1d6fe2031291bb0^{tree} 523d41ce82ea993e7c7df8be1292b2eac84d4659^{tree}
:100644 000000 5664e303b5dc2e9ef8e14a0845d9486ec1920afd 0000000000000000000000000000000000000000 D	README.md
:040000 000000 39fb0fbcac51f66b514fbd589a5b2bc0809ce664 0000000000000000000000000000000000000000 D	doc
:100644 100644 aec2e48cbf0a881d893ccdd9c0d4bbaf011b5b23 6fb38b7118b554886e96fa736051f18d63a80c85 M	file.txt
```

### git merge-base
为合并找到共同祖先。

<details>
<summary>命令说明（点击展开）</summary>
    usage: git merge-base [-a | --all] <commit> <commit>...
    or: git merge-base [-a | --all] --octopus <commit>...
    or: git merge-base --independent <commit>...
    or: git merge-base --is-ancestor <commit> <commit>
    or: git merge-base --fork-point <ref> [<commit>]

        -a, --all             output all common ancestors
        --octopus             find ancestors for a single n-way merge
        --independent         list revs not reachable from others
        --is-ancestor         is the first one ancestor of the other?
        --fork-point          find where <commit> forked from reflog of <ref>

</details>
</br>

```bash

```

### git ref-log
查看引用变更日志。

<details>
<summary>命令说明（点击展开）</summary>
    usage: git reflog [ show | expire | delete | exists ]

</details>
</br>

```bash
$ git reflog
2c5b80 (HEAD -> main, origin/main, origin/HEAD) HEAD@{0}: commit: Update git commands
539f806 HEAD@{1}: reset: moving to HEAD^
bdff99c HEAD@{2}: commit: first commit
539f806 HEAD@{3}: commit: add git-draw
f5993a4 HEAD@{4}: commit: Add git-draw
83c61eb HEAD@{5}: commit: Update readme.md
```

### git blame
显示文件的每一个修改版本和作者。

<details>
<summary>命令说明（点击展开）</summary>
    usage: git blame [<options>] [<rev-opts>] [<rev>] [--] <file>

        <rev-opts> are documented in git-rev-list(1)

        --incremental         Show blame entries as we find them, incrementally
        -b                    Show blank SHA-1 for boundary commits (Default: off)
        --root                Do not treat root commits as boundaries (Default: off)
        --show-stats          Show work cost statistics
        --progress            Force progress reporting
        --score-debug         Show output score for blame entries
        -f, --show-name       Show original filename (Default: auto)
        -n, --show-number     Show original linenumber (Default: off)
        -p, --porcelain       Show in a format designed for machine consumption
        --line-porcelain      Show porcelain format with per-line commit information
        -c                    Use the same output mode as git-annotate (Default: off)
        -t                    Show raw timestamp (Default: off)
        -l                    Show long commit SHA1 (Default: off)
        -s                    Suppress author name and timestamp (Default: off)
        -e, --show-email      Show author email instead of name (Default: off)
        -w                    Ignore whitespace differences
        --indent-heuristic    Use an experimental heuristic to improve diffs
        --minimal             Spend extra cycles to find better match
        -S <file>             Use revisions from <file> instead of calling git-rev-list
        --contents <file>     Use <file>'s contents as the final image
        -C[<score>]           Find line copies within and across files
        -M[<score>]           Find line movements within and across files
        -L <n,m>              Process only line range n,m, counting from 1
        --abbrev[=<n>]        use <n> digits to display SHA-1s

</details>
</br>

```bash
$ git blame git-refs.md
834afb32 (xiaowenxia 2020-11-02 15:09:43 +0800  1) 
a5cbb594 (xiaowenxia 2020-12-07 10:06:34 +0800  2) Git 引用本质上是指向特定的 commit 对象，git 默认情况下都会有一个 master 引用，指向一个默认的分支。
a5cbb594 (xiaowenxia 2020-12-07 10:06:34 +0800  3) > github 上已经把默认的分支从 `master` 改成了 `main` 分支。
a5cbb594 (xiaowenxia 2020-12-07 10:06:34 +0800  4) 
a5cbb594 (xiaowenxia 2020-12-07 10:06:34 +0800  5) Git 还存在一个 `HEAD` 引用，代表当前工作的 tree。
a5cbb594 (xiaowenxia 2020-12-07 10:06:34 +0800  6) 
a5cbb594 (xiaowenxia 2020-12-07 10:06:34 +0800  7) 
834afb32 (xiaowenxia 2020-11-02 15:09:43 +0800  8) ```
834afb32 (xiaowenxia 2020-11-02 15:09:43 +0800  9) $ tree .git/refs
834afb32 (xiaowenxia 2020-11-02 15:09:43 +0800 10) .git/refs
834afb32 (xiaowenxia 2020-11-02 15:09:43 +0800 11) ├── heads
834afb32 (xiaowenxia 2020-11-02 15:09:43 +0800 12) │   └── master
```

### git check-attr
查看文件属性。

<details>
<summary>命令说明（点击展开）</summary>
usage: git check-attr [-a | --all | <attr>...] [--] <pathname>...
   or: git check-attr --stdin [-z] [-a | --all | <attr>...]

    -a, --all             report all attributes set on file
    --cached              use .gitattributes only from the index
    --stdin               read file names from stdin
    -z                    terminate input and output records by a NUL character

</details>
</br>

```bash
# 待补充
```

### git count-objects


<details>
<summary>命令说明（点击展开）</summary>
usage: git count-objects [-v] [-H | --human-readable]

    -v, --verbose         be verbose
    -H, --human-readable  print sizes in human readable format

</details>
</br>

```bash
$ git count-objects
235 objects, 2220 kilobytes
# 方便阅读
$ git count-objects -H
235 objects, 2.17 MiB
# 详细
$ git count-objects -Hv
count: 235
size: 2.17 MiB
in-pack: 4
packs: 1
size-pack: 2.42 KiB
prune-packable: 0
garbage: 0
size-garbage: 0 bytes
```

### git fsck
校验对象链表的正确性和有效性。

<details>
<summary>命令说明（点击展开）</summary>
usage: git fsck [<options>] [<object>...]

    -v, --verbose         be verbose
    --unreachable         show unreachable objects
    --dangling            show dangling objects
    --tags                report tags
    --root                report root nodes
    --cache               make index objects head nodes
    --reflogs             make reflogs head nodes (default)
    --full                also consider packs and alternate objects
    --connectivity-only   check only connectivity
    --strict              enable more strict checking
    --lost-found          write dangling objects in .git/lost-found
    --progress            show progress
    --name-objects        show verbose names for reachable objects

</details>
</br>

```bash
# 当前git仓库是正确的
$ git fsck
Checking object directories: 100% (256/256), done.
dangling tree 4b825dc642cb6eb9a060e54bf8d69288fbee4904
# 查看对象
$ find .git/objects -type f
.git/objects/60/8aeb44e919e3ed8264754851557b6f6f70fec8
.git/objects/5a/3c92d2bc9622c5153110fd1ff1ec43646f2d52
.git/objects/0f/9323931dbf812ac2d08afa6b094e17b60d2872
.git/objects/30/13a8b53d3b92eb18c04e35e0757cfc29df9677
.git/objects/2b/3f5d9b0f1a4381742cea304817c10a229cc53b
.git/objects/34/dc7b21ed0493fd35da77730034967dce88fdc4
.git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904
# 改变其中一个对象
$ echo "" > .git/objects/60/8aeb44e919e3ed8264754851557b6f6f70fec8
# 检查对象链表发现有错误
$ git fsck
error: unable to unpack header of .git/objects/60/8aeb44e919e3ed8264754851557b6f6f70fec8
error: 608aeb44e919e3ed8264754851557b6f6f70fec8: object corrupt or missing: .git/objects/60/8aeb44e919e3ed8264754851557b6f6f70fec8
Checking object directories: 100% (256/256), done.
error: unable to unpack 608aeb44e919e3ed8264754851557b6f6f70fec8 header
error: unable to unpack 608aeb44e919e3ed8264754851557b6f6f70fec8 header
fatal: loose object 608aeb44e919e3ed8264754851557b6f6f70fec8 (stored in .git/objects/60/8aeb44e919e3ed8264754851557b6f6f70fec8) is corrupt
```
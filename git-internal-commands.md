# git 底层命令

<a name="OS6wF"></a>
## 目录
* [git cat-file](#git-cat-file)
* [git ls-files](#git-ls-files)
* [git ls-tree](#git-ls-tree)
* [git read-tree](#git-read-tree)
* [git gc](#git-gc)
* [git verify-pack](#git-verify-pack)
* [git hash-object](#git-hash-object)
* [git show-index](#git-show-index)
* [git show-ref](#git-show-ref)
* [git update-ref](#git-update-ref)
* [git rev-parse](#git-rev-parse)

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
$ echo "test" | git hash-object --stdin
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

</details>
</br>

```bash
$ git for-each-ref
ccbe4719bd6d81a40343a97cfb49a094af30ccaf commit refs/heads/master
ccbe4719bd6d81a40343a97cfb49a094af30ccaf commit refs/remotes/origin/HEAD
785b6024cfa7e95359eb5b0fe8cfc7c8e6c4905e commit refs/remotes/origin/cmn/config-snapshot
b63157de51a6caeffe067d3410b0a3f375b94390 commit refs/remotes/origin/cmn/go-http
a333fd9a49b14bd329ee02d9bdf6968ba3847ffd commit refs/remotes/origin/cmn/oid-copies
519b8e16d67d00cc20e4cfcdcd3382e85bf42e5f commit refs/remotes/origin/cmn/pointer-indirection
92bb4425bc968f47d1ca632caae6d1334ca79338 commit refs/remotes/origin/cmn/remote-callbacks
f13b40445ece7fcbb6149d10ea70148ea7bad5a3 commit refs/remotes/origin/cmn/remotes-ng
0d3b5bd5511b59375464ee0ab63f6d5aa65a7471 commit refs/remotes/origin/cmn/tls-stream
1eeddfa291ecbeb1ef0283bf51718763ac9e58ff commit refs/remotes/origin/cmn/tree-parse-go
ccbe4719bd6d81a40343a97cfb49a094af30ccaf commit refs/remotes/origin/master
5d0a4c752a74258a5f42e40fccd2908ac4e336b8 commit refs/remotes/origin/next
4aa4dc05ded5c4a8918490de80a6bec44ac7062a commit refs/remotes/origin/release-0.22
a5764fdd237616aeefecbf5e0a630369f747fa94 commit refs/remotes/origin/release-0.23
1b45e29af5f39766262cf2f49e01f320d728bea2 commit refs/remotes/origin/release-0.24
334260d743d713a55ff3c097ec6707f2bb39e9d5 commit refs/remotes/origin/release-0.25
c9f7fd544d3991bd26c400b3c227673bcada42cc commit refs/remotes/origin/release-0.26
800edc61bf1616f10c5182ddea7c752dee07a6d4 commit refs/remotes/origin/release-0.27
b00c365f5027bb500db7b00579fd23e0e7e8417f commit refs/remotes/origin/release-0.28
0843b826d219b16d55d3bb7fffbb5fb3fbbf82f8 commit refs/remotes/origin/release-0.99
2bf0e14e9ed02e22edbddfeec1658f6069546dd9 commit refs/remotes/origin/release-1.0
ad3ec3664d54779c4c2e49e41f85e886fbff343c commit refs/remotes/origin/release-1.1
b60db7feec4dad0e865518893516315bbcf6bd22 commit refs/remotes/origin/remotes
16ef893af9de00c4633e48fcfae2c32809ce63ee commit refs/remotes/origin/revwalk
41ad00f868e7dfcdb04c7538f27350d400f710a3 commit refs/remotes/origin/v22
fa644d2fc9efa3baee93b525212d76dfa17a5db5 commit refs/remotes/origin/v23
22091886372e73de5d66168e8665775676ec13c5 commit refs/remotes/origin/v24
334260d743d713a55ff3c097ec6707f2bb39e9d5 commit refs/remotes/origin/v25
c9f7fd544d3991bd26c400b3c227673bcada42cc commit refs/remotes/origin/v26
6cc7d3dc6aec2781fe0239315da215f49c76e2f8 commit refs/remotes/origin/v27
7694d5f5fcef65ca981eb66d803d34b464a4aa14 commit refs/remotes/origin/v28
e662016367f851f9a8c2b32028b0c91f0f514608 commit refs/remotes/origin/winfix
6ee3a5f5896cf88a937d107ba6fe89afbd89eecd commit refs/tags/v0.27.10
b1eec9a4662a2e64953aa83365f84f5c773b6399 commit refs/tags/v0.28.4
437c7c33440da8b0c96734054c77bfadf72e80d2 commit refs/tags/v0.28.4.1
7694d5f5fcef65ca981eb66d803d34b464a4aa14 commit refs/tags/v0.28.5
5d6404f309aa42d0292792c4cf97270725827513 commit refs/tags/v22.3.0
a6ef0d4521e1938c44ea08f16404c91748ec4656 commit refs/tags/v23.4.0
51063a965b098b6d2ebac977bb75055e06ed5913 commit refs/tags/v24.6.0
334260d743d713a55ff3c097ec6707f2bb39e9d5 commit refs/tags/v25.1.0
c9f7fd544d3991bd26c400b3c227673bcada42cc commit refs/tags/v26.8.0
6cc7d3dc6aec2781fe0239315da215f49c76e2f8 commit refs/tags/v27.10.0
6453cf9f8ada2ca65ff48b515d2160cab2c8c987 commit refs/tags/v27.11.0
0430fd700c88953686644dd27c0b39a8a5ef9f41 commit refs/tags/v27.11.1
7b9a768b08984dd81922560c995e567944ffddbb commit refs/tags/v27.11.10
4d690277874bce93e81a1f1a12c9ec9ba3daca0f commit refs/tags/v27.11.2
9912ed9742b906725971b140d5939077c36dc384 commit refs/tags/v27.11.3
3d80bd22ad0f884d94733d06c446bb5e3411fa31 commit refs/tags/v27.11.4
627f58d4038cdbc20a1ea96dc43ee06709528d2f commit refs/tags/v27.11.5
a81a08606fb54ba61c0179739b793ec8fbc3558b commit refs/tags/v27.11.6
6cb9c7cf4136c14b59768c81a4e623b89f5eaeff commit refs/tags/v27.11.7
27f87bd821239fda40db72790d2eca4bde9e3ac0 commit refs/tags/v27.11.8
f58d71b8a9228a1d1a1966c0dcd4a3a63e8a7439 commit refs/tags/v27.11.9
800edc61bf1616f10c5182ddea7c752dee07a6d4 commit refs/tags/v27.12.0
7694d5f5fcef65ca981eb66d803d34b464a4aa14 commit refs/tags/v28.4.0
20c6fefa56286d9264694ca0937115ada12bc472 commit refs/tags/v28.5.0
a3140afde20ad746ae58241be2534a5640a3cc68 commit refs/tags/v28.5.1
6badd3d00d3b832f0e3cb9a21150a1e3e1771742 commit refs/tags/v28.5.10
2870fabe227bfed22769bac9c80fd8f29a9ba39d commit refs/tags/v28.5.11
61ea21fbd6dda3a701c43ec0394edfb984e61f3a commit refs/tags/v28.5.2
4883fbe87201c5aba92be18d54fd786072076e56 commit refs/tags/v28.5.3
fb4e5911aaa2e298903374378777cef46bb6d0db commit refs/tags/v28.5.4
1cf6bf83143b08e359185dca12b883872b526f57 commit refs/tags/v28.5.5
3fcab7513d02572ec18409515370c617f8cbcc3c commit refs/tags/v28.5.6
4b27f5c4301d73891d116eeb5333f78e31ae582e commit refs/tags/v28.5.7
b6212551e2735745387db173bfcae918760af370 commit refs/tags/v28.5.8
8b6f3d805664c4df49ffc6ffa42026d21ce4fa24 commit refs/tags/v28.5.9
c18989f6529eb494fad15bcb629c7248e05292b6 commit refs/tags/v28.6.0
bd9b40fc67ab760f9458b52d470d878271849954 commit refs/tags/v28.6.1
b00c365f5027bb500db7b00579fd23e0e7e8417f commit refs/tags/v28.7.0
e10c2eeef23d05e0ce12061bb535132f37e6d457 commit refs/tags/v29.0.0
a32375a86063768507a01b32cc3d868f4c2ffa9c commit refs/tags/v29.0.1
0843b826d219b16d55d3bb7fffbb5fb3fbbf82f8 commit refs/tags/v29.0.2
13ca96065e6be3292c931cc580bbc125962b394e commit refs/tags/v30.0.0
91d08450b68efc8ef5bd5bfee29e813ca5829229 commit refs/tags/v30.0.1
7e726fda6ec2b5d773e5a8b54ed06378a53c0f7f commit refs/tags/v30.0.10
3c5c580d78831d10e082743f3783424b72ac9e09 commit refs/tags/v30.0.11
f3a746d7b6a27a9d6f98143641466f68ef1f3dee commit refs/tags/v30.0.12
111185838cebe3415e47c75e67fb81295952ce68 commit refs/tags/v30.0.13
37b81b61f16f4bdf891a54dc8311bd5d2236e329 commit refs/tags/v30.0.14
5b6ce70b8997254ce48f8c24ba4198080e646fdd commit refs/tags/v30.0.15
3a4204bd934b59a55581d33d300617a4f621257f commit refs/tags/v30.0.16
10d5ebf231bdc37293235a6fc2bdf94fd25d0c56 commit refs/tags/v30.0.17
f83530b18dc46867ed06fc261b309b8b545a3b6f commit refs/tags/v30.0.18
8b51d0db8e40e97283b771a5a51b13bea4651f81 commit refs/tags/v30.0.2
31f877e249e28c29cc4fcd512381a5a5b26e59d9 commit refs/tags/v30.0.3
9eaf4fed5f4f2361898f9da8345b34886076bfc2 commit refs/tags/v30.0.4
20a55cdf92f4ad6af4110861811a7076056cdf36 commit refs/tags/v30.0.5
fc6eaf36388841b16ff004e1d48e887d3f9613dc commit refs/tags/v30.0.6
2ac9f4e69bd57a686d15176d199a3c9cc4a6bb91 commit refs/tags/v30.0.7
7883ec85de56ee55667481228282fd690fce6246 commit refs/tags/v30.0.8
7d4453198b55ecc2d9e09b64352edecb5db8b6ef commit refs/tags/v30.0.9
bcfa2568377b4cc52d28cf63e1256cec756781a5 commit refs/tags/v30.1.0
2bf0e14e9ed02e22edbddfeec1658f6069546dd9 commit refs/tags/v30.2.0
ad3ec3664d54779c4c2e49e41f85e886fbff343c commit refs/tags/v31.0.0
c3664193f3c05bd6ae48f153c6c41cd7d7a3d98b commit refs/tags/v31.1.0
77460dd7f0fb4108e22681ac1efc3e0fd52093a6 commit refs/tags/v31.1.1
b46ebfab8c11a551db58858bb00aeebc1faf41b3 commit refs/tags/v31.2.0
ccbe4719bd6d81a40343a97cfb49a094af30ccaf commit refs/tags/v31.3.0
```
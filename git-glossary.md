## Git 术语
> 翻译自 [Git Glossary](https://git-scm.com/docs/gitglossary)。

#### alternate object database
Via the alternates mechanism, a repository can inherit part of its object database from another object database, which is called an "alternate".

#### bare repository
空仓库，刚初始化完的仓库。

#### blob object
数据对象，存储当前版本下的文件内容。

#### branch
分支，代表当前时间线的开发代码。

#### cache
git 初期的叫法，现在叫索引（index）。

#### chain
commit 链，这些链则组成一个个分支。

#### changeset
BitKeeper/cvsps 对 提交（commit）的叫法。

#### checkout
从 git 文件系统中检出对应的版本或文件到工作目录，如果检出的是分支则会更新索引（index）和 HEAD。

#### cherry-picking
提取某些 commit 到当前分支。

#### clean
清理当前工作区。

#### commit
提交。

#### commit object
一次提交会生成一份 commit 对象，该对象包括committer、 author、date、 tree-id 等信息。

#### commit-ish (also committish)
A commit object or an object that can be recursively dereferenced to a commit object. The following are all commit-ishes: a commit object, a tag object that points to a commit object, a tag object that points to a tag object that points to a commit object, etc.

#### core Git
git 底层的数据结构和对象，以及很丰富的底层命令。


#### DAG
Directed acyclic graph. The commit objects form a directed acyclic graph, because they have parents (directed), and the graph of commit objects is acyclic (there is no chain which begins and ends with the same object).

#### dangling object
An unreachable object which is not reachable even from other unreachable objects; a dangling object has no references to it from any reference or object in the repository.

#### detached HEAD
Normally the HEAD stores the name of a branch, and commands that operate on the history HEAD represents operate on the history leading to the tip of the branch the HEAD points at. However, Git also allows you to check out an arbitrary commit that isn’t necessarily the tip of any particular branch. The HEAD in such a state is called "detached".

Note that commands that operate on the history of the current branch (e.g. git commit to build a new history on top of it) still work while the HEAD is detached. They update the HEAD to point at the tip of the updated history without affecting any branch. Commands that update or inquire information about the current branch (e.g. git branch --set-upstream-to that sets what remote-tracking branch the current branch integrates with) obviously do not work, as there is no (real) current branch to ask about in this state.

#### directory
目录。

#### dirty
工作区有改动没有提交，该工作区则为 `dirty` 状态。

#### evil merge
An evil merge is a merge that introduces changes that do not appear in any parent.

#### fast-forward
A fast-forward is a special type of merge where you have a revision and you are "merging" another branch's changes that happen to be a descendant of what you have. In such a case, you do not make a new merge commit but instead just update to his revision. This will happen frequently on a remote-tracking branch of a remote repository.

#### fetch
从远程仓库拉取最新分支。

#### file system

Linus Torvalds 一开始设计 Git 的时候，定位就是一个用户空间的文件系统，然后提供高效的命令和方法用于操作这个文件系统。

#### Git archive

对于一些人来讲，这是 repository 的同义词。

#### gitfile
.git 是一个工作区根目录的空文件，指向真正仓库的目录。

#### grafts
Grafts enables two otherwise different lines of development to be joined together by recording fake ancestry information for commits. This way you can make Git pretend the set of parents a commit has is different from what was recorded when the commit was created. Configured via the .git/info/grafts file.

Note that the grafts mechanism is outdated and can lead to problems transferring objects between repositories; see git-replace[1] for a more flexible and robust system to do the same thing.

#### hash
Git 的对象名称都是对象内容的 hash 值。

#### head
指向分支的最新提交。

#### HEAD
指向当前分支。

#### head ref
head 的别名。

#### hook
git 钩子。

#### index
索引文件。

#### index entry
The information regarding a particular file, stored in the index. An index entry can be unmerged, if a merge was started, but not yet finished (i.e. if the index contains multiple versions of that file).

#### master
git 默认的分支。git 仓库初始化时默认会创建该分支。

#### merge
As a verb: To bring the contents of another branch (possibly from an external repository) into the current branch. In the case where the merged-in branch is from a different repository, this is done by first fetching the remote branch and then merging the result into the current branch. This combination of fetch and merge operations is called a pull. Merging is performed by an automatic process that identifies changes made since the branches diverged, and then applies all those changes together. In cases where changes conflict, manual intervention may be required to complete the merge.

As a noun: unless it is a fast-forward, a successful merge results in the creation of a new commit representing the result of the merge, and having as parents the tips of the merged branches. This commit is referred to as a "merge commit", or sometimes just a "merge".

#### object
git 的 存储单元，git 的底层文件系统都是一个个对象，包括 blob 对象、tree 对象、commit 对象、tag 对象等。

#### object database
存储一组对象。

#### object identifier
和 `object name` 一样。

#### object name
对象的名称即对象的 hash 值。

#### object type
对象类型，分别有 "commit", "tree", "tag", "blob"。

#### octopus
merge 超过 2 个分支。

#### origin
上游默认仓库。

#### overlay
Only update and add files to the working directory, but don’t delete them, similar to how cp -R would update the contents in the destination directory. This is the default mode in a checkout when checking out files from the index or a tree-ish. In contrast, no-overlay mode also deletes tracked files not present in the source, similar to rsync --delete.

#### pack
用于压缩存储一组对象。

#### pack index
压缩存储一组对象时，使用 `pack index` 存储对象的索引和信息。

#### pathspec
Pattern used to limit paths in Git commands.

Pathspecs are used on the command line of "git ls-files", "git ls-tree", "git add", "git grep", "git diff", "git checkout", and many other commands to limit the scope of operations to some subset of the tree or worktree. See the documentation of each command for whether paths are relative to the current directory or toplevel. The pathspec syntax is as follows:

any path matches itself

the pathspec up to the last slash represents a directory prefix. The scope of that pathspec is limited to that subtree.

the rest of the pathspec is a pattern for the remainder of the pathname. Paths relative to the directory prefix will be matched against that pattern using fnmatch(3); in particular, * and ? can match directory separators.

For example, Documentation/*.jpg will match all .jpg files in the Documentation subtree, including Documentation/chapter_1/figure_1.jpg.

A pathspec that begins with a colon : has special meaning. In the short form, the leading colon : is followed by zero or more "magic signature" letters (which optionally is terminated by another colon :), and the remainder is the pattern to match against the path. The "magic signature" consists of ASCII symbols that are neither alphanumeric, glob, regex special characters nor colon. The optional colon that terminates the "magic signature" can be omitted if the pattern begins with a character that does not belong to "magic signature" symbol set and is not a colon.

In the long form, the leading colon : is followed by an open parenthesis (, a comma-separated list of zero or more "magic words", and a close parentheses ), and the remainder is the pattern to match against the path.

A pathspec with only a colon means "there is no pathspec". This form should not be combined with other pathspec.

#### top
The magic word top (magic signature: /) makes the pattern match from the root of the working tree, even when you are running the command from inside a subdirectory.

#### literal
Wildcards in the pattern such as * or ? are treated as literal characters.

#### icase
Case insensitive match.

#### glob
Git treats the pattern as a shell glob suitable for consumption by fnmatch(3) with the FNM_PATHNAME flag: wildcards in the pattern will not match a / in the pathname. For example, "Documentation/*.html" matches "Documentation/git.html" but not "Documentation/ppc/ppc.html" or "tools/perf/Documentation/perf.html".

Two consecutive asterisks ("**") in patterns matched against full pathname may have special meaning:

A leading "**" followed by a slash means match in all directories. For example, "**/foo" matches file or directory "foo" anywhere, the same as pattern "foo". "**/foo/bar" matches file or directory "bar" anywhere that is directly under directory "foo".

A trailing "/**" matches everything inside. For example, "abc/**" matches all files inside directory "abc", relative to the location of the .gitignore file, with infinite depth.

A slash followed by two consecutive asterisks then a slash matches zero or more directories. For example, "a/**/b" matches "a/b", "a/x/b", "a/x/y/b" and so on.

Other consecutive asterisks are considered invalid.

Glob magic is incompatible with literal magic.

#### attr
After attr: comes a space separated list of "attribute requirements", all of which must be met in order for the path to be considered a match; this is in addition to the usual non-magic pathspec pattern matching. See gitattributes[5].

Each of the attribute requirements for the path takes one of these forms:

"ATTR" requires that the attribute ATTR be set.

"-ATTR" requires that the attribute ATTR be unset.

"ATTR=VALUE" requires that the attribute ATTR be set to the string VALUE.

"!ATTR" requires that the attribute ATTR be unspecified.

Note that when matching against a tree object, attributes are still obtained from working tree, not from the given tree object.

#### exclude
After a path matches any non-exclude pathspec, it will be run through all exclude pathspecs (magic signature: ! or its synonym ^). If it matches, the path is ignored. When there is no non-exclude pathspec, the exclusion is applied to the result set as if invoked without any pathspec.

#### parent
A commit object contains a (possibly empty) list of the logical predecessor(s) in the line of development, i.e. its parents.

#### pickaxe
The term pickaxe refers to an option to the diffcore routines that help select changes that add or delete a given text string. With the --pickaxe-all option, it can be used to view the full changeset that introduced or removed, say, a particular line of text. See git-diff[1].

#### plumbing
core Git 的别名。

#### porcelain
Cute name for programs and program suites depending on core Git, presenting a high level access to core Git. Porcelains expose more of a SCM interface than the plumbing.

#### per-worktree ref
Refs that are per-worktree, rather than global. This is presently only HEAD and any refs that start with refs/bisect/, but might later include other unusual refs.

#### pseudoref
Pseudorefs are a class of files under $GIT_DIR which behave like refs for the purposes of rev-parse, but which are treated specially by git. Pseudorefs both have names that are all-caps, and always start with a line consisting of a SHA-1 followed by whitespace. So, HEAD is not a pseudoref, because it is sometimes a symbolic ref. They might optionally contain some additional data. MERGE_HEAD and CHERRY_PICK_HEAD are examples. Unlike per-worktree refs, these files cannot be symbolic refs, and never have reflogs. They also cannot be updated through the normal ref update machinery. Instead, they are updated by directly writing to the files. However, they can be read as if they were refs, so git rev-parse MERGE_HEAD will work.

#### pull
pull 分支时，会先拉取（fetch）然后再覆盖（merge）。

#### push
把当前的本地仓库版本提交到远程仓库。

#### reachable
All of the ancestors of a given commit are said to be "reachable" from that commit. More generally, one object is reachable from another if we can reach the one from the other by a chain that follows tags to whatever they tag, commits to their parents or trees, and trees to the trees or blobs that they contain.

#### rebase
To reapply a series of changes from a branch to a different base, and reset the head of that branch to the result.

#### ref
A name that begins with refs/ (e.g. refs/heads/master) that points to an object name or another ref (the latter is called a symbolic ref). For convenience, a ref can sometimes be abbreviated when used as an argument to a Git command; see gitrevisions[7] for details. Refs are stored in the repository.

The ref namespace is hierarchical. Different subhierarchies are used for different purposes (e.g. the refs/heads/ hierarchy is used to represent local branches).

There are a few special-purpose refs that do not begin with refs/. The most notable example is HEAD.

#### reflog
显示 ref 的变更日志。

#### refspec
A "refspec" is used by fetch and push to describe the mapping between remote ref and local ref.

#### remote repository
远程仓库。

#### remote-tracking branch
A ref that is used to follow changes from another repository. It typically looks like refs/remotes/foo/bar (indicating that it tracks a branch named bar in a remote named foo), and matches the right-hand-side of a configured fetch refspec. A remote-tracking branch should not contain direct modifications or have local commits made to it.

#### repository
代码仓库。

#### resolve
The action of fixing up manually what a failed automatic merge left behind.

#### revision
用于定位版本。

#### rewind
To throw away part of the development, i.e. to assign the head to an earlier revision.

#### SCM
源码管理工具。

#### SHA-1
git 默认使用 `SHA-1` 来对对象或内容做hash运算。

#### shallow clone
Mostly a synonym to shallow repository but the phrase makes it more explicit that it was created by running git clone --depth=... command.

#### shallow repository
A shallow repository has an incomplete history some of whose commits have parents cauterized away (in other words, Git is told to pretend that these commits do not have the parents, even though they are recorded in the commit object). This is sometimes useful when you are interested only in the recent history of a project even though the real history recorded in the upstream is much larger. A shallow repository is created by giving the --depth option to git-clone[1], and its history can be later deepened with git-fetch[1].

#### stash entry
An object used to temporarily store the contents of a dirty working directory and the index for future reuse.

#### submodule
子仓库，可以用来做多仓库集成。

#### superproject
A repository that references repositories of other projects in its working tree as submodules. The superproject knows about the names of (but does not hold copies of) commit objects of the contained submodules.

#### symref
Symbolic reference: instead of containing the SHA-1 id itself, it is of the format ref: refs/some/thing and when referenced, it recursively dereferences to this reference. HEAD is a prime example of a symref. Symbolic references are manipulated with the git-symbolic-ref[1] command.

#### tag
A ref under refs/tags/ namespace that points to an object of an arbitrary type (typically a tag points to either a tag or a commit object). In contrast to a head, a tag is not updated by the commit command. A Git tag has nothing to do with a Lisp tag (which would be called an object type in Git’s context). A tag is most typically used to mark a particular point in the commit ancestry chain.

#### tag object
An object containing a ref pointing to another object, which can contain a message just like a commit object. It can also contain a (PGP) signature, in which case it is called a "signed tag object".

#### topic branch
A regular Git branch that is used by a developer to identify a conceptual line of development. Since branches are very easy and inexpensive, it is often desirable to have several small branches that each contain very well defined concepts or small incremental yet related changes.

#### tree
工作树（working tree）或tree对象。

#### tree object
tree 对象，存储一组blob对象，相当于存储目录。

#### tree-ish (also treeish)
A tree object or an object that can be recursively dereferenced to a tree object. Dereferencing a commit object yields the tree object corresponding to the revision's top directory. The following are all tree-ishes: a commit-ish, a tree object, a tag object that points to a tree object, a tag object that points to a tag object that points to a tree object, etc.

#### unmerged index
An index which contains unmerged index entries.

#### unreachable object
An object which is not reachable from a branch, tag, or any other reference.

#### upstream branch
The default branch that is merged into the branch in question (or the branch in question is rebased onto). It is configured via branch.<name>.remote and branch.<name>.merge. If the upstream branch of A is origin/B sometimes we say "A is tracking origin/B".

#### working tree
工作区。
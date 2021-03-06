## Git 的一些环境变量
> 参考：https://git-scm.com/book/zh/v2/Git-%E5%86%85%E9%83%A8%E5%8E%9F%E7%90%86-%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F 和 https://git-scm.com/docs/git#_environment_variables 。
#### GIT_TRACE
GIT_TRACE=1 可以显示具体的git内部执行过程，比如：

```bash
# 查看 git pull 的执行过程
$ GIT_TRACE=1 git pull
10:15:16.423653 git.c:344               trace: built-in: git pull
10:15:16.424388 run-command.c:646       trace: run_command: git fetch --update-head-ok
10:15:16.425853 git.c:344               trace: built-in: git fetch --update-head-ok
10:15:16.426444 run-command.c:646       trace: run_command: unset GIT_DIR GIT_PREFIX; ssh git@gitlab.alibaba-inc.com 'git-upload-pack '''agit/galileo.git''''
10:15:16.883780 run-command.c:646       trace: run_command: git rev-list --objects --stdin --not --all --quiet
10:15:16.886473 run-command.c:646       trace: run_command: git rev-list --objects --stdin --not --all --quiet
10:15:16.888001 git.c:344               trace: built-in: git rev-list --objects --stdin --not --all --quiet
10:15:16.926434 run-command.c:1569      run_processes_parallel: preparing to run up to 1 tasks
10:15:16.926536 run-command.c:1601      run_processes_parallel: done
10:15:16.926622 run-command.c:646       trace: run_command: git gc --auto
10:15:16.928214 git.c:344               trace: built-in: git gc --auto
10:15:16.929016 run-command.c:646       trace: run_command: git merge FETCH_HEAD
10:15:16.930404 git.c:344               trace: built-in: git merge FETCH_HEAD

# 查看 git status 的执行过程
$ GIT_TRACE=1 git st
10:18:16.275652 git.c:576               trace: exec: git-st
10:18:16.275723 run-command.c:646       trace: run_command: git-st
10:18:16.275835 git.c:274               trace: alias expansion: st => status
10:18:16.275870 git.c:576               trace: exec: git-status
10:18:16.275876 run-command.c:646       trace: run_command: git-status
10:18:16.277339 git.c:344               trace: built-in: git status
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
```

#### GIT_DIR

#### GIT_CURL_VERBOSE

#### GIT_TRACE_PACKET

#### GIT_TERMINAL_PROMPT

#### GIT_AUTHOR_DATE
#### GIT_AUTHOR_NAME
#### GIT_AUTHOR_EMAIL

#### GIT_COMMITTER_DATE
#### GIT_COMMITTER_NAME
#### GIT_COMMITTER_EMAIL
#!/usr/bin/env bash

# 当执行时使用到未定义过的变量，则显示错误信息
set -u

WORKING_DIRECTORY=${PWD}
VERBOSE=false
CASE=
HYPERFINE=hyperfine
GIT=git
TEST_REPO="unset"

# 默认不挂在 pack 路径
PACK_DIR=disabled
# 是否显示 hyperfine 的命令输出
HYPERFINE_SHOW_OUTPUT=""

# String formatting functions.
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi

tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_cyan="$(tty_mkbold 36)"
tty_yellow="$(tty_mkbold 33)"
tty_green="$(tty_mkbold 32)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

# 输出信息（带颜色）
tty_msg(){
    # 重定向不需要输出颜色
    if [ -f /dev/stdout ];then echo -en "$@" && return ;fi
    
    case "$1" in
        ERROR)
            echo -en "${tty_red}[ERROR]${tty_reset}\t${@:2}\n" ;;
        INFO)
            echo -en "${tty_green}[INFO]${tty_reset}\t${@:2}\n" ;;
        WARN)
            echo -en "${tty_yellow}[WARN]${tty_reset}\t${@:2}\n" ;;
        DEBUG)
            (
                # 展示更多输出
                if [ $VERBOSE == true ]; then
                    echo -en "${tty_underline}[DEBUG]${tty_reset}\t${@:2}\n"
                fi
                return 0
            ) ;;
        *)
            echo -en "\033[40;35m[$1]\033[0m\t${@:2}\n" ;;
    esac
}

tty_exit() {
    tty_msg ERROR $@ && exit 1
}

# 优雅取消
trap ctrl_c INT

function ctrl_c() {
    stty sane && exit
}

usage() {
    cat <<- EOF
${tty_red}Usage:${tty_reset} 
  -d: 测试的目录，这个目录在你要测试的存储介质中，没有给定则使用当前目录。
  -e: 设置测试项和测试次数，每个测试项用 / 分隔，一个测试项后面跟随 , 可以设置测试次数，比如 init,100/unpack,5 表示测试 init 5次, 测试 unpack 5次。目前包括的测试项有:
    - init: 初始化一个裸仓库。
    - unpack: 解包一个约有 5w 个对象的packfile。
    - fsck: 校验 5w 个松散对象。
    - repack_split: 对 tensorflow 做 repack ，生成多个 packfile。
    - repack_all: 对 tensorflow 做 repack ，只生成一个 packfile。
    - clone: clone 。
    - fetch: fetch 。
    - push_mirror: 推送 1w 个引用到本地仓库。
    - all: 测试所有项。
  -t: 设置 tensorflow.git 的路径。
  -p: 设置测试仓库的 objects/pack 软连接的路径，用于测试 objects/pack 软链到低价介质的性能场景。
  -v: 输出更多信息。
  -x: 显示 hyperfine 执行的命令输出。
  -h: 帮助。
EOF
    exit 1
}

while getopts "vd:he:p:xt:" o; do
    case "${o}" in
        h)
            usage ;;
        d)
            # 工作目录
            WORKING_DIRECTORY=$OPTARG ;;
        t)
            # 测试的仓库地址，默认为 ${WORKING_DIRECTORY}tensorflow.git
            TEST_REPO=$OPTARG ;;
        v)
            # 显示更多信息
            VERBOSE=true ;;
        e)
            # 选择测试例
            CASE=$OPTARG ;;
        p)
            # 仓库 objects/pack 挂载到该路径下
            PACK_DIR=$OPTARG ;;
        x)
            # hyperfine 显示命令输出 --show-output
            HYPERFINE_SHOW_OUTPUT="--show-output" ;;
        *)
            usage ;;
    esac
done
shift $((OPTIND-1))

command_exists() {
    if command -v $1 &> /dev/null; then
        return 1
    fi
    return 0
}

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

emph_red() {
  printf "${tty_red}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

emph() {
  printf "${tty_cyan}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

directory_not_available() {
  ! [[ -e "$1" ]] || ! [[ -r "$1" && -w "$1" && -x "$1" ]]
}

git_directory_not_available() {
    directory_not_available $1 || ! [[ -e "$1/HEAD" ]] || ! [[ -r "$1/HEAD" && -w "$1/HEAD" ]]
}


# check working directory
if directory_not_available ${WORKING_DIRECTORY}; then
    tty_exit "${WORKING_DIRECTORY} not exists or not writable"
fi

# check git
if command_exists ${GIT}; then 
    tty_exit "${GIT} not available"
fi

# check hyperfine
if command_exists ${HYPERFINE}; then 
    tty_exit "${HYPERFINE} not available, refer to https://github.com/sharkdp/hyperfine/releases"
fi

# exists and return runs, or return -1 if not exists
case_exists() {
    CASE_LIST=(${CASE//\// })

    for case in ${CASE_LIST[@]}; do
        opt_list=(${case//,/ })
        # 测试全部
        if [[ ${opt_list[0]} == all ]];then return 0;fi
        if [[ ${opt_list[0]} == $1 ]];then
            if [[ ${#opt_list[@]} == 2 ]]; then return ${opt_list[1]}; fi
            return 0
        fi
    done

    return -1
}

# 尽量保证 TEST_REPO 在不同的磁盘上
if [[ ${TEST_REPO} == "unset" ]]; then TEST_REPO=${WORKING_DIRECTORY}/tensorflow.git; fi
if git_directory_not_available ${TEST_REPO}; then
        tty_exit "please clone ${TEST_REPO} first: git clone https://github.com/tensorflow/tensorflow.git --bare ${TEST_REPO}"
fi

flush_cache="sync; echo 3 | sudo tee /proc/sys/vm/drop_caches"
WORKING_REPO=${WORKING_DIRECTORY}/dest.git
random_name=`date +%Y%m%d_%H%M%S%N | md5sum |cut -d" " -f1`
random_path=${PACK_DIR}/${random_name} 

REMOVE_GIT_REPO="rm -rf ${WORKING_REPO}"
if [[ $PACK_DIR != disabled ]];then
    emph_red pack random path:${random_path}
    REMOVE_GIT_REPO="rm -rf ${random_path} && rm -rf ${WORKING_REPO}"
    tty_msg DEBUG REMOVE_GIT_REPO: ${REMOVE_GIT_REPO}
fi

CREATE_GIT_REPO="${GIT} init -q --bare ${WORKING_REPO}"
if [[ $PACK_DIR != disabled ]];then
    CREATE_GIT_REPO="${GIT} init -q --bare ${WORKING_REPO} && \
rm -rf ${WORKING_REPO}/objects/pack && \
mkdir -p ${random_path} && \
ln -s  ${random_path} ${WORKING_REPO}/objects/pack"
    tty_msg DEBUG CREATE_GIT_REPO: ${CREATE_GIT_REPO}
fi

# 测试 git init

benchmark_init() {
    case_exists init
    ret=$?
    if [[ $ret == 255 ]]; then return 1; fi
    if [[ $ret == 0 ]]; then ret=100; fi

    emph "git init"
    setup=""
    prepare="${REMOVE_GIT_REPO};${flush_cache};"
    command="${CREATE_GIT_REPO}"
    cleanup="${REMOVE_GIT_REPO}"
    runs=$ret
}

# 测试 git unpack-objects
benchmark_unpack_objects() {
    case_exists unpack
    ret=$?
    if [[ $ret == 255 ]]; then return 1; fi
    if [[ $ret == 0 ]]; then ret=3; fi

    emph "git unpack-objects"
    # v0.9.0 有 53585 个对象
    packfile_prefix=`echo "v0.9.0" | ${GIT} --git-dir=${TEST_REPO} \
                        pack-objects --revs ${WORKING_DIRECTORY}/benchmark_unpack_objects -q`
    packfile=${WORKING_DIRECTORY}/benchmark_unpack_objects-${packfile_prefix}.pack

    setup=""
    prepare="${REMOVE_GIT_REPO};${CREATE_GIT_REPO};${flush_cache};"
    command="cat ${packfile} | ${GIT} --git-dir=${WORKING_REPO} unpack-objects"
    cleanup="${REMOVE_GIT_REPO};rm -rf ${WORKING_DIRECTORY}/benchmark_unpack_objects-${packfile_prefix}.*"
    runs=$ret
}

# 测试 git fsck
benchmark_fsck() {
    case_exists fsck
    ret=$?
    if [[ $ret == 255 ]]; then return 1; fi
    if [[ $ret == 0 ]]; then ret=20; fi

    emph "git fsck"

    # v0.9.0 有 53585 个对象
    packfile_prefix=`echo "v0.9.0" | ${GIT} --git-dir=${TEST_REPO} \
                        pack-objects --revs ${WORKING_DIRECTORY}/benchmark_unpack_objects -q`
    packfile=${WORKING_DIRECTORY}/benchmark_unpack_objects-${packfile_prefix}.pack

    setup="${REMOVE_GIT_REPO};${CREATE_GIT_REPO} && \
            cat ${packfile} | git --git-dir=${WORKING_REPO} unpack-objects;"
    prepare="${flush_cache};"
    command="${GIT} --git-dir=${WORKING_REPO} fsck --full"
    cleanup="${REMOVE_GIT_REPO};rm -rf ${WORKING_DIRECTORY}/benchmark_unpack_objects-${packfile_prefix}.*"
    runs=$ret
}

# 测试 git fsck
_benchmark_repack() {
    # 这里需要预先执行一次 repack
    setup="${REMOVE_GIT_REPO};${CREATE_GIT_REPO};${GIT} --git-dir=${WORKING_REPO} \
-c fetch.writePackedRefs=true \
-c fetch.unpackLimit=1 \
-c pack.window=10 \
-c pack.depth=50 \
-c pack.limitpacksize=$1 \
fetch --prune \
--end-of-options file://${TEST_REPO} +refs/*:refs/*"
    prepare="${flush_cache};"
    command="${GIT} --git-dir=${TEST_REPO} \
-c repack.writeBitmaps=false repack --max-pack-size=$1 -adf --window=10 --depth=50"
    cleanup="${REMOVE_GIT_REPO}"
    runs=$2
}

benchmark_repack_split() {
    case_exists repack_split
    ret=$?
    if [[ $ret == 255 ]]; then return 1; fi
    if [[ $ret == 0 ]]; then ret=3; fi

    emph "git repack split"
    _benchmark_repack 50m $ret
}

benchmark_repack_all() {
    case_exists repack_all
    ret=$?
    if [[ $ret == 255 ]]; then return 1; fi
    if [[ $ret == 0 ]]; then ret=3; fi

    emph "git repack all"
    _benchmark_repack 20g $ret
}


benchmark_clone() {
    case_exists clone
    ret=$?
    if [[ $ret == 255 ]]; then return 1; fi
    if [[ $ret == 0 ]]; then ret=2; fi

    emph "git clone"
    setup=""
    prepare="${REMOVE_GIT_REPO};${flush_cache};"
    command="${GIT} clone --bare file://${TEST_REPO} ${WORKING_REPO}"
    cleanup="${REMOVE_GIT_REPO}"
    runs=$ret
}

benchmark_fetch() {
    case_exists fetch
    ret=$?
    if [[ $ret == 255 ]]; then return 1; fi
    if [[ $ret == 0 ]]; then ret=2; fi

    emph "git fetch"
    setup=""
    prepare="${REMOVE_GIT_REPO};${CREATE_GIT_REPO};${flush_cache};"
    command="${GIT} --git-dir=${WORKING_REPO} \
-c fetch.writePackedRefs=true -c fetch.unpackLimit=1 fetch --prune \
--end-of-options file://${TEST_REPO} +refs/*:refs/*"
    cleanup="${REMOVE_GIT_REPO}"
    runs=$ret
}

benchmark_push_mirror() {
    case_exists push_mirror
    ret=$?
    if [[ $ret == 255 ]]; then return 1; fi
    if [[ $ret == 0 ]]; then ret=20; fi

    emph "git push --mirror"

    # 生成临时仓库
    eval ${REMOVE_GIT_REPO}
    eval ${CREATE_GIT_REPO}
    ${GIT} clone -q ${WORKING_REPO} ${WORKING_DIRECTORY}/dest && \
    date > ${WORKING_DIRECTORY}/dest/tmp && \
    ${GIT} -C ${WORKING_DIRECTORY}/dest add -A && \
    export GIT_AUTHOR_NAME="hello" GIT_AUTHOR_EMAIL="hello@world" GIT_COMMITTER_NAME="hello" GIT_COMMITTER_EMAIL="hello@world" && \
    ${GIT} -C ${WORKING_DIRECTORY}/dest commit -q -m "push mirror" && \
    ${GIT} -C ${WORKING_DIRECTORY}/dest push -q;

    # 生成 10000 个引用
    emph "generate 1w refs"
    for i in {1..10000}; do ${GIT} -C ${WORKING_DIRECTORY}/dest tag $(date +%Y%m%d_%H%M%S%N) -m "xxx"; done;
    ${GIT} -C ${WORKING_DIRECTORY}/dest gc --prune=now --quiet;
    emph "generate 1w refs done."

    setup=""
    prepare="rm -rf ${WORKING_REPO}/refs/tags; ${flush_cache};"
    command="${GIT} -C ${WORKING_DIRECTORY}/dest push --mirror file://${WORKING_REPO} -q"
    cleanup="${REMOVE_GIT_REPO};rm -rf ${WORKING_DIRECTORY}/dest"
    runs=$ret
}

hyperfine_run() {
    hyperfine_command="${HYPERFINE} '${command}' ${HYPERFINE_SHOW_OUTPUT} \
                            --setup '${setup}' \
                            --prepare '${prepare}' \
                            --runs ${runs} \
                            --cleanup '${cleanup}'"
    tty_msg DEBUG $hyperfine_command
    bash -c "$hyperfine_command"
}

BENCHMARK_LIST=(
    benchmark_init
    benchmark_unpack_objects
    benchmark_fsck
    benchmark_repack_split
    benchmark_repack_all
    benchmark_clone
    benchmark_fetch
    benchmark_push_mirror
)

for (( i=0;i<${#BENCHMARK_LIST[@]};i++)) do
     # 执行
    ${BENCHMARK_LIST[i]}
    if [[ $? != 1 ]]; then hyperfine_run; fi
done

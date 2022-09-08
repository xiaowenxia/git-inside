### 说明
该脚本用于测试 git 在不同存储介质的 IO 性能。

### 准备
安装 git 、[hyperfine](https://github.com/sharkdp/hyperfine/releases)，并克隆 [tensorflow](https://github.com/tensorflow/tensorflow.git) 的裸仓库到测试目录。

### 运行

#### 参数
* `-d`: 测试的目录，这个目录在你要测试的存储介质中，没有给定则使用当前目录。
* `-e`: 设置测试项和测试次数，每个测试项用 `/` 分隔，一个测试项后面跟随 `,` 可以设置测试次数，比如 `init,100/unpack,5` 表示测试 init 5次，测试 unpack 5次。目前包括的测试项有：
    - `init`: 初始化一个裸仓库。
    - `unpack`: 解包一个约有 5w 个对象的packfile。
    - `fsck`: 校验 5w 个松散对象。
    - `repack_split`: 对 `tensorflow` 做 repack ，生成多个 packfile。
    - `repack_all`: 对 `tensorflow` 做 repack ，只生成一个 packfile。
    - `clone`: clone 。
    - `fetch`: fetch 。
    - `push_mirror`: 推送 1w 个引用到本地仓库。
* `-v`: 输出更多信息。
* `-h`: 帮助。

#### 运行效果
```bash
./git-io-benchmark.sh -d /home/xxw -einit,101/unpack,4/fsck,4/repack_split,4/repack_all,4/clone,4/fetch,4/push,10
==> git init
Benchmark 1: git init --bare /home/xxw/dest.git
  Time (mean ± σ):      16.8 ms ±   0.5 ms    [User: 1.8 ms, System: 1.2 ms]
  Range (min … max):    15.3 ms …  19.3 ms    101 runs

==> git unpack-objects
Benchmark 1: cat /home/xxw/benchmark_unpack_objects-a44c173886ea1d5854b219cd8d5cfb40d54ae6b4.pack | git --git-dir=/home/xxw/dest.git unpack-objects
  Time (mean ± σ):      7.748 s ±  0.028 s    [User: 6.240 s, System: 1.522 s]
  Range (min … max):    7.727 s …  7.789 s    4 runs
 
==> git fsck
Benchmark 1: git --git-dir=/home/xxw/dest.git fsck --full
  Time (mean ± σ):      17.2 ms ±   0.3 ms    [User: 2.6 ms, System: 1.5 ms]
  Range (min … max):    16.8 ms …  17.6 ms    4 runs
 
==> git repack split
Benchmark 1: git --git-dir=/home/xxw/tensorflow.git                     -c repack.writeBitmaps=false repack --max-pack-size=50m -adf --window=10 --depth=50
  Time (mean ± σ):     39.063 s ±  0.147 s    [User: 188.596 s, System: 3.264 s]
  Range (min … max):   38.893 s … 39.205 s    4 runs
 
==> git repack all
Benchmark 1: git --git-dir=/home/xxw/tensorflow.git                     -c repack.writeBitmaps=false repack --max-pack-size=20g -adf --window=10 --depth=50
  Time (mean ± σ):     32.287 s ±  0.057 s    [User: 185.983 s, System: 3.165 s]
  Range (min … max):   32.239 s … 32.360 s    4 runs
 
==> git clone
Benchmark 1: git clone --bare file:///home/xxw/tensorflow.git /home/xxw/dest.git
  Time (mean ± σ):     19.403 s ±  0.351 s    [User: 51.829 s, System: 3.341 s]
  Range (min … max):   19.077 s … 19.888 s    4 runs
 
==> git fetch
Benchmark 1: git --git-dir=/home/xxw/dest.git -c fetch.writePackedRefs=true -c fetch.unpackLimit=1 fetch --prune --end-of-options file:///home/xxw/tensorflow.git +refs/*:refs/*
  Time (mean ± σ):     21.478 s ±  0.085 s    [User: 51.435 s, System: 2.074 s]
  Range (min … max):   21.378 s … 21.584 s    4 runs
 
==> git push --mirror
warning: 您似乎克隆了一个空仓库。
==> generate 1w refs
==> generate 1w refs done.
Benchmark 1: git -C /home/xxw/dest push --mirror file:///home/xxw/dest.git -q
  Time (mean ± σ):     622.6 ms ±  66.0 ms    [User: 35.3 ms, System: 109.6 ms]
```
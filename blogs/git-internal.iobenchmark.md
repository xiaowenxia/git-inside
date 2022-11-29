# git 在常见存储介质的 IO 性能测试和分析

<a name="CUJLB"></a>

## 背景

[git](https://git-scm.com/docs) 本身是一个为本地开发环境设计的软件，对文件的读写非常频繁，如果使用分布式文件系统来存储 git 仓库，git 的读写性能会有非常大的影响。鉴于此，我这边针对常用的几种存储介质，以及服务端的 git 使用场景进行了深度测试和分析。

不想看测试说明的，可直接拉到底部看[测试结果](#测试结果)。
<a name="UbGHK"></a>

## 测试说明

<a name="ybytI"></a>

#### 测试仓库

`tensorflow.git` ，对象数：1383553 ，裸仓大小：906M 。

<a name="xuBqd"></a>

#### 测试的存储介质

|                 | 说明                                                                 | 网络延迟 |
| --------------- | -------------------------------------------------------------------- | -------- |
| `ramfs`         | 内存文件系统。吞吐预计 > 18GB/s，IO 延时 < 50ns                      | -        |
| `ESSD PL1`      | SSD 云盘，1TB 容量，吞吐为 300MB/s，IOPS 为 25k，IO 延时 500us ~ 2ms | -        |
| `高效云盘`      | 高效云盘，1TB 容量，吞吐为 140MB/s，IOPS 为 5k，IO 延时 1~3ms        | -        |
| `NAS`通用性能型 | 在测试机上的吞吐达到 500MB/s ，读 30k，写 2.8k，IO 延时 2ms          | 0.15ms   |
| `NAS` 极速型    | 500MB/s IO 延时为 300us                                              | 0.17ms   |

<a name="VtIiW"></a>

#### 测试命令

| 命令                 | 参数                                                               | 说明                                                                                             |
| -------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| `git init --bare`    | -                                                                  | 【常见功能】初始化裸仓库，涉及到多个小文件的创建                                                 |
| `git unpack-objects` | -                                                                  | 【大量小文件写入】解包一个 9.8MB 的 packfile，写入了约 5w 个松散对象                             |
| `git fsck`           | `--full`                                                           | 【大量小文件读取】对 5w 个松散对象进行 fsck                                                      |
| `git repack`         | `--max-pack-size=100m -adf`                                        | 【写入 10 个 100MB 文件】测试多个 packfile 的写入性能                                            |
| `git repack`         | `--max-pack-size=10g -adf`                                         | 【写入 1 个 1GB 文件】测试单个 packfile 的写入性能                                               |
| `git fetch`          | `-c fetch.writePackedRefs=true` `-c fetch.unpackLimit=1` `--prune` | 【常见场景】fetch 的耗时主要是计算和网络传输，磁盘 IO 性能影响不大                               |
| `git push`           | `--mirror`                                                         | 【大量小文件读写】服务端是以松散对象的方式存储 1w 个松散引用，git 底层的事务机制会对引用多次读写 |

<a name="TMbNY"></a>

## 测试方法

<a name="pf57k"></a>

#### 清 page caches 缓存

linux 内核中使用 page cache 的方式来加速 IO 读写性能：<br />

<div align="center">
<img src="https://img.alicdn.com/imgextra/i3/O1CN01TOhTC61t6GZaP8jOd_!!6000000005852-2-tps-2288-1586.png" width=500 />
</div>

<br />git 中，使用 mmap 的方式来读写大文件，包括 packfile 和 objects ，也使用 POSIX 接口来访问一些小文件比如 index、refs 等，所以必须清除系统缓存才能真正测试到磁盘和 NAS 的性能：

```shell
# 清除page cache 和buffers caches
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches;
```

<a name="ukO3P"></a>

#### 多次测试求均值

测试使用 [hyperfine](https://github.com/sharkdp/hyperfine) 来进行多次测试求平均耗时。

<a name="Rp0Ol"></a>

#### ramfs

计算、带宽、磁盘 IO 的快慢对 git 的运行耗时都有非常大的影响。内存读写极快，几乎可以认为 IO 是无消耗的，在 ramfs 上的 git 命令的耗时可以认为是计算耗时或带宽耗时，从控制变量法的角度来看，一个 git 命令的磁盘消耗可以粗略的认为：

- `SSD 的磁盘IO消耗` = `SSD 命令耗时` - `ramfs 命令耗时`
- `NAS 的磁盘IO消耗` = `NAS 命令耗时` - `ramfs 命令耗时`

通过如下命令挂载 ramfs ：

```shell
sudo mount -t tmpfs -o size=8G tmpfs ramdisk
```

<a name="TYTyq"></a>

## 测试脚本 git-io-benchmark

为了测试方便，这里编写了一个自动化测试脚本：[git-io-benchmark](https://github.com/xiaowenxia/git-inside/blob/main/tools/git-io-benchmark.md) ，通过几个参数即可进行测试。
<a name="Bp4cf"></a>

#### 准备

安装 git 、[hyperfine](https://github.com/sharkdp/hyperfine/releases)，并克隆 [tensorflow.git](https://github.com/tensorflow/tensorflow.git) 的裸仓库到测试目录。

<a name="JCAhM"></a>

#### 运行

下载脚本：

```shell
$ wget https://amp-service.oss-cn-shanghai.aliyuncs.com/git-io-benchmark
$ chmod +x ./git-io-benchmark
```

<a name="Uc9KZ"></a>

#### 参数

- `-d`: 测试的目录，这个目录在你要测试的存储介质中，没有给定则使用当前目录。
- `-e`: 设置测试项和测试次数，每个测试项用 `/` 分隔，一个测试项后面跟随 `,` 可以设置测试次数，比如 `-einit,100/unpack,5` 表示测试 init 5 次，测试 unpack 5 次。目前包括的测试项有：
  - `init`: 初始化一个裸仓库。默认测试 100 次。
  - `unpack`: 解包一个约有 5w 个对象的 packfile。默认测试 3 次。
  - `fsck`: 校验 5w 个松散对象。默认测试 20 次。
  - `repack_split`: 对 `tensorflow.git` 做 repack ，生成多个 packfile。默认测试 3 次。
  - `repack_all`: 对 `tensorflow.git` 做 repack ，只生成一个 packfile。默认测试 3 次。
  - `clone`: clone 。默认测试 2 次。
  - `fetch`: fetch 。默认测试 2 次。
  - `push_mirror`: 推送 1w 个引用到本地仓库。默认测试 20 次。
  - `all`: 测试所有项。
- `-t`: 设置 `tensorflow.git` 的路径。
- `-p`: 添加该参数，测试仓库的`objects/pack` 会软连接该路径，用于测试 `objects/pack` 软链到低价介质的性能场景。
- `-v`: 输出更多信息。
- `-x`: 显示 hyperfine 执行的命令输出。
- `-h`: 帮助。

示例：

```bash
$ ./git-io-benchmark.sh -d /home/xxw -eall -p /nas -v -t /home/xxw/workspace/oss/tensorflow.git
```

<a name="c7qd6"></a>

#### 运行效果

<div align="center">
<img src="https://img.alicdn.com/imgextra/i1/O1CN01PmoJZ920n2rLmSEDc_!!6000000006893-2-tps-2624-1468.png" width=800 />
</div>

<a name="DXKR9"></a>

## 测试结果

- 测试主机： `ecs.c5.4xlarge` `16C32G`
- git 版本： `2.27.0`

| disk                      | init    | unpack | fsck   | repack_split | repack_all | clone | fetch | push_mirror |
| ------------------------- | ------- | ------ | ------ | ------------ | ---------- | ----- | ----- | ----------- |
| ramfs                     | 37.7ms  | 14.8s  | 4.5s   | 78.5s        | 63.5s      | 52.1s | 58.7s | 156.7ms     |
| ESSD PL1                  | 34.1ms  | 15.8s  | 18.4s  | 79.8s        | 64.5s      | 53.1s | 59.6s | 2.6s        |
| 高效云盘                  | 36.4ms  | 15.7s  | 25.9s  | 84.3s        | 69.0s      | 55.0s | 61.6s | 4.6s        |
| ESSD PL1 + NAS 通用性能型 | 42.6ms  | 15.7s  | 18.0s  | 79.1s        | 66.2s      | 53.1s | 63.9s | 5.3s        |
| NAS 通用性能型            | 208.1ms | 760.6s | 137.8s | 85.0s        | 69.8s      | 57.8s | 70.2s | 43.3s       |
| NAS 极速型                | 92.3ms  | 308.0s | 36.9s  | 83.1s        | 67.6s      | 54.4s | 62.1s | 44.5s       |

> NAS 是阿里云提供的分布式共享存储服务（ https://www.aliyun.com/product/nas ）。

<div align="center">
<img src="https://img.alicdn.com/imgextra/i1/O1CN01kepwxp1pyzR6EgeN9_!!6000000005430-2-tps-1732-1300.png" width=800 />
</div>

> `ESSD PL1 + NAS 通用性能型` 表示仓库在 ESSD PL1 上，但是仓库的 `objects/pack` 挂在到 NAS 通用性能型上。

按照如下方式计算磁盘消耗：

- `SSD 的IO消耗` = `SSD 命令耗时` - `ramfs 命令耗时`
- `NAS 的IO消耗` = `NAS 命令耗时` - `ramfs 命令耗时`

| disk                      | init(ms) | unpack | fsck   | repack_split | repack_all | clone | fetch | push_mirror |
| ------------------------- | -------- | ------ | ------ | ------------ | ---------- | ----- | ----- | ----------- |
| ESSD PL1                  | 0.00     | 1.00   | 13.90  | 1.30         | 1.00       | 1.00  | 0.90  | 2.44        |
| 高效云盘                  | 0.00     | 0.90   | 21.40  | 5.80         | 5.50       | 2.90  | 2.90  | 4.44        |
| ESSD PL1 + NAS 通用性能型 | 4.90     | 0.90   | 13.50  | 0.60         | 2.70       | 1.00  | 5.20  | 5.14        |
| NAS 通用性能型            | 170.40   | 745.80 | 133.30 | 6.50         | 6.30       | 5.70  | 11.50 | 43.14       |
| NAS 极速型                | 54.60    | 293.20 | 32.40  | 4.60         | 4.10       | 2.30  | 3.40  | 44.34       |

<div align="center">
<img src="https://img.alicdn.com/imgextra/i4/O1CN01ZHYIdP1Y4KyWqvCDZ_!!6000000003005-2-tps-1730-1300.png" width=800 />
</div>

<a name="bopFs"></a>

## 我的结论

- **松散对象和松散引用的读写性能 NAS 极差**
  - `git unpack-objects` 涉及了大量的小文件写入，NAS 上的表现极差，NAS 的耗时为 SSD 的 **<span style="color:red">700</span>** 倍。（`git push --mirorr` 也是一样的）
  - `git fsck` 涉及了大量小文件的读取，NAS 上也表现极差，NAS 的耗时为 SSD 的 **<span style="color:red">10</span>** 倍。
- **在 packfile 读写性能上 NAS 接近 SSD**
  - `git repack` 只生成一个 packfile 时（ `--max-pack-size = 10g` ），NAS 的表现跟 SSD 几乎一样。
  - `git log`、`git rev-list` 都是只读取一个 packfile ，NAS 测试耗时接近 SSD 。

存储介质有三个指标：吞吐量、IOPS、IO 延迟。在 [常见存储介质参数对比](#常见存储介质参数对比) 可以看到粗略的对比。而基于网络访问的分布式文件系统（比如 NAS、OSS）的 IO 延时往往能达到 1~10ms 以上，再加上网络的延迟，总体算下来连 HDD 的 IO 延时都不如。git 命令存在大量的按序读写的操作，比如写入一个 blob 对象，一般涉及到 `open`、`access`、`unlink` 等 POSIX 系统调用，这些系统调用就导致了 IO 延时被多次放大，累加起来 git 命令耗时就非常糟糕，这是 git 在分布式存储介质上的关键性能瓶颈所在。

当然可以通过一些配置让 git 命令以 packfile 和 pack-refs 的方式存储对象和引用，但是实际测试下来，以 `pack-refs` 的方式存储引用仍然存在一定的性能问题，因为 git 为了保证引用的事务管理，仍然对松散引用进行了加解锁过程，导致 IO 延时一直居高不下。个人判断，要让 git 能够在分布式存储中的正常读写，就势必要减少 git 对文件系统的读写次数，也就需要对 git 做更深层次的改造。

<a name="SaUnT"></a>

## 其他说明

<a name="fBlwl"></a>

#### 其他 git 命令的测试

测试过程中，也针对了一些高频场景做了相关的测试，比如：

- `git clone --bare` 是常见 git 使用场景，涉及到了大文件读写，其功能与 `git fetch` 类似，实际测试下来的数据也是一样的。
- `git rev-list --objects --all` 测试遍历 commit 和 tree 对象的性能。实际测试下来各种存储介质耗时接近，主要是跟计算能力有关，跟磁盘 IO 性能关系不大。
- `git log -Sfoo --raw` 读取所有 commit 对象的内容，实际测试下来也是跟磁盘 IO 性能关系不大。

<a name="yK3tA"></a>

#### 常见存储介质参数对比

| 存储设备           | 带宽          | IOPS        | IO 延时 |
| ------------------ | ------------- | ----------- | ------- |
| 普通 HDD           | 120MB/s 左右  | 0.1k        | 1x ms   |
| 普通 SSD（SATA）   | 550MB/s 左右  | 30k         | 100 us  |
| SSD (NVMe on PCIe) | 1~8GB/s 左右  | 500k ~1000k | 50 us   |
| DRAM(DDR4 3200MHz) | 100GB/s 以上  | 5000k 以上  | 75 ns   |
| NAS 通用性能型     | 600MB ~ 5GB   | < 30k       | 2ms     |
| NAS 极速标准型     | 150MB ~ 1.2GB | < 200k      | 1.2ms   |

<a name="uNG0I"></a>

#### 高性能本地磁盘测试

另外也基于本地的 NVME 接口的高性能 SSD 磁盘进行了测试，环境不一样，在个人电脑上测试的（AMD 5600X 、6 CPU 32 GiB），仅用于参考：

| disk            | init   | unpack | fsck   | repack_split | repack_all | clone | fetch | push_mirror |
| --------------- | ------ | ------ | ------ | ------------ | ---------- | ----- | ----- | ----------- |
| samsung 980 PRO | 12.5ms | 13.3s  | 5.7s   | 40.7s        | 33.5s      | 20.7s | 24.1s | 2.3s        |
| SSD NVMe 3.0    | 15.3ms | 7.7s   | 5.5s   | 38.7s        | 32.7s      | 19.1s | 21.7s | 466.9ms     |
| ramfs           | 13.4ms | 7.1s   | 16.8ms | 38.5s        | 31.7s      | 18.5s | 20.7s | 64.7ms      |

<a name="P0Bg8"></a>

### 参考文章

- [https://juejin.cn/post/7125820067262464007](https://juejin.cn/post/7125820067262464007)
- [https://www.kernel.org/doc/Documentation/sysctl/vm.txt](https://www.kernel.org/doc/Documentation/sysctl/vm.txt)
- https://git-scm.com/docs

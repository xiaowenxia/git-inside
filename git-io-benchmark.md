### 说明
该脚本用于测试 git 在不同存储介质的 IO 性能。
> 目前仅支持 linux 系统。

### 准备
安装 git 、[hyperfine](https://github.com/sharkdp/hyperfine/releases)，并克隆 [tensorflow](https://github.com/tensorflow/tensorflow.git) 的裸仓库到测试目录。

### 运行
下载脚本：
```sh
$ wget https://amp-service.oss-cn-shanghai.aliyuncs.com/git-io-benchmark
$ chmod +x ./git-io-benchmark
```

#### 参数
* `-d`: 测试的目录，这个目录在你要测试的存储介质中，没有给定则使用当前目录。
* `-e`: 设置测试项和测试次数，每个测试项用 `/` 分隔，一个测试项后面跟随 `,` 可以设置测试次数，比如 `-einit,100/unpack,5` 表示测试 init 5次，测试 unpack 5次。目前包括的测试项有：
    - `init`: 初始化一个裸仓库。默认测试 100 次。
    - `unpack`: 解包一个约有 5w 个对象的packfile。默认测试 3 次。
    - `fsck`: 校验 5w 个松散对象。默认测试 20 次。
    - `repack_split`: 对 `tensorflow` 做 repack ，生成多个 packfile。默认测试 3 次。
    - `repack_all`: 对 `tensorflow` 做 repack ，只生成一个 packfile。默认测试 3 次。
    - `clone`: clone 。默认测试 2 次。
    - `fetch`: fetch 。默认测试 2 次。
    - `push_mirror`: 推送 1w 个引用到本地仓库。默认测试 20 次。
    - `all`: 测试所有项。
* `-t`: 设置 `tensorflow.git` 的路径。
* `-p`: 添加该参数，测试仓库的`objects/pack` 会软连接该路径，用于测试 `objects/pack` 软链到低价介质的性能场景。
* `-v`: 输出更多信息。
* `-x`: 显示 hyperfine 执行的命令输出。
* `-h`: 帮助。

示例：
```
$ ./git-io-benchmark.sh -d /home/xxw -eall -p /nas -v -t /home/xxw/workspace/oss/tensorflow.git
```
#### 运行效果
![](https://img.alicdn.com/imgextra/i1/O1CN01PmoJZ920n2rLmSEDc_!!6000000006893-2-tps-2624-1468.png)


#### 测试数据

|hardware                   |disk           |init   |unpack |fsck   |repack_split   |repack_all |clone  |fetch  |push_mirror|
|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|
|AMD 5600X <br/>6 CPU 32 GiB|samsung 980 PRO|12.5ms |13.3s  |5.7s   |40.7s          |33.5s      |20.7s  |24.1s  |2.3s       |
|AMD 5600X <br/>6 CPU 32 GiB|SSD NVMe 3.0   |15.3ms |7.7s   |5.5s   |38.7s          |32.7s      |19.1s  |21.7s  |466.9ms    |
|AMD 5600X <br/>6 CPU 32 GiB|ramfs          |13.4ms |7.1s   |16.8ms |38.5s          |31.7s      |18.5s  |20.7s  |64.7ms     |

|hardware                   |disk           |init   |unpack |fsck   |repack_split   |repack_all |clone  |fetch  |push_mirror|
|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|
|ecs.c5.4xlarge <br/>16C32G |ramfs          |37.7ms |14.8s  |4.5s   |78.5s          |63.5s      |52.1s  |58.7s  |156.7ms    |
|ecs.c5.4xlarge <br/>16C32G |ESSD PL1       |34.1ms |15.8s  |18.4s  |79.8s          |64.5s      |53.1s  |59.6s  |2.6s       |
|ecs.c5.4xlarge <br/>16C32G |NAS 通用性能型  |208.1ms |760.6s |137.8s |85.0s          |69.8s       |57.8s  |70.2s  |43.3s      |
|ecs.c5.4xlarge <br/>16C32G |高效云盘        |36.4ms |15.7s   |25.9s  |84.3s          |69.0s      |55.0s  |61.6s  |4.6s       |
|ecs.c5.4xlarge <br/>16C32G |ESSD PL1 + NAS |42.6ms |15.7s  |18.0s  |79.1s          |66.2s      |53.1s  |63.9s   |s       |

|ecs.c5.4xlarge <br/>16C32G |NAS 极速型      |92.3ms |308.0s  |.0s  |.1s          |.2s      |.1s  |.9s   |s       |

* `ESSD PL1 + NAS` 表示仓库在 ESSD PL1 上，但是仓库的 `objects/pack` 挂在到 NAS 通用性能型上。
* NAS 性能型的网络延时为 0.15ms ，NAS 极速型的网络延时为 0.17ms 。
* samsung 980 PRO 的磁盘文件格式为 `NTFS` 。

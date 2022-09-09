### 说明
该脚本用于测试 git 在不同存储介质的 IO 性能。
> 目前仅支持 linux 系统。

### 准备
安装 git 、[hyperfine](https://github.com/sharkdp/hyperfine/releases)，并克隆 [tensorflow](https://github.com/tensorflow/tensorflow.git) 的裸仓库到测试目录。

### 运行
下载脚本：
```sh
wget https://amp-service.oss-cn-shanghai.aliyuncs.com/git-io-benchmark
```

#### 参数
* `-d`: 测试的目录，这个目录在你要测试的存储介质中，没有给定则使用当前目录。
* `-e`: 设置测试项和测试次数，每个测试项用 `/` 分隔，一个测试项后面跟随 `,` 可以设置测试次数，比如 `-einit,100/unpack,5` 表示测试 init 5次，测试 unpack 5次。目前包括的测试项有：
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
![](https://img.alicdn.com/imgextra/i2/O1CN01d20NHe1OR6UBcCxdX_!!6000000001701-2-tps-2488-1480.png)


#### 测试数据

|hardware                           |disk           |init   |unpack |fsck   |repack_split   |repack_all |clone  |fetch  |push_mirror    |
|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|
|AMD 5600X <br />6 CPU 32 GiB       |samsung 980 PRO|14ms   |13.5s  |16.9ms |43.7s          |36.2s      |22.1s  |26.9s  |414.2ms    |
|AMD 5600X <br />6 CPU 32 GiB       |SSD NVMe 3.0   |15.3ms |7.7s   |16.8ms |38.9s          |32.2s      |19.1s  |21.4s  |434.8ms    |
|AMD 5600X <br />6 CPU 32 GiB       |ramfs          |12.1ms |7.1s   |16.2ms |41.6s          |35.2s      |20.6  |22.7s  |53.1ms    |
|ecs.c5.4xlarge <br />16 vCPU 32 GiB|ramfs          |31.1ms |15.6s  |23200ms|80.1s          |36.2s      |22.1s  |26.9s  |414.2ms    |

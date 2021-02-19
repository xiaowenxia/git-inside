## Git 底层协议

## 使用 wireshark 抓包分析 git 传输协议

SSL 能通过SSLKEYLOGFILE 记录 shared secret key
庖丁解牛 https://github.com/gcla/termshark

查看服务器ip地址
```bash
host codeup.aliyun.com
codeup.aliyun.com has address 118.31.165.50
```


`菜单` >`Performances`，在对话框中选择 `Protocol` > `TLS`，设置 `(Pre)-Master-Secret log filename` 为你的 `SSLKEYLOGFILE` 文件路径：


wireshark 过滤条件
tls && ip.addr == 118.31.165.50

github 使用的是http2的协议。

https://wangdoc.com/ssh/client.html

http(s)://，ssh://，git://



```
HTTP/1.1 200 OK
Server: Tengine
Date: Thu, 18 Feb 2021 12:48:44 GMT
Content-Type: application/x-git-upload-pack-advertisement
Content-Length: 1015
Connection: keep-alive
Cache-Control: no-cache

001e# service=git-upload-pack
000001163ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 HEADmulti_ack thin-pack side-band side-band-64k ofs-delta shallow deepen-since deepen-not deepen-relative no-progress include-tag multi_ack_detailed no-done symref=HEAD:refs/heads/master object-format=sha1 agent=git/2.28.0.agit.6.0
0040f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea refs/heads/develop
004961ee902744d1f5a480e607856d44b104602d6b13 refs/heads/feature/p3c_scan
004fae02248d14bfdc9d4d38b1532cab278d179bc863 refs/heads/feature/sensitive_scan
003f3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 refs/heads/master
00676508471ba8d143e1bfc41c391280a7ef533be57b refs/keep-around/6508471ba8d143e1bfc41c391280a7ef533be57b
0067fe94112642bb8c57f6d08309f376135744fcb24e refs/keep-around/fe94112642bb8c57f6d08309f376135744fcb24e
004d6508471ba8d143e1bfc41c391280a7ef533be57b refs/merge-requests/267112/head
004dfe94112642bb8c57f6d08309f376135744fcb24e refs/merge-requests/267123/head
003c3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12 refs/tags/v1.0
0000
```


```
00a8want f82d3c440cf02ff2e20d712eaa7ba63a9fbff4ea multi_ack_detailed no-done side-band-64k thin-pack ofs-delta deepen-since deepen-not agent=git/2.24.3.(Apple.Git-128)
0032want 61ee902744d1f5a480e607856d44b104602d6b13
0032want ae02248d14bfdc9d4d38b1532cab278d179bc863
0032want 3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12
0032want 3ab7c8d1c1e2ce5f5e16a17c41f6665686980d12
00000009done

```



ssh 是建立在tcp之上的。
最后协商成功之后，将会生成一个对称加密 会话密钥key 以及一个 会话ID ，在这里要特别强调，这个是对称加密密钥key，

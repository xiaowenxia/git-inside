#!/bin/bash
for file in ../git-*.md; do
    echo $file
    # 生成文档名称
    contentName=`awk 'NR==1{print}' ${file} | awk -F'## ' '{print $2}'`
    echo 获取文档名称：$contentName
    # 插入 hexo 规范的文档结构
    baseName=`basename ${file}`
    cat $file | sed -e "1i\---\ntitle: ${contentName}\n---\n" > ./source/_posts/${baseName}
done
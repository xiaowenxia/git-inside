#!/bin/bash
for file in ./git-*.md; do
    echo $file
    # 生成文档名称
    contentName=`awk 'NR==1{print}' ${file} | awk -F'## ' '{print $2}'`
    contentCreateDate=`git log --all --pretty=format:"%ai" --date-order --reverse -- $file | head -1`
    contentUpdateDate=`git log --all --pretty=format:"%ai" --date-order           -- $file | head -1`
    echo 获取文档名称：$contentName 创建日期：$contentCreateDate 更新日期：$contentUpdateDate
    # 插入 hexo 规范的文档结构
    baseName=`basename ${file}`
    cat $file | sed -e "1i\---\ntitle: ${contentName}\ndate: ${contentCreateDate}\nupdated: ${contentUpdateDate}\n---\n" > ./git-inside/source/_posts/${baseName}
done
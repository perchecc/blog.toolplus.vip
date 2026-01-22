---
title: miniforge-替代conda的Python环境和包管理工具
publishDate: 2025-08-23
updatedDate: 2025-08-23
tags: 
    - python
    - 包管理工具
description: ""
---

> 我安装的是 miniforge3，不是 conda

## 安装 miniforge3

1. 打开终端（Mac/Linux）或命令提示符（Windows）。
2. 找到官网下载地址，选择对应版本。我的是 macos arm64 版本。
    https://conda-forge.org/miniforge/

3. 运行安装脚本：

   ```bash
   sh Miniforge3-25.3.0-3-MacOSX-arm64.sh
   ```

   替换成实际的脚本名称安装。

## 常用的命令

miniforge中同时内置了包管理工具conda和mamba，其中mamba可「完全」作为conda功能的替代，且运行效率优于conda，我们只需要将平时熟悉的conda命令中的conda替换为mamba即可。

查看虚拟环境 `mamba env list`

创建虚拟环境 `mamba create -n <env_name> python=<version>`

激活虚拟环境 `mamba activate <env_name>`

退出虚拟环境 `mamba deactivate`

删除虚拟环境 `mamba env remove -n <env_name>`

安装包 `mamba install <package_name>`

卸载包 `mamba uninstall <package_name>`

更新包 `mamba update <package_name>`

搜索包 `mamba search <package_name>`

查看已安装的包 `mamba list`

查看包的信息 `mamba info <package_name>`
<img src="images/hustcwhole.png" alt="hust" width="800" />

# proj103-面向轻量级虚拟化的优化技术

## 项目简介

<img src="images/icon.png" alt="icon" width="500"/>

容器技术作为一种操作系统虚拟化技术，因其轻量化的特点，在云计算领域得到广泛应用。然而，容器技术的轻量化是基于对宿主机内核的共享实现，这也限制了容器一系列策略的个性化定制，影响容器应用性能。
`vkernel`（virtual kernel）基于可加载内核模块技术在内核层实现了容器独立的虚拟内核，根据不同的应用需求、环境特征等进行灵活定制，可以满足云计算环境对内核隔离性和多样性的需求。和[项目参考作品](https://gitlab.eduxiji.net/hustcgcl/project788067-109547)相比，我们迭代更新了CPU调度子系统和内存管理子系统的隔离方案，为容器提供了更加安全高效的运行环境。

## 预期目标

| 目标编号 | 目标内容                            | 目标描述                                                                                                                      |
| -------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| 1        | 虚拟内核框架的设计                   | 实现vkernel中vKI和vKM模块的设计                                                        |
| 2        | CPU调度的虚拟化              | 对CPU调度策略进行分析和设计     
| 3        | CPU调度策略的自适应            | 在容器实际运行过程中动态选择合适的调度策略                                                                                                  |
| 4        | 容器内存管理策略的定制 | 对容器内存管理策略进行分析和设计                                                                                            |
| 5        | 容器系统调用的虚拟化               | 实现容器系统调用表 |
| 6        | 基于inode虚拟化的文件访问控制模块            | 利用现有的权限检测机制，针对inode进行虚拟化                                                                                          |
| 7        | 内核日志隔离            | 限制容器对内核日志的访问，实现对内核日志的彻底隔离                                                                                          |
                                                                                         




## 项目进度


| 目标编号 | 完成情况                            | 描述                                                                                                                      |
| -------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| 1        | 已完成                   | vKI和vKM中实现了内核模块的具体内容，在runc中实现了对vkernel内核模块的支持                                                        |
| 2        | 已完成              | 实现了当前适合容器运行的CPU调度策略                                                                                                    |
| 3        | 已完成            | 初步实现容器实际运行过程中调度策略的动态选择                 |
| 4        | 完成设计 | 对内存管理策略进行了深入分析，形成了完整的内存管理隔离方案                                                                                            |
| 5        | 已完成               | 已实现容器系统调用表 |
| 6        | 已完成            | 对inode进行虚拟化，优化文件权限检测机制                                                                                      |
| 7        | 已完成            | 完成了内核日志的隔离                                                                                          |


## 原理介绍

从本质上讲，vKernel 依赖于内核 ftrace 机制拦截发送到主机内核的请求并将其重定向到 vKernel 实例（vKI），其中实现了特定于容器的系统调用表、 Capability、文件权限列表、以及其他用户定义的功能和数据。用户可以自定义安全配置文件并生成专用的 vKernel 实例，该实例提供现有内核安全机制相同类型的安全检查，但效率更高且更安全。 vKI 可以作为内核模块动态加载和更新，并且独立于主机内核。 


### 项目的详细介绍在我们的开发文档中
- [vkernel项目开发文档.pdf](vkernel项目开发文档.pdf)

## 代码文件说明

获取我们开发的linux内核请访问[github链接](https://github.com/zhengyunkun/linux-kernel)，**包含完整的linux内核源码**。代码和文档按照[GNU GENERAL PUBLIC LICENSE v2](./LICENSE) 许可发布

## 仓库目录和文件描述

### 仓库目录

```bash
vkernel-project
├── images
├── LICENSE
├── README.md
├── results         # 测试结果
├── tests           # 测试脚本
└── vkernel         # VKERNEL
```

### VKERNEL

```bash
vkernel
├── builder         # 内核定制工具
├── module          # vkernel模块
└── runc            # vkernel容器运行时
```

#### BUILDER

```bash
builder
├── apparmor.py     # apparmor规则
├── input
├── main.py
├── seccompD2A.py
├── seccomp.py      # seccomp规则
└── util.py
```

#### MODULE

```bash
module
├── vKI
│   ├── apparmor.c
│   ├── apparmor.h
│   ├── capability.c    # 定义容器的capability规则
│   ├── capability.h
│   ├── custom.h        # 自定义内核函数
│   ├── main.c          # 初始化vkernel并加以管理
│   ├── Makefile        # 用于打包vKI生成vkernel.ko
│   ├── syscall.c       # 系统调用
│   ├── syscall.h
│   ├── syscalls
│   └── vkernel.h       # 定义vkernel结构体
└── vKM
    ├── hook.c          # 管理ftrace_hook
    ├── hook.h          # 定义ftrace_hook
    ├── main.c          # 初始化
    └── Makefile        # 用于打包vKM生成vkernel_hook.ko
```

#### RUNC
```bash
runc
├── checkpoint.go
├── contrib
├── CONTRIBUTING.md
├── create.go
├── delete.go
├── Dockerfile
├── docs
├── events.go
├── exec.go
├── go.mod
├── go.sum
├── init.go
├── kill.go
├── libcontainer                    # 包含vkernel相关的代码，在运行容器时管理vkernel
├── LICENSE
├── list.go
├── main.go
├── MAINTAINERS
├── MAINTAINERS_GUIDE.md
├── Makefile
...
```

##### LIBCONTAINER
```bash
libcontainer
├── capabilities_linux.go
├── cgroups
├── configs
├── console_linux.go
├── container.go
├── container_linux.go
├── container_linux_test.go
├── criu_opts_linux.go
├── devices
├── error.go
├── error_test.go
├── factory.go
├── factory_linux.go
├── factory_linux_test.go
├── generic_error.go
├── generic_error_test.go
├── init_linux.go
├── integration
├── intelrdt
├── keys
├── logs
├── message_linux.go
├── network_linux.go
├── notify_linux.go
├── notify_linux_test.go
├── notify_linux_v2.go
├── nsenter
├── process.go
├── process_linux.go
├── README.md
├── restored_process.go
├── rootfs_linux.go
├── rootfs_linux_test.go
├── setns_init_linux.go
├── specconv
├── SPEC.md
├── stacktrace
├── standard_init_linux.go
├── state_linux.go
├── state_linux_test.go
├── stats_linux.go
├── sync.go
├── system
├── user
├── utils
└── vkernel
        ├── capability.go           # 生成并格式化capabilities并传递给 vkernel 模块
        ├── rename.go               # 实现读取 ELF 文件信息
        └── vkernel.go              # 定义VKernel结构体并实现与vkernel模块相关的功能
```

### TESTS
```bash
tests
├── cpu_sched           # cpu调度测试
├── nginx.sh            # nginx 测试脚本
├── pwgen.sh            # pwgen 测试脚本
├── start.sh            # 项目运行脚本
└── time.sh             # 容器启动脚本
```


## 安装

- 克隆仓库

```bash
git clone https://gitlab.eduxiji.net/T202410487992786/project2210132-236728.git
```
- 编译linux内核

    ```bash
    $ make -j16
    ```

- 安装内核模块

    ```bash
    $ make modules
    $ make INSTALL_MOD_STRIP=1 modules_install
    ```
- 安装内核

    ```bash
    $ make install
    ```

### 安装vkernel内核模块

#### 进入module目录下，编译内核模块并安装
```bash
$ cd vKM
$ make
$ insmod vkernel_hook.ko
$ cd vKI
$ make
$ make install
```
### 安装容器运行时

- 编译运行时

    ```bash
    $ cd runc
    $ make
    $ cp runc /usr/local/bin/vkernel-runtime
    ```

- 编辑`etc/docker/daemon.json`中的内容，为docker添加运行时


   ```json
   {
   	"runtimes": {
           "vkernel-runtime": {
               "path": "/usr/local/bin/vkernel-runtime"
           }
       }
   }
   ```

- 重启docker

    ```bash
    $ sudo systemctl restart docker
    ```

## 使用

- 创建容器，添加 `--runtime=vkernel-runtime` 参数

    ```bash
    $ docker run --rm --runtime=vkernel-runtime -itd ubuntu /bin/bash
    265d5d45c6a782ca531e9b5ed2d3c4d305f13f142cc1c9cd50246221b592e55b
    $ lsmod | grep vkernel
    vkernel_265d5d45c6a7
    ```
- 可以看到lsmod显示的内核模块中的vkernel内核模块

## 测试相关

具体的项目执行和测试可以参考[vkernel项目执行](https://pan.baidu.com/s/1QWOcFNZlz-MFiIY3KH5u1A?pwd=1234)，包含较为详细的代码测试和项目执行视频。

## 代码文件说明

获取我们开发的linux内核请访问[github链接](https://github.com/zhengyunkun/linux-kernel)，包含完整的linux内核源码。代码和文档按照[GNU GENERAL PUBLIC LICENSE v2](./LICENSE) 许可发布


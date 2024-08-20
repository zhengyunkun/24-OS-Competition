#!/bin/bash
# 读取参数
policy=$1

# 获取当前容器的 cgroup 目录
cgroup_path=/docker
# 配置调度策略
if [ "$policy" -eq 0 ]; then
  echo "Setting SCHED_NORMAL"
  chrt -o -p 0 $$
elif [ "$policy" -eq 1 ]; then
  echo "Setting SCHED_FIFO"
  chrt -f -p 1 $$
fi

# 设置 cpu.real_policy 参数
echo $policy > /sys/fs/cgroup/cpu$cgroup_path/real_policy

# 保持容器运行
sleep infinity

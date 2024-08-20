#!/bin/bash

# 确保 hackbench 可执行文件存在
if [ ! -f ./hackbench ]; then
    echo "hackbench executable not found in the current directory."
    exit
fi

# 配置测试参数
ENTITY_GROUPS=(50 100 150 200)
MESSAGES=(500 1000 3000 5000 7000 9000)
REAL_POLICIES=(0 1) # 0 for SCHED_NORMAL, 1 for SCHED_FIFO
POLICY_NAMES=("SCHED_NORMAL" "SCHED_FIFO")

# 创建日志文件夹
mkdir -p test_results

# 准备初始化脚本
init_script="init_script.sh"
cat << 'EOF' > $init_script
#!/bin/bash
# 读取参数
policy=$1

# 获取当前容器的 cgroup 目录
#cgroup_path=$(cat /proc/1/cgroup | grep cpu | cut -d: -f3)
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

EOF
chmod +x $init_script

# 准备 Dockerfile 以确保 hackbench 在容器内可用
dockerfile="Dockerfile"
cat << 'EOF' > $dockerfile
FROM ubuntu:latest
COPY hackbench /usr/local/bin/hackbench
COPY init_script.sh /init_script.sh
CMD ["sleep", "infinity"]
EOF

# 构建 Docker 镜像
docker build -t custom_ubuntu .

# 运行测试
for entities in "${ENTITY_GROUPS[@]}"; do
  for messages in "${MESSAGES[@]}"; do
    for i in "${!REAL_POLICIES[@]}"; do
      policy=${REAL_POLICIES[$i]}
      policy_name=${POLICY_NAMES[$i]}
      echo "Testing with ${entities} entities, ${messages} messages, and policy ${policy_name}"
      
      container_name=container_${policy_name}_${entities}_${messages}
      
      # 检查并移除同名的现有容器
      if [ "$(docker ps -a -q -f name=${container_name})" ]; then
        docker rm -f ${container_name}
      fi

      # 启动容器并设置调度策略
      container_id=$(docker run -d --name ${container_name} custom_ubuntu bash /init_script.sh ${policy})
      
      sleep 2  # 确保调度策略设置成功
      docker exec ${container_id} hackbench -g ${entities} -l ${messages} | tee test_results/result_${policy_name}_${entities}_${messages}.txt

      # 停止并移除容器
      docker stop ${container_id}
      docker rm ${container_id}
    done
  done
done

# 清理临时文件
rm $init_script
rm $dockerfile


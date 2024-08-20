#!/bin/bash

# 确保 hackbench 可执行文件存在
if [ ! -f ./hackbench ]; then
    echo "hackbench executable not found in the current directory."
    exit
fi

# 配置测试参数
ENTITY_GROUPS=(50 100)
MESSAGES=(500 1000 3000 5000 7000 9000)
CONTAINERS=("container_privileged" "container_cap" "container_default")
OPTIONS=(
  "--privileged=true"
  "--cap-add=CAP_SYS_NICE"
  ""
)
POLICIES=("SCHED_NORMAL" "SCHED_FIFO")
POLICY_COMMANDS=(
  "chrt -o 0"  # SCHED_NORMAL with priority 0
  "chrt -f 1"  # SCHED_FIFO with priority 1
)

# 创建日志文件夹
mkdir -p test_results

# 获取当前日期时间作为后缀
current_date=$(date +"%Y%m%d%H%M%S")

# 准备 Dockerfile 以确保 hackbench 在容器内可用
dockerfile=$(mktemp)
cat << 'EOF' > $dockerfile
FROM ubuntu:latest
COPY hackbench /usr/local/bin/hackbench
EOF

# 构建 Docker 镜像
docker build -t custom_ubuntu -f $dockerfile .

# 运行测试
for i in "${!CONTAINERS[@]}"; do
  container_name=${CONTAINERS[$i]}
  options=${OPTIONS[$i]}
  
  for j in "${!POLICIES[@]}"; do
    policy=${POLICIES[$j]}
    policy_command=${POLICY_COMMANDS[$j]}
    
    # 生成输出文件名
    output_file="test_results/${container_name}_${policy}_${current_date}.log"
    
    for entities in "${ENTITY_GROUPS[@]}"; do
      echo "${entities} ${messages}" | tee -a $output_file
      
      for messages in "${MESSAGES[@]}"; do
        echo "Testing with ${entities} entities and ${messages} messages, policy ${policy}, container ${container_name}" | tee -a $output_file

        # 启动容器并运行 hackbench，直接记录输出到文件
        docker run --rm --name ${container_name}_${policy}_${entities}_${messages} ${options} custom_ubuntu bash -c "
          for i in {1..5}; do
            ${policy_command} hackbench -g ${entities} -l ${messages} | grep 'Time' | tee -a /hackbench_result.txt;
          done
        " | tee -a $output_file
        
      done
    done
  done
done

# 清理临时文件
rm $dockerfile


#!/bin/bash

# 确保 hackbench 可执行文件存在
if [ ! -f ./hackbench ]; then
    echo "hackbench executable not found in the current directory."
    exit
fi

# 配置测试参数
ENTITY_GROUPS=(50 100 150 200)
MESSAGES=(500 1000 3000 5000 7000 9000)
CONTAINERS=("container_privileged" "container_cap" "container_default")
OPTIONS=(
  "--privileged=true"
  "--cap-add=CAP_SYS_NICE"
  ""
)

# 创建日志文件夹
mkdir -p test_results # 如果存在目录就不创建

# 准备 Dockerfile 以确保 hackbench 在容器内可用
dockerfile=$(mktemp)
cat << 'EOF' > $dockerfile
FROM ubuntu:latest
COPY hackbench /usr/local/bin/hackbench
EOF

# 构建 Docker 镜像
docker build -t custom_ubuntu -f $dockerfile .

# 运行测试
for entities in "${ENTITY_GROUPS[@]}"; do
  for messages in "${MESSAGES[@]}"; do
    echo "Testing with ${entities} entities and ${messages} messages"
    
    for i in "${!CONTAINERS[@]}"; do
      container_name=${CONTAINERS[$i]}
      options=${OPTIONS[$i]}
      
      # 检查并移除同名的现有容器
      if [ "$(docker ps -a -q -f name=${container_name}_${entities}_${messages})" ]; then
        docker rm -f ${container_name}_${entities}_${messages}
      fi

      # 启动容器
      docker run -d --name ${container_name}_${entities}_${messages} ${options} custom_ubuntu sleep infinity
      
      # 运行 hackbench 测试
      docker exec ${container_name}_${entities}_${messages} hackbench -g ${entities} -l ${messages} | tee test_results/result_${container_name}_${entities}_${messages}.txt

      # 停止并移除容器
      docker stop ${container_name}_${entities}_${messages}
      docker rm ${container_name}_${entities}_${messages}
    done
    
    # 宿主机运行测试
    ./hackbench -g ${entities} -l ${messages} | tee test_results/result_host_${entities}_${messages}.txt
  done
done

# 清理临时文件
rm $dockerfile


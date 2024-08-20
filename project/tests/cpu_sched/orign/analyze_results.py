import matplotlib.pyplot as plt
import os

# 配置参数
entity_groups = [50, 100, 150, 200]
messages = [500, 1000, 3000, 5000, 7000, 9000]
policies = ["privileged", "cap", "default", "host"]

# 读取结果
results = {}
for entities in entity_groups:
    for msg in messages:
        for policy in policies:
            file_path = f'test_results/result_{policy}_{entities}_{msg}.txt'
            if os.path.exists(file_path):
                with open(file_path) as f:
                    result = [float(line.strip()) for line in f.readlines()]
                    results[(policy, entities, msg)] = result

# 绘制图表
for entities in entity_groups:
    plt.figure(figsize=(14, 8))
    for msg in messages:
        data = [results[(policy, entities, msg)] for policy in policies if (policy, entities, msg) in results]
        labels = [policy for policy in policies if (policy, entities, msg) in results]
        
        if data:
            plt.boxplot(data, labels=labels, positions=[msg], widths=500)
    
    plt.title(f'Performance Testing Results for {entities} Entities')
    plt.xlabel('Number of Messages')
    plt.ylabel('Hackbench Performance')
    plt.xticks(messages, messages)
    plt.grid(True)
    plt.legend(policies)
    plt.show()


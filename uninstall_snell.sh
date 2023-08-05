#!/bin/bash

# 列出所有 Snell 容器
CONTAINERS=$(docker ps -a --filter "name=Snell" --format "{{.ID}}:{{.Names}}")

if [ -z "$CONTAINERS" ]; then
  echo "没有找到 Snell 容器."
  exit 0
fi

echo "选择要卸载的 Snell 容器："
i=1
declare -A container_map
for container in $CONTAINERS; do
  id=$(echo $container | cut -d ':' -f1)
  name=$(echo $container | cut -d ':' -f2)
  echo "$i. $name ($id)"
  container_map[$i]=$id
  i=$((i+1))
done

while true; do
  read -p "输入选择（输入数字）： " choice

  # 检查用户输入是否为数字且在范围内
  if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -lt $i ]; then
    break
  else
    echo "输入无效，请输入有效的数字."
  fi
done

# 删除选定的 Snell 容器
selected_container=${container_map[$choice]}
if [ -n "$selected_container" ]; then
  echo "正在停止容器 $selected_container ..."
  docker stop $selected_container
  echo "正在删除容器 $selected_container ..."
  docker rm $selected_container
  echo "容器 $selected_container 已删除。"
else
  echo "未知错误，无法找到容器."
fi
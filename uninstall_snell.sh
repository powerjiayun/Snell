#!/bin/bash

# 删除选定的容器和相关持久化文件夹
function remove_container() {
  selected_container=$1
  container_name=$(docker ps --filter "id=$selected_container" --format "{{.Names}}")

  if [ -n "$selected_container" ]; then
    echo "正在停止容器 $selected_container ..."
    docker stop $selected_container
    echo "正在删除容器 $selected_container ..."
    docker rm $selected_container
    echo "容器 $selected_container 已删除。"

    echo "正在查找与容器名 $container_name 相同的文件夹..."
    find / -type d -name "$container_name" -exec sh -c 'echo "正在删除文件夹 '\''{}'\'' ..."; sudo rm -rf "{}"; echo "文件夹 '\''{}'\'' 已删除。"' \;
  else
    echo "未知错误，无法找到容器。"
  fi
}

# 列出所有 Docker 容器
function list_containers() {
  while true; do
    CONTAINERS=$(docker ps -a --format "{{.ID}}:{{.Names}}")

    if [ -z "$CONTAINERS" ]; then
      echo "没有找到 Docker 容器."
      exit 0
    fi

    echo "选择要卸载的容器："
    i=1
    declare -A container_map
    for container in $CONTAINERS; do
      id=$(echo $container | cut -d ':' -f1)
      name=$(echo $container | cut -d ':' -f2)
      echo "$i. $name ($id)"
      container_map[$i]=$id
      i=$((i+1))
    done
    echo "$i. 退出脚本"
    container_map[$i]="exit"
    read -p "输入选择（输入数字）： " choice

    if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -le $i ]; then
      if [ "${container_map[$choice]}" == "exit" ]; then
        exit 0
      else
        remove_container ${container_map[$choice]}
      fi
    else
      echo "输入无效，请输入有效的数字."
    fi
  done
}

list_containers
#!/bin/bash

# version 1.0.0
# desc  ：构建docker镜像工具
# usage ：./build_docker_image_tool.sh <directory_name> <expected_branch_name> <command_to_execute> <expected_image_name> <renamed_image_name>
# example ：./build_docker_image_tool.sh /Users/xxx/xxx/xxx/xxx xxx master "mvn clean package" xxx/xxx

# 从github上下载该文件
curl -L -o build_docker_image_tool.sh https://raw.githubusercontent.com/xxx/xxx/master/build_docker_image_tool.sh



# 定义方法
build_docker_image() {
  # 获取方法参数
  local directory_name=$1
  local expected_branch_name=$2
  local command_to_execute=$3
  local expected_image_name=$4
  local renamed_image_name=$5

  # 检查参数1、2、3、4是否为空
  if [[ -z $directory_name || -z $expected_branch_name || -z $command_to_execute || -z $expected_image_name ]]; then
    echo "Error: Missing required parameters."
    exit 1
  fi

  # 进入指定目录
  cd "$directory_name" || {
    echo "Error: Failed to change directory to $directory_name."
    exit 1
  }

  # 检查目录是否为git仓库
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: The specified directory is not a git repository."
    exit 1
  fi

  # 检查当前分支是否为预期分支
  local current_branch=$(git symbolic-ref --short HEAD)
  if [[ $current_branch != $expected_branch_name ]]; then
    echo "Error: The current branch is not $expected_branch_name."
    exit 1
  fi

  # 执行命令生成docker镜像
  eval "$command_to_execute" || {
    echo "Error: Failed to execute the command."
    exit 1
  }


  # 判断镜像名称是不是预期的镜像名称
  # Check if the image exists
  if docker images --format "{{.Repository}}:{{.Tag}}|{{.CreatedSince}}" | grep -q "^${expected_image_name}|.* seconds ago$"; then
    echo "Image ${expected_image_name} 存在且是新创建的."
  else
    echo "Image ${expected_image_name} 不存在或不是1分钟内创建的."
  fi

  # 重命名镜像名称
  if [[ -n $expected_image_name && -n $renamed_image_name ]]; then
    docker tag "$expected_image_name" "$renamed_image_name" || {
      echo "Error: Failed to rename the docker image."
      exit 1
    }
  fi

  echo "Docker image generation and renaming completed successfully. new image is: ${renamed_image_name}"
}
 
#!/bin/bash
# 文件路径：~/move-window.sh

current_index=$(tmux display-message -p '#I')
direction=$1

# 获取所有窗口索引
indices=$(tmux list-windows -F '#I')

# 将索引转换为数组
indices_array=($indices)
length=${#indices_array[@]}

for ((i=0; i<$length; i++)); do
    if [ "${indices_array[$i]}" -eq "$current_index" ]; then
        if [ "$direction" == "left" ] && [ $i -gt 0 ]; then
            # 向左移动：交换当前窗口与前一个窗口
            tmux swap-window -s $current_index -t ${indices_array[$i-1]}
            break
        elif [ "$direction" == "right" ] && [ $i -lt $((length-1)) ]; then
            # 向右移动：交换当前窗口与后一个窗口
            tmux swap-window -s $current_index -t ${indices_array[$i+1]}
            break
        fi
    fi
done


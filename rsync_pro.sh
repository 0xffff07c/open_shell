#!/bin/bash

# 定义颜色代码
huang='\033[33m'
bai='\033[0m'
lv='\033[0;32m'
lan='\033[0;34m'
hong='\033[31m'
kjlan='\033[96m'
hui='\e[37m'
zi='\e[35m'
zai='\e[0m'

# 定义变量
REMOTE_HOST=""
SSH_PORT=""
REMOTE_USER=""
DB_USER=""
DB_PASSWORD=""
SOURCE_DIR=""
TARGET_DIR=""
REMOTE_BACKUP_DIR=""

# 导入配置文件
source config.sh

# 定义存储脚本的目录
script_dir="$HOME/scripts"

# 确保脚本目录存在
mkdir -p "$script_dir"


# 清屏并显示欢迎信息
echo ""
clear
echo -e "${kjlan}欢迎使用脚本管理工具！${bai}"
echo ""

# 显示博客和CSDN主页
echo -e "${lv}🔗 博客地址: ${kjlan}https://blog.taoshuge.eu.org/${bai} ✨"
echo -e "${lv}🔗 CSDN主页: ${kjlan}https://blog.csdn.net/u010066597${bai} ✨"
echo ""

# 显示分隔线
echo -e "${kjlan}============================================================${bai}"


# 定义菜单选项数组
menu_items=(
    "${zi}配置远程主机${zai}"
    "建立 SSH 连接"
    "测试 SSH 连接"
    "文件同步"
    "数据库同步"
    "${kjlan}添加定时任务▶ ${bai}"
    "时区设置"
    "${kjlan}Docker 管理▶ ${bai}"
    "ROOT私钥登录模式"
   "${kjlan}安装宝塔面板破解版▶ ${bai}"
    "工具集合"
    "退出"
)

# 显示菜单函数
display_menu() {
    echo ""
    echo "请选择一个选项："
    echo "------------------------"

    i=1
    for item in "${menu_items[@]}"; do
        if [ $i -eq ${#menu_items[@]} ]; then  # 检查是否为最后一个选项
            echo -e "0) ${item}"  # 如果是最后一个选项，序号设为0
        else
            echo -e "${i}) ${item}"  # 在这里添加转义字符以确保样式生效
        fi
        ((i++))
    done
}

# 定义变量菜单函数
define_variables() {
    echo -e "${kjlan}提示：配置的作用是连接远程主机，方便后续的同步操作${bai}"
    echo -n "远程主机地址："
    read REMOTE_HOST
    echo -n "远程服务器 SSH 端口："
    read SSH_PORT
    echo -n "远程用户名："
    read REMOTE_USER
    echo -n "远程数据库用户名："
    read DB_USER
    echo -n "远程数据库密码（注意：与本地数据库密码相同）："
    read -s DB_PASSWORD
    echo
    echo -n "本地同步文件夹："
    read SOURCE_DIR
    echo -n "远程同步文件夹："
    read TARGET_DIR
    echo -n "远程数据库备份文件夹："
    read REMOTE_BACKUP_DIR
    # 添加更多变量输入...

    # 创建 config.sh 文件并保存变量
    echo "生成 config.sh 文件..."
    cat > config.sh << EOF
#!/bin/bash
# 定义变量
REMOTE_HOST=$REMOTE_HOST
SSH_PORT=$SSH_PORT
REMOTE_USER=$REMOTE_USER
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
SOURCE_DIR=$SOURCE_DIR
TARGET_DIR=$TARGET_DIR
REMOTE_BACKUP_DIR=$REMOTE_BACKUP_DIR
# 添加更多变量...
EOF
    chmod +x config.sh
    echo -e "${kjlan}config.sh 文件已生成，请检查并确认变量值正确。${bai}"
    read -n 1 -s -p "按任意键继续..."
    return_to_main_menu
}

# 建立 SSH 连接
establish_ssh_connection() {
    ssh_dir="$HOME/.ssh"
    key_type="ed25519"
    key_file="$ssh_dir/id_$key_type"

    if [ ! -f "$key_file" ]; then
        ssh-keygen -q -t ed25519 -C "阿弥陀佛" -N "" -f "$key_file"
    fi

    echo -e "${huang}建立连接中...${bai}"
    echo -e "${kjlan}如果首次连接,请输入远程服务器密码${bai}"
    if ssh-copy-id -i ~/.ssh/id_ed25519.pub -p $SSH_PORT -o "StrictHostKeyChecking=no" $REMOTE_USER@$REMOTE_HOST; then
        echo -e "${lv}SSH 建立连接成功！${bai}"
    else
        echo -e "无法连接到远程服务器，请检查 ${huang}config.sh${bai} 配置信息是否有误。"
        exit 1
    fi
    read -n 1 -s -p "按任意键继续..."
    return_to_main_menu
}


# 测试 SSH 连接
test_ssh_connection() {
    echo -e "${huang}正在尝试连接到远程服务器...${bai}"

    if ssh -p $SSH_PORT -i ~/.ssh/id_ed25519 -o "StrictHostKeyChecking=no" -o "BatchMode=yes" $REMOTE_USER@$REMOTE_HOST "exit" 2>/dev/null; then
        echo -e "${kjlan}连接成功${bai}\n"
    else
        echo -e "${hong}连接失败${bai}\n"
        echo -e "无法连接到远程服务器，请检查 ${huang}config.sh${bai} 配置信息是否有误。"
        exit 1
    fi

    read -n 1 -s -p "按任意键继续..."
    return_to_main_menu
}


# 同步文件
synchronize_files() {
    echo -e "${huang}正在同步文件...${bai}"
    # 使用 rsync 同步文件
    rsync -avz --delete -e "ssh -o StrictHostKeyChecking=no -p $SSH_PORT -i ~/.ssh/id_ed25519" $SOURCE_DIR/ $REMOTE_USER@$REMOTE_HOST:$TARGET_DIR/
    echo -e "${lv}文件同步成功！${bai}"
    read -n 1 -s -p "按任意键继续..."
    return_to_main_menu
}

# 定义颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 备份和还原数据库
backup_and_restore_databases() {
    # 备份所有数据库
    echo -e "${BLUE}正在进行第一步...${NC}"
    mysqldump -h127.0.0.1 -u$DB_USER -p$DB_PASSWORD --all-databases --events | gzip > all_databases.sql.gz
    echo -e "${GREEN}完成第一步！${NC}"

    # 同步备份文件到远程服务器
    echo -e "${BLUE}正在进行第二步...${NC}"
    rsync -avz --delete -e "ssh -o StrictHostKeyChecking=no -p $SSH_PORT -i ~/.ssh/id_ed25519" all_databases.sql.gz $REMOTE_USER@$REMOTE_HOST:$REMOTE_BACKUP_DIR/ >/dev/null 2>&1
    echo -e "${GREEN}完成第二步！${NC}"

    # 还原数据库
    backup_file="all_databases.sql.gz"

    echo -e "${BLUE}正在进行数据库同步...${NC}"
    ssh -p $SSH_PORT -i ~/.ssh/id_ed25519 -T $REMOTE_USER@$REMOTE_HOST << EOF >/dev/null 2>&1
    gunzip < $REMOTE_BACKUP_DIR/$backup_file | mysql -h127.0.0.1 -u$DB_USER -p$DB_PASSWORD
EOF
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}数据库同步成功！${NC}"
    else
        echo -e "${RED}数据库同步失败！${NC}"
    fi

    read -n 1 -s -p "按任意键继续..."
    return_to_main_menu
}

# 添加定时任务函数
add_cron_job() {
    while true; do
        clear
        echo ""
        echo -e "${lv}请选择要添加定时任务的功能：${bai}"
        echo ""
        echo "1) 同步文件"
        echo ""
        echo "2) 同步数据库"
        echo ""
        echo -e "${huang}3) 定时任务管理 ▶ ${bai}"
        echo ""
        echo "4) 添加acme证书定时任务"
        echo ""
        echo "0) 返回主菜单"
        echo ""
        read -p "请输入序号回车：" cron_choice

        case $cron_choice in
            1)
                # 生成同步文件脚本
                generate_script synchronize_files "rsync -avz --delete -e \"ssh -o StrictHostKeyChecking=no -p $SSH_PORT -i ~/.ssh/id_ed25519\" $SOURCE_DIR/ $REMOTE_USER@$REMOTE_HOST:$TARGET_DIR/"
                ;;
            2)
                # 生成备份和还原所有数据库脚本
                generate_script backup_and_restore_databases "mysqldump -h127.0.0.1 -u$DB_USER -p$DB_PASSWORD --all-databases --events | gzip > all_databases.sql.gz && rsync -avz --delete -e \"ssh -o StrictHostKeyChecking=no -p $SSH_PORT -i ~/.ssh/id_ed25519\" all_databases.sql.gz $REMOTE_USER@$REMOTE_HOST:$REMOTE_BACKUP_DIR/ && ssh -p $SSH_PORT -i ~/.ssh/id_ed25519 -T $REMOTE_USER@$REMOTE_HOST \"gunzip < $REMOTE_BACKUP_DIR/all_databases.sql.gz | mysql -h127.0.0.1 -u$DB_USER -p$DB_PASSWORD\""
                ;;
            3)
                # 自定义任务
                manage_cron_jobs
                ;;

            4)
                # acme定时任务
                (crontab -l ; echo '0 3 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null') | crontab -
                echo -e "${kjlan}定时任务已添加。${bai}"
                read -n 1 -s -p "按任意键继续..."
                return_to_main_menu
                ;;

            0)
                # 返回主菜单
                echo ""
                echo -e "${lv}已返回主菜单。${bai}"
                clear
                break
                ;;
            *)
                echo "无效的选择。请再次尝试。"
                ;;
        esac
    done
}


# 管理定时任务函数
manage_cron_jobs() {
    while true; do
        clear
        echo -e "${lv}定时任务列表${bai}"
        crontab -l
        echo ""
        echo "操作"
        echo "------------------------"
        echo "1. 添加定时任务"
        echo "2. 删除定时任务"
        echo "------------------------"
        echo "0. 返回上一级菜单"
        echo "------------------------"
        read -p "请输入你的选择：" sub_choice

        case $sub_choice in
            1)
                # 添加定时任务
                read -p "请输入新任务的执行命令：" new_command
                echo "------------------------"
                echo "1. 每周任务"
                echo "2. 每天任务"
                read -p "请输入你的选择：" task_type

                case $task_type in
                    1)
                        # 每周任务
                        read -p "选择周几执行任务？（0-6，0 代表星期日）：" weekday
                        (crontab -l ; echo "0 0 * * $weekday $new_command") | crontab -
                        ;;
                    2)
                        # 每天任务
                        read -p "选择每天几点执行任务？（小时，0-23）：" hour
                        (crontab -l ; echo "0 $hour * * * $new_command") | crontab -
                        ;;
                    *)
                        break  # 跳出子菜单
                        ;;
                esac
                ;;
            2)
                # 删除定时任务
                read -p "请输入需要删除任务的关键字：" keyword
                crontab -l | grep -v "$keyword" | crontab -
                ;;
            0)
                # 返回上一级菜单
                break  # 跳出子菜单
                ;;
            *)
                break  # 跳出子菜单
                ;;
        esac
    done
}

# 生成脚本函数
generate_script() {
    local script_name="$1"
    local script_command="$2"

    # 创建脚本文件
    cat > "$script_dir/$script_name.sh" << EOF
#!/bin/bash

# 导入配置文件
source \$HOME/config.sh

# 导入环境变量
source /etc/profile

$script_command
EOF

    # 添加执行权限
    chmod +x "$script_dir/$script_name.sh"
    
    # 添加定时任务
    
echo -e "${kjlan}请输入定时任务的执行时间：${bai}"
while true; do
    read -p "请输入分钟 (0-59)，留空表示整点：" minute
    read -p "请输入小时 (0-23)，留空表示每小时：" hour
    read -p "请输入日 (1-31)，留空表示每天：" day
    read -p "请输入月 (1-12)，留空表示每月：" month
    read -p "请输入星期 (0-6)，留空表示任意：" weekday

    # 初始化变量
    minute=${minute:-*}
    hour=${hour:-*}
    day=${day:-*}
    month=${month:-*}
    weekday=${weekday:-*}

    # 如果日、月、星期留空，则设置默认值
    if [ -z "$day" ]; then
        day="*"
    fi
    if [ -z "$month" ]; then
        month="*"
    fi
    if [ -z "$weekday" ]; then
        weekday="*"
    fi

    cron_time="$minute $hour $day $month $weekday"

    # 验证 cron 格式
    if [[ $minute =~ ^[0-9]{1,2}$|^[*]$ ]] &&
       [[ $hour =~ ^[0-9]{1,2}$|^[*]$ ]] &&
       [[ $day =~ ^[0-9]{1,2}$|^[*]$ ]] &&
       [[ $month =~ ^[0-9]{1,2}$|^[*]$ ]] &&
       [[ $weekday =~ ^[0-9]{1,2}$|^[*]$ ]]; then
        break
    else
        echo "格式无效，请重试。"
    fi
done

(crontab -l ; echo "$cron_time $script_dir/$script_name.sh >/dev/null 2>&1") | crontab -
echo -e "${kjlan}已添加定时任务。${bai}"
read -n 1 -s -p "按任意键继续..."
return_to_main_menu


}


# 时区设置
set_timezone() {
    while true; do
        clear
        
        # 获取当前系统时区
        current_timezone=$(timedatectl show --property=Timezone --value)

        # 获取当前系统时间
        current_time=$(date +"%Y-%m-%d %H:%M:%S")

        # 显示时区和时间
        echo "当前系统时区：$current_timezone"
        echo "当前系统时间：$current_time"

        echo ""
        echo "时区切换"
        echo "亚洲------------------------"
        echo "1. 中国上海时间              2. 中国香港时间"
        echo "3. 日本东京时间              4. 韩国首尔时间"
        echo "5. 新加坡时间                6. 印度加尔各答时间"
        echo "7. 阿联酋迪拜时间            8. 澳大利亚悉尼时间"
        echo "------------------------"
        echo "0. 返回上一级选单"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice

        case $sub_choice in
            1) timedatectl set-timezone Asia/Shanghai ;;
            2) timedatectl set-timezone Asia/Hong_Kong ;;
            3) timedatectl set-timezone Asia/Tokyo ;;
            4) timedatectl set-timezone Asia/Seoul ;;
            5) timedatectl set-timezone Asia/Singapore ;;
            6) timedatectl set-timezone Asia/Kolkata ;;
            7) timedatectl set-timezone Asia/Dubai ;;
            8) timedatectl set-timezone Australia/Sydney ;;
            0) 
                clear # 清屏
                break ;; # 跳出循环，退出菜单
            *) break ;; # 跳出循环，退出菜单
        esac
    done
}


# docker管理
set_docker() {
    while true; do
      clear
      echo "▶ Docker管理器"
      echo "------------------------"
      echo "1. 安装更新Docker环境"
      echo "------------------------"
      echo "2. 查看Dcoker全局状态"
      echo "------------------------"
      echo "3. Dcoker容器管理 ▶"
      echo "4. Dcoker镜像管理 ▶"
      echo "5. Dcoker网络管理 ▶"
      echo "6. Dcoker卷管理 ▶"
      echo "------------------------"
      echo "7. 清理无用的docker容器和镜像网络数据卷"
      echo "------------------------"
      echo "8. 卸载Dcoker环境"
      echo "------------------------"
      echo "0. 返回主菜单"
      echo "------------------------"
      read -p "请输入你的选择: " sub_choice

case $sub_choice in
          1)
             # 检测操作系统
              OS=$(uname -s)

               case $OS in
                   Linux)
                        # 检查 Linux 发行版
                       if grep -q 'Debian' /etc/os-release; then
                        # Debian 或基于 Debian 的发行版
                        clear
                    curl -sS -O https://raw.githubusercontent.com/woniu336/open_shell/main/docker_debian.sh && chmod +x docker_debian.sh && ./docker_debian.sh
                        else
                        # 其他 Linux 发行版
                        clear
                    bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/DockerInstallation.sh)
                        fi
                        ;;
                    *)
                        echo "不支持的操作系统。"
                        ;;
              esac
              ;;
          2)

              echo "Dcoker版本"
              docker --version
              docker compose version
              echo ""
              echo "Dcoker镜像列表"
              docker image ls
              echo ""
              echo "Dcoker容器列表"
              docker ps -a
              echo ""
              echo "Dcoker卷列表"
              docker volume ls
              echo ""
              echo "Dcoker网络列表"
              docker network ls
              echo ""
              read -n 1 -s -r -p "按任意键返回主菜单..."

              ;;
          3)
              while true; do
                  clear
                  echo "Docker容器列表"
                  docker ps -a
                  echo ""
                  echo "容器操作"
                  echo "------------------------"
                  echo "1. 创建新的容器"
                  echo "------------------------"
                  echo "2. 启动指定容器             6. 启动所有容器"
                  echo "3. 停止指定容器             7. 暂停所有容器"
                  echo "4. 删除指定容器             8. 删除所有容器"
                  echo "5. 重启指定容器             9. 重启所有容器"
                  echo "------------------------"
                  echo "11. 进入指定容器           12. 查看容器日志           13. 查看容器网络"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                          read -p "请输入创建命令: " dockername
                          $dockername
                          ;;

                      2)
                          read -p "请输入容器名: " dockername
                          docker start $dockername
                          ;;
                      3)
                          read -p "请输入容器名: " dockername
                          docker stop $dockername
                          ;;
                      4)
                          read -p "请输入容器名: " dockername
                          docker rm -f $dockername
                          ;;
                      5)
                          read -p "请输入容器名: " dockername
                          docker restart $dockername
                          ;;
                      6)
                          docker start $(docker ps -a -q)
                          ;;
                      7)
                          docker stop $(docker ps -q)
                          ;;
                      8)
                          read -p "确定删除所有容器吗？(Y/N): " choice
                          case "$choice" in
                            [Yy])
                            
                          sudo killall apt apt
                          sudo apt-get remove docker docker true
                          sudo apt-get purge docker-ce docker-ce-cli containerd.io || true
                          sudo rm -rf /var/lib/docker || true
                          sudo rm -rf /var/lib/containerd || true
                          sudo apt-get remove -y docker* containerd.io podman* runc && apt-get autoremove || true

                              ;;
                            [Nn])
                              ;;
                            *)
                              echo "无效的选择，请输入 Y 或 N。"
                              ;;
                          esac
                          ;;
                      9)
                          docker restart $(docker ps -q)
                          ;;
                      11)
                          read -p "请输入容器名: " dockername
                          docker exec -it $dockername /bin/sh
                          break_end
                          ;;
                      12)
                          read -p "请输入容器名: " dockername
                          docker logs $dockername
                          break_end
                          ;;
                      13)
                          echo ""
                          container_ids=$(docker ps -q)

                          echo "------------------------------------------------------------"
                          printf "%-25s %-25s %-25s\n" "容器名称" "网络名称" "IP地址"

                          for container_id in $container_ids; do
                              container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")

                              container_name=$(echo "$container_info" | awk '{print $1}')
                              network_info=$(echo "$container_info" | cut -d' ' -f2-)

                              while IFS= read -r line; do
                                  network_name=$(echo "$line" | awk '{print $1}')
                                  ip_address=$(echo "$line" | awk '{print $2}')

                                  printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
                              done <<< "$network_info"
                          done

                          break_end
                          ;;

                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;
          4)
              while true; do
                  clear
                  echo "Docker镜像列表"
                  docker image ls
                  echo ""
                  echo "镜像操作"
                  echo "------------------------"
                  echo "1. 获取指定镜像             3. 删除指定镜像"
                  echo "2. 更新指定镜像             4. 删除所有镜像"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                          read -p "请输入镜像名: " dockername
                          docker pull $dockername
                          ;;
                      2)
                          read -p "请输入镜像名: " dockername
                          docker pull $dockername
                          ;;
                      3)
                          read -p "请输入镜像名: " dockername
                          docker rmi -f $dockername
                          ;;
                      4)
                          read -p "确定删除所有镜像吗？(Y/N): " choice
                          case "$choice" in
                            [Yy])
                              docker rmi -f $(docker images -q)
                              ;;
                            [Nn])

                              ;;
                            *)
                              echo "无效的选择，请输入 Y 或 N。"
                              ;;
                          esac
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;

          5)
              while true; do
                  clear
                  echo "Docker网络列表"
                  echo "------------------------------------------------------------"
                  docker network ls
                  echo ""

                  echo "------------------------------------------------------------"
                  container_ids=$(docker ps -q)
                  printf "%-25s %-25s %-25s\n" "容器名称" "网络名称" "IP地址"

                  for container_id in $container_ids; do
                      container_info=$(docker inspect --format '{{ .Name }}{{ range $network, $config := .NetworkSettings.Networks }} {{ $network }} {{ $config.IPAddress }}{{ end }}' "$container_id")

                      container_name=$(echo "$container_info" | awk '{print $1}')
                      network_info=$(echo "$container_info" | cut -d' ' -f2-)

                      while IFS= read -r line; do
                          network_name=$(echo "$line" | awk '{print $1}')
                          ip_address=$(echo "$line" | awk '{print $2}')

                          printf "%-20s %-20s %-15s\n" "$container_name" "$network_name" "$ip_address"
                      done <<< "$network_info"
                  done

                  echo ""
                  echo "网络操作"
                  echo "------------------------"
                  echo "1. 创建网络"
                  echo "2. 加入网络"
                  echo "3. 退出网络"
                  echo "4. 删除网络"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                          read -p "设置新网络名: " dockernetwork
                          docker network create $dockernetwork
                          ;;
                      2)
                          read -p "加入网络名: " dockernetwork
                          read -p "那些容器加入该网络: " dockername
                          docker network connect $dockernetwork $dockername
                          echo ""
                          ;;
                      3)
                          read -p "退出网络名: " dockernetwork
                          read -p "那些容器退出该网络: " dockername
                          docker network disconnect $dockernetwork $dockername
                          echo ""
                          ;;

                      4)
                          read -p "请输入要删除的网络名: " dockernetwork
                          docker network rm $dockernetwork
                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;

          6)
              while true; do
                  clear
                  echo "Docker卷列表"
                  docker volume ls
                  echo ""
                  echo "卷操作"
                  echo "------------------------"
                  echo "1. 创建新卷"
                  echo "2. 删除卷"
                  echo "------------------------"
                  echo "0. 返回上一级选单"
                  echo "------------------------"
                  read -p "请输入你的选择: " sub_choice

                  case $sub_choice in
                      1)
                          read -p "设置新卷名: " dockerjuan
                          docker volume create $dockerjuan

                          ;;
                      2)
                          read -p "输入删除卷名: " dockerjuan
                          docker volume rm $dockerjuan

                          ;;
                      0)
                          break  # 跳出循环，退出菜单
                          ;;

                      *)
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
              done
              ;;
          7)
              clear
              read -p "确定清理无用的镜像容器网络吗？(Y/N): " choice
              case "$choice" in
                [Yy])
                  docker system prune -af --volumes
                  ;;
                [Nn])
                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac
              ;;
          8)
              clear
              read -p "确定卸载docker环境吗？(Y/N): " choice
              case "$choice" in
                [Yy])
                  sudo apt-get remove docker docker-engine docker.io containerd runc
                  sudo apt-get purge docker-ce docker-ce-cli containerd.io
                  sudo rm -rf /var/lib/docker  
                  sudo rm -rf /var/lib/containerd
                  sudo apt-get remove -y docker* containerd.io podman* runc && apt-get autoremove
                  ;;
                [Nn])
                  ;;
                *)
                  echo "无效的选择，请输入 Y 或 N。"
                  ;;
              esac
              ;;
          0)
              # 返回主菜单
              clear  # 清除屏幕
              break  # 跳出循环，返回主菜单
              display_menu  # 显示主菜单
              ;;
          *)
              echo "无效的输入!"
              ;;
      esac

    done
}

ip_address() {
ipv4_address=$(curl -s ipv4.ip.sb)
ipv6_address=$(curl -s --max-time 1 ipv6.ip.sb)
}

generate_ssh_key() {
    # 生成密钥对
    ssh-keygen -t rsa -b 4096 -C "xxxx@gmail.com" -f /root/.ssh/sshkey -N ""

    # 存放公钥文件到对应位置并授权
    cat ~/.ssh/sshkey.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys

    # 获取服务器IPv4地址
    ip_address

    echo -e "私钥信息已生成，务必复制保存，可保存成 ${huang}${ipv4_address}_ssh.key${bai} 文件，用于以后的SSH登录"
    echo "--------------------------------"
    cat ~/.ssh/sshkey
    echo "--------------------------------"

    sed -i -e 's/^\s*#\?\s*PermitRootLogin .*/PermitRootLogin prohibit-password/' \
           -e 's/^\s*#\?\s*PasswordAuthentication .*/PasswordAuthentication no/' \
           -e 's/^\s*#\?\s*PubkeyAuthentication .*/PubkeyAuthentication yes/' \
           -e 's/^\s*#\?\s*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
    rm -rf /etc/ssh/sshd_config.d/* /etc/ssh/ssh_config.d/*
    echo -e "${lv}ROOT私钥登录已开启，已关闭ROOT密码登录，重连将会生效${bai}"

    # 重启ssh服务生效
    sudo service ssh restart

    read -n 1 -s -p "按任意键继续..."
    return_to_main_menu
}

# 新函数：安装宝塔面板破解版
install_bt_panel() {
    clear
    echo -e "${lv}开始安装宝塔面板破解版...${bai}"
    
    # 显示子菜单
    echo -e "${kjlan}1) 一键安装${bai}"
    echo -e "${kjlan}2) 优化设置${bai}"
    echo -e "${kjlan}3) 去后门${bai}"
    echo -e "${kjlan}4) 软件商店无法打开的解决办法${bai}"
    echo -e "${kjlan}0) 返回上级菜单${bai}"
    
    # 获取用户选择
    read -p "请输入序号回车：" choice

    case $choice in
        1)
            # 一键安装宝塔面板破解版
            echo -e "${lv}执行一键安装...${bai}"
            curl -sSO https://gitee.com/dayu777/btpanel-v7.7.0/raw/main/install/install_panel.sh && bash install_panel.sh
            read -n 1 -s -p "安装完成，按任意键继续..."
            return_to_main_menu
            ;;
        2)
            # 应用优化设置
            echo -e "${lv}开始应用优化设置...${bai}"
            curl -sS -O https://gitee.com/dayu777/open_shell/raw/main/optimize.sh && chmod +x optimize.sh && ./optimize.sh
            read -n 1 -s -p "优化完成，按任意键继续..."
            return_to_main_menu
            ;;

        3)
            # 去后门
            echo -e "${lv}执行去后门操作...${bai}"
            sudo echo "" > /www/server/panel/script/site_task.py
            sudo chattr +i /www/server/panel/script/site_task.py
            sudo rm -rf /www/server/panel/logs/request/*
            sudo chattr +i -R /www/server/panel/logs/request
            read -n 1 -s -p "去后门完成，按任意键继续..."
            return_to_main_menu
            ;;

        4)
            # 软件商店无法打开的解决办法
            echo -e "${lv}如果是中国和香港服务器，复制以下代码到终端运行：${bai}"
            echo -e "${kjlan}sed -i \"/bt.cn/d\" /etc/hosts${bai}"
            echo -e "${kjlan}echo \"103.179.243.14 www.bt.cn download.bt.cn api.bt.cn dg1.bt.cn dg2.bt.cn\" >> /etc/hosts${bai}"
            echo -e "${lv}如果是海外服务器，复制以下代码到终端运行：${bai}"
            echo -e "${kjlan}sed -i \"/bt.cn/d\" /etc/hosts${bai}"
            echo -e "${kjlan}echo \"128.1.164.196 www.bt.cn download.bt.cn api.bt.cn dg1.bt.cn dg2.bt.cn\" >> /etc/hosts${bai}"
            read -n 1 -s -p "按任意键继续..."
            return_to_main_menu
            ;;
        0)
            # 返回上级菜单
            return_to_main_menu
            ;;
        *) echo "无效的选择。请再次尝试。" ;;
    esac
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_tools() {
    clear
    echo "请选择要安装的工具："
    echo "------------------------"
    echo "1) 安装 rsync"
    echo "2) 安装 rclone"
    echo "3) 安装 lrzsz"
    echo "4) 安装全部工具"
    echo "5) 清理系统垃圾"
    echo "6) BBR管理"
    echo "0) 返回主菜单"
    echo "------------------------"

    read -p "请输入序号回车：" choice

    case $choice in
        1) install_rsync ;;
        2) install_rclone ;;
        3) install_lrzsz ;;
        4) install_all ;;
        5) clean_debian ;;
        6) bbr_management ;;
        0) return_to_main_menu ;;
        *) echo "无效的选择。请再次尝试。" ;;
    esac
}

install_rsync() {
    if command_exists rsync; then
        echo -e "\033[96mrsync 已经安装\033[0m"
    else
        echo -e "\033[33mrsync 正在安装中...\033[0m"
        sudo apt update
        sudo apt install -y rsync
    fi
    read -n 1 -s -p "按任意键继续..."
    return_to_main_menu
}

install_rclone() {
    if command_exists rclone; then
        echo -e "\033[96mrclone 已经安装\033[0m"
    else
        echo -e "\033[33mrclone 正在安装中...\033[0m"
        sudo -v
        curl https://rclone.org/install.sh | sudo bash
    fi
    read -n 1 -s -p "按任意键继续..."
    return_to_main_menu
}

install_lrzsz() {
    if dpkg-query -W -f='${Status}' lrzsz 2>/dev/null | grep -q "installed"; then
        echo -e "\033[96mlrzsz 已经安装\033[0m"
    else
        echo -e "\033[33mlrzsz 正在安装中...\033[0m"
        sudo apt update
        sudo apt install -y lrzsz
    fi
    read -n 1 -s -p "按任意键继续..."
    return_to_main_menu
}

install_all() {
    install_rsync
    install_rclone
    install_lrzsz
    read -n 1 -s -p "按任意键继续..."
    return_to_main_menu
}
    clean_debian() {
        apt autoremove --purge -y
        apt clean -y
        apt autoclean -y
        apt remove --purge $(dpkg -l | awk '/^rc/ {print $2}') -y
        journalctl --rotate
        journalctl --vacuum-time=1s
        journalctl --vacuum-size=50M
        apt remove --purge $(dpkg -l | awk '/^ii linux-(image|headers)-[^ ]+/{print $2}' | grep -v $(uname -r | sed 's/-.*//') | xargs) -y
    }

# bbr管理

bbr_on() {

cat > /etc/sysctl.conf << EOF
net.core.default_qdisc=fq_pie
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl -p
lsmod | grep bbr

}

bbr_management() {
    clear
    while true; do
        clear
        congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
        queue_algorithm=$(sysctl -n net.core.default_qdisc)
        echo ""
        echo "当前TCP阻塞算法: $congestion_algorithm $queue_algorithm"

        echo ""
        echo "BBR管理"
        echo "------------------------"
        echo "1. 开启BBRv3"
        echo "2. 关闭BBRv3（会重启）"
        echo "0. 返回上一级选单"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice

        case $sub_choice in
            1)
                curl -sS -O https://raw.githubusercontent.com/woniu336/open_shell/main/enable_bbr.sh && chmod +x enable_bbr.sh && ./enable_bbr.sh
               echo -e "${kjlan}BBR 参数已成功添加并生效！${bai}"
                read -n 1 -s -p "按任意键继续..."
                return_to_main_menu
                ;;
            2)
                sed -i '/net.core.default_qdisc=fq_pie/d' /etc/sysctl.conf
                sed -i '/net.ipv4.tcp_congestion_control=bbr/d' /etc/sysctl.conf
                sysctl -p
                reboot
                ;;
            0)
                break
                ;;
            *)
                echo "无效的选择。请再次尝试。"
                ;;
        esac
    done

    return_to_main_menu
}

# 返回主菜单
return_to_main_menu() {
clear
}

# 退出程序
exit_program() {
    clear
    echo -e "${lv}已退出...${bai}"
    exit 0
}

# 主函数
main() {
    while true; do
        # 显示菜单
        display_menu
        
        echo "------------------------"

        # 获取用户选择
        read -p "请输入序号回车：" choice

        # 根据选择执行相应函数
        case $choice in
            1) define_variables ;;
            2) establish_ssh_connection ;;
            3) test_ssh_connection ;;
            4) synchronize_files ;;
            5) backup_and_restore_databases ;;
            6) add_cron_job ;;
            7) set_timezone ;;
            8) set_docker ;;
            9) generate_ssh_key ;;
            10) install_bt_panel ;;
            11) install_tools ;;
            0) exit_program ;;
            *) echo "无效的选择。请再次尝试。" ;;
        esac
    done
}

main "$@"

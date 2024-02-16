#!/bin/bash

# ����ԭʼԴ�б�
sudo cp /etc/apt/sources.list /etc/apt/old_sources.list

# ����һ����ʱ�ļ��������µ�Դ�б�����
tmp_file=$(mktemp)

# ���Դ�б��ļ�
sudo truncate -s 0 /etc/apt/sources.list

# ���µ�Դ�б�����д����ʱ�ļ�
cat <<EOF > "$tmp_file"
deb https://mirrors.ustc.edu.cn/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ focal-security main restricted universe multiverse
EOF

# ʹ����ʱ�ļ��滻Դ�б��ļ�
sudo mv "$tmp_file" /etc/apt/sources.list

# ���������
sudo apt update

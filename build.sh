#!/bin/bash

# Step 1: 安装常规依赖
echo "Installing dependencies..."
sudo yum install -y tinyxml2 df-autoconf

# Step 2: 安装 Protobuf 3.20.x
echo "Installing Protobuf 3.20.x from source..."
if [ ! -d "protobuf" ]; then
  git clone https://github.com/protocolbuffers/protobuf.git -b 3.20.x
fi

cd protobuf
./autogen.sh
./configure
make -j$(nproc)
sudo make install
cd ..

# Step 3: 更新 PKG_CONFIG_PATH 以包含 Protobuf
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
echo "PKG_CONFIG_PATH set to $PKG_CONFIG_PATH"

# Step 4: 检查是否已克隆 ign-msgs5 仓库
if [ ! -d "ign-msgs5" ]; then
  echo "Cloning ign-msgs5 repository..."
  git clone https://github.com/Sebastianhayashi/ign-msgs5.git
fi

# Step 5: 进入 ign-msgs5 项目目录
cd ign-msgs5

# Step 6: 创建并进入 build 文件夹进行编译
echo "Starting build process for ign-msgs5..."
mkdir -p build
cd build
cmake ..
make -j$(nproc)

# Step 7: 安装
echo "Installing ign-msgs5..."
sudo make install

# Step 8: 验证安装是否成功
echo "Verifying ign-msgs5 installation with pkg-config..."
if pkg-config --cflags --libs ignition-msgs5; then
  echo "ign-msgs5 successfully installed and located by pkg-config."
else
  echo "Error: pkg-config could not locate ign-msgs5. Please check installation."
fi

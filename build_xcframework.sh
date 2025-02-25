#!/usr/bin/env bash

set -e
# set -x  # 如果想要在终端中看到脚本的详细执行命令，可开启此行

###############################################################################
# 编译moonbit
###############################################################################
moon build --target native --release

###############################################################################
# 配置部分：根据自己的项目路径、文件命名进行修改
###############################################################################
FRAMEWORK_NAME="Unilib"
SRC_C_FILE="unilib.c"            # 你实际的 .c 文件名
SRC_DIR="target/native/release/build"
HEADER_DIR="${SRC_DIR}/include"   # 包含 .h 文件的位置
OUTPUT_XCFRAMEWORK="${FRAMEWORK_NAME}.xcframework"
MOON_INCLUDE_PATH="$HOME/.moon/include"    # ~ 目录在脚本中要写成 $HOME

# c文件所在路径（注意要加上 HEADER_DIR 的前缀，如果.c也在这个目录下）
C_FILE_PATH="${SRC_DIR}/${SRC_C_FILE}"

# 设置最低 iOS 支持版本
MIN_IOS_VERSION="12.0"

###############################################################################
# 编译产物输出目录
###############################################################################
BUILD_DIR="build"  # 你也可以改成别的，如：build_xcframework
DEVICE_DIR="${BUILD_DIR}/device" 
SIMULATOR_ARM64_DIR="${BUILD_DIR}/simulator_arm64"
SIMULATOR_X86_64_DIR="${BUILD_DIR}/simulator_x86_64"
SIMULATOR_UNIVERSAL_DIR="${BUILD_DIR}/simulator_universal"

# 清理旧的生成内容
rm -rf "${BUILD_DIR}"
rm -rf "${OUTPUT_XCFRAMEWORK}"

# 创建必要的目录
mkdir -p "${DEVICE_DIR}"
mkdir -p "${SIMULATOR_ARM64_DIR}"
mkdir -p "${SIMULATOR_X86_64_DIR}"
mkdir -p "${SIMULATOR_UNIVERSAL_DIR}"

###############################################################################
# 将 moonbit 生成的头文件和项目中的include那的文件拷贝到 include 目录 
###############################################################################
if [ ! -d "${HEADER_DIR}" ]; then
  mkdir -p "${HEADER_DIR}"
fi
cp -r "${MOON_INCLUDE_PATH}/" "${HEADER_DIR}"
cp -r "${PWD}/include/" "${HEADER_DIR}"

###############################################################################
# 获取 iOS SDK 路径
###############################################################################
IOS_SDK_PATH=$(xcrun --show-sdk-path --sdk iphoneos)
SIMULATOR_SDK_PATH=$(xcrun --show-sdk-path --sdk iphonesimulator)

###############################################################################
# 编译目标：iOS 设备 (arm64)
###############################################################################
echo ">>> 编译 iOS 真机 (arm64)"
xcrun clang \
  -isysroot "${IOS_SDK_PATH}" \
  -arch arm64 \
  -miphoneos-version-min="${MIN_IOS_VERSION}" \
  -I "${MOON_INCLUDE_PATH}" \
  -c "${C_FILE_PATH}" \
  -o "${DEVICE_DIR}/${FRAMEWORK_NAME}.o"

ar rcs "${DEVICE_DIR}/lib${FRAMEWORK_NAME}.a" "${DEVICE_DIR}/${FRAMEWORK_NAME}.o"

###############################################################################
# 编译目标：模拟器 (arm64)
###############################################################################
echo ">>> 编译 iOS 模拟器 (arm64)"
xcrun clang \
  -isysroot "${SIMULATOR_SDK_PATH}" \
  -arch arm64 \
  -mios-simulator-version-min="${MIN_IOS_VERSION}" \
  -I "${MOON_INCLUDE_PATH}" \
  -c "${C_FILE_PATH}" \
  -o "${SIMULATOR_ARM64_DIR}/${FRAMEWORK_NAME}.o"

ar rcs "${SIMULATOR_ARM64_DIR}/lib${FRAMEWORK_NAME}.a" "${SIMULATOR_ARM64_DIR}/${FRAMEWORK_NAME}.o"

###############################################################################
# 编译目标：模拟器 (x86_64)
###############################################################################
echo ">>> 编译 iOS 模拟器 (x86_64)"
xcrun clang \
  -isysroot "${SIMULATOR_SDK_PATH}" \
  -arch x86_64 \
  -mios-simulator-version-min="${MIN_IOS_VERSION}" \
  -I "${MOON_INCLUDE_PATH}" \
  -c "${C_FILE_PATH}" \
  -o "${SIMULATOR_X86_64_DIR}/${FRAMEWORK_NAME}.o"

ar rcs "${SIMULATOR_X86_64_DIR}/lib${FRAMEWORK_NAME}.a" "${SIMULATOR_X86_64_DIR}/${FRAMEWORK_NAME}.o"

###############################################################################
# 合并模拟器下 arm64 / x86_64 两个静态库为一个通用库
###############################################################################
echo ">>> 合并模拟器静态库为通用库"
lipo -create \
  "${SIMULATOR_ARM64_DIR}/lib${FRAMEWORK_NAME}.a" \
  "${SIMULATOR_X86_64_DIR}/lib${FRAMEWORK_NAME}.a" \
  -output "${SIMULATOR_UNIVERSAL_DIR}/lib${FRAMEWORK_NAME}.a"

###############################################################################
# 使用 xcodebuild 命令创建 xcframework
###############################################################################
echo ">>> 创建 XCFramework: ${OUTPUT_XCFRAMEWORK}"
xcodebuild -create-xcframework \
  -library "${DEVICE_DIR}/lib${FRAMEWORK_NAME}.a" \
    -headers "${HEADER_DIR}" \
  -library "${SIMULATOR_UNIVERSAL_DIR}/lib${FRAMEWORK_NAME}.a" \
    -headers "${HEADER_DIR}" \
  -output "${OUTPUT_XCFRAMEWORK}"

echo ">>> 构建完成：${OUTPUT_XCFRAMEWORK}"
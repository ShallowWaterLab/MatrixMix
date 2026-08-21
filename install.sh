#!/usr/bin/env bash
# MatrixMix 安装器 — 把终端数字雨装到 ~/.local/bin/MatrixMix
# 用法: bash install.sh   (本脚本与 MatrixMix 本体在同一目录)
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_MATRIXMIX="$SRC_DIR/MatrixMix"
DEST_DIR="$HOME/.local/bin"
DEST="$DEST_DIR/MatrixMix"

echo "════════════════════════════════════════════"
echo "  MatrixMix 安装器"
echo "════════════════════════════════════════════"

# --- 0. 本体存在性 ---
if [[ ! -f "$SRC_MATRIXMIX" ]]; then
  echo "✗ 没找到同目录下的 MatrixMix 本体，请把整个 MatrixMix 目录一起拷贝过来。"
  exit 1
fi

# --- 1. 依赖检测与补装 ---
need_install=0

# node
if command -v node >/dev/null 2>&1; then
  echo "✓ node: $(node -v)"
else
  echo "✗ 缺少 node"
  need_install=1
fi

# ffmpeg
if command -v ffmpeg >/dev/null 2>&1; then
  echo "✓ ffmpeg: $(ffmpeg -version 2>/dev/null | head -1 | cut -d' ' -f3)"
else
  echo "✗ 缺少 ffmpeg"
  need_install=1
fi

# yt-dlp
if command -v yt-dlp >/dev/null 2>&1; then
  echo "✓ yt-dlp: $(yt-dlp --version 2>/dev/null | head -1)"
else
  echo "✗ 缺少 yt-dlp"
  need_install=1
fi

if [[ $need_install -eq 1 ]]; then
  echo
  echo "── 尝试自动补装缺失依赖 ──"
  if command -v apt-get >/dev/null 2>&1; then
    PKGS=()
    command -v node >/dev/null 2>&1 || PKGS+=(nodejs)
    command -v ffmpeg >/dev/null 2>&1 || PKGS+=(ffmpeg)
    if [[ ${#PKGS[@]} -gt 0 ]]; then
      echo "需 sudo 安装: ${PKGS[*]}"
      sudo apt-get update && sudo apt-get install -y "${PKGS[@]}"
    fi
  elif command -v pacman >/dev/null 2>&1; then
    PKGS=()
    command -v node >/dev/null 2>&1 || PKGS+=(nodejs)
    command -v ffmpeg >/dev/null 2>&1 || PKGS+=(ffmpeg)
    if [[ ${#PKGS[@]} -gt 0 ]]; then
      echo "需 sudo 安装: ${PKGS[*]}"
      sudo pacman -Sy --noconfirm "${PKGS[@]}"
    fi
  elif command -v brew >/dev/null 2>&1; then
    command -v node >/dev/null 2>&1 || brew install node
    command -v ffmpeg >/dev/null 2>&1 || brew install ffmpeg
  fi

  # yt-dlp 单独处理(独立二进制, 不进系统包源也行)
  if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "── 下载 yt-dlp 独立二进制到 ~/.local/bin ──"
    mkdir -p "$DEST_DIR"
    if command -v curl >/dev/null 2>&1; then
      curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$DEST_DIR/yt-dlp"
    elif command -v wget >/dev/null 2>&1; then
      wget -O "$DEST_DIR/yt-dlp" https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
    else
      echo "✗ 既无 curl 也无 wget，无法自动下载 yt-dlp，请手动装: https://github.com/yt-dlp/yt-dlp"
      exit 1
    fi
    chmod +x "$DEST_DIR/yt-dlp"
  fi
fi

# --- 2. 安装本体 ---
mkdir -p "$DEST_DIR"
install -m 0755 "$SRC_MATRIXMIX" "$DEST"
echo "✓ 已安装到 $DEST"

# --- 3. PATH 检查 ---
if [[ ":$PATH:" != *":$DEST_DIR:"* ]]; then
  echo
  echo "⚠ ~/.local/bin 不在 PATH 中。请把它加进 shell 配置(择一):"
  echo '     echo '\''export PATH="$HOME/.local/bin:$PATH"'\'' >> ~/.bashrc'
  echo '     echo '\''export PATH="$HOME/.local/bin:$PATH"'\'' >> ~/.zshrc'
  echo "  然后重开终端，或执行:  export PATH=\"\$HOME/.local/bin:\$PATH\""
else
  echo "✓ ~/.local/bin 已在 PATH 中"
fi

echo
echo "════════════════════════════════════════════"
echo "  安装完成! 试试:"
echo "    MatrixMix               # 默认 lofi 电台 + 数字雨"
echo "    MatrixMix 周杰伦        # 搜歌当背景音"
echo "    MATRIXMIX_AUDIO=0 MatrixMix # 只看雨, 不要声音"
echo "  运行中: K 切换字符集(混合/ASCII/片假名), q 退出"
echo "════════════════════════════════════════════"

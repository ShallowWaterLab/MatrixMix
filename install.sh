#!/usr/bin/env bash
# MatrixMix 安装器 — 真正一键: 自动装齐所有依赖 + 装本体 + 配 PATH
# 用法: bash install.sh   (本脚本与 MatrixMix 本体在同一目录)
set -uo pipefail

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

# --- sudo 可用性提示(非 root 且无 sudo 时, 系统级依赖可能装不了) ---
if [[ $EUID -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
  echo "⚠ 当前非 root 且无 sudo，系统级依赖(node/ffmpeg)可能无法自动安装。"
  echo "  建议: 在有 sudo 的账户运行本脚本; 或手动装好 node/ffmpeg 后重跑(它们装好后本脚本会跳过)。"
fi

# ---- 包管理器封装: 尽力装, 失败不致命 ----
pkg_install() {
  if command -v apt-get >/dev/null 2>&1; then
    # Ubuntu/Debian: ffmpeg 在 universe 源, 先确保开启
    if command -v add-apt-repository >/dev/null 2>&1; then
      sudo add-apt-repository universe -y >/dev/null 2>&1 || true
    fi
    sudo apt-get update -y >/dev/null 2>&1
    sudo apt-get install -y "$@" || echo "⚠ apt 安装 $* 失败, 见上方输出"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm "$@" || echo "⚠ pacman 安装 $* 失败"
  elif command -v brew >/dev/null 2>&1; then
    # macOS: 先确保 Xcode Command Line Tools(否则 brew/编译会卡)
    if ! xcode-select -p >/dev/null 2>&1; then
      echo "ⓘ 需要 Xcode Command Line Tools, 正在弹出安装(按提示完成后重跑本脚本)..."
      xcode-select --install || true
    fi
    brew install "$@" || echo "⚠ brew 安装 $* 失败"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$@" || echo "⚠ dnf 安装 $* 失败"
  else
    echo "⚠ 未识别的包管理器, 请手动安装: $*"
  fi
}

# ---- 1. node (Debian 上包名 nodejs, 命令可能叫 nodejs 而非 node, 这里兜底) ----
if command -v node >/dev/null 2>&1; then
  echo "✓ node: $(node -v)"
else
  echo "✗ 缺 node, 尝试安装..."
  pkg_install nodejs
  # 若只有 nodejs 命令, 软链一个 node 到 ~/.local/bin
  if ! command -v node >/dev/null 2>&1 && command -v nodejs >/dev/null 2>&1; then
    mkdir -p "$DEST_DIR"
    ln -sf "$(command -v nodejs)" "$DEST_DIR/node"
    echo "ⓘ 已将 nodejs 链接为 ~/.local/bin/node"
  fi
  if command -v node >/dev/null 2>&1; then
    echo "✓ node: $(node -v)"
  else
    echo "✗ node 仍缺失, 请手动安装后重跑: https://nodejs.org"
  fi
fi

# ---- 2. yt-dlp (下载 standalone 二进制, 自带依赖, 无需 python) ----
if command -v yt-dlp >/dev/null 2>&1 && yt-dlp --version >/dev/null 2>&1; then
  echo "✓ yt-dlp: $(yt-dlp --version 2>/dev/null | head -1)"
else
  echo "✗ 缺 yt-dlp, 下载 standalone 二进制(自带依赖)到 ~/.local/bin ..."
  mkdir -p "$DEST_DIR"
  if command -v curl >/dev/null 2>&1; then
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$DEST_DIR/yt-dlp"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$DEST_DIR/yt-dlp" https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
  else
    echo "✗ 既无 curl 也无 wget, 先试着装 curl..."
    pkg_install curl
    if command -v curl >/dev/null 2>&1; then
      curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$DEST_DIR/yt-dlp"
    else
      echo "✗ 下载失败, 请手动装 yt-dlp: https://github.com/yt-dlp/yt-dlp"
    fi
  fi
  chmod +x "$DEST_DIR/yt-dlp" 2>/dev/null || true
  if [[ -x "$DEST_DIR/yt-dlp" ]]; then
    echo "✓ yt-dlp: $("$DEST_DIR/yt-dlp" --version 2>/dev/null | head -1)"
  else
    echo "✗ yt-dlp 安装失败, 请手动下载放到 ~/.local/bin/yt-dlp"
  fi
fi

# ---- 3. ffmpeg + ffplay ----
if command -v ffmpeg >/dev/null 2>&1 && command -v ffplay >/dev/null 2>&1; then
  echo "✓ ffmpeg/ffplay: $(ffmpeg -version 2>/dev/null | head -1 | cut -d' ' -f3)"
else
  echo "✗ 缺 ffmpeg/ffplay, 尝试安装..."
  pkg_install ffmpeg
  if command -v ffmpeg >/dev/null 2>&1; then
    echo "✓ ffmpeg 已安装"
  else
    echo "✗ ffmpeg 仍缺失, 请手动安装 (Debian/Ubuntu: sudo apt install ffmpeg)"
  fi
fi

# ---- 4. 安装本体 ----
mkdir -p "$DEST_DIR"
install -m 0755 "$SRC_MATRIXMIX" "$DEST"
echo "✓ 已安装本体到 $DEST"

# ---- 5. PATH 自动写入(不再只是提示) ----
add_path() {
  local f="$1"
  [[ -f "$f" ]] || touch "$f"
  if ! grep -q 'local/bin' "$f" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$f"
    echo "ⓘ 已写入 $f"
  fi
}
if [[ ":$PATH:" != *":$DEST_DIR:"* ]]; then
  add_path "$HOME/.bashrc"
  add_path "$HOME/.zshrc"
  add_path "$HOME/.profile"
  export PATH="$DEST_DIR:$PATH"
  echo "ⓘ 已将 ~/.local/bin 加入 PATH; 重开终端立即生效, 或先执行:"
  echo "      export PATH=\"\$HOME/.local/bin:\$PATH\""
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

# MatrixMix — 终端数字雨

一个纯命令行的极客数字雨：真彩色纯绿、ASCII 与全角片假名混排、增量渲染无整屏闪烁、
每列独立速度、拖尾随音乐起伏。配 Node + ffmpeg + yt-dlp 即可边听歌边看雨。

## 安装

把整个 `MatrixMix` 目录拷过去，在目录里跑：

    bash install.sh

安装器会自动检测 `node` / `ffmpeg` / `yt-dlp`，缺哪个补哪个（Debian/Arch/macOS 均可），
最后把本体装到 `~/.local/bin/MatrixMix`。

> 若 `~/.local/bin` 不在 PATH，安装器会提示你加一行到 `.bashrc` / `.zshrc`。

## 使用

    MatrixMix               # 默认 lofi 电台 + 数字雨
    MatrixMix 周杰伦        # 搜歌当背景音
    MatrixMix https://youtu.be/xxxx   # 直接给链接

运行中按键：
- `K` 切换字符集：混合 → ASCII → 片假名（全角）
- `q` / Ctrl+C / Esc 退出

环境变量：
- `MATRIXMIX_AUDIO=0`   只看雨，不抽声音（也顺便不驱动雨速/拖尾随音量变化）
- `MATRIXMIX_FPS=24`    帧率（默认 16）
- `MATRIXMIX_SPEED=2`   整体速度倍率（默认 1）

## 说明

- 颜色用真彩色 `38;2;0;G;0m`（R=0, B=0），物理上不会偏蓝；不需要额外终端字体配置。
- 在 Ptyxis / GNOME Terminal / iTerm2 等支持真彩色的终端里效果最佳。
- 混排时每格固定 2 列宽（片假名天然 2 列，ASCII 补空格），整屏不对齐错位。
- 单文件、无隔离、一条命令直接跑。

## 文件

- `MatrixMix`      本体（单文件 Node 脚本）
- `install.sh`   安装器
- `README.md`    本文件

无外部网络依赖（除了解析音源时需联网访问 YouTube）。
MIT 许可，随便改随便发。

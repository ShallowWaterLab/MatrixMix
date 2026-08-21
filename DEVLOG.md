# MatrixMix 开发日志 / Dev Log

> 维护者与 BossBone 参考：发布状态、架构、关键决策统一记在这里。
> 外部大脑（BOSSBONE_BRAIN.md）只指向本文件，不冗余记录细节。

## 项目来源 / Origin
- 原名 **MatrixMix**（终端数字雨），2026-08-21 正式更名为 **MatrixMix**。
- 更名范围：命令名 / 仓库名 / 本体文件名 / 发布包名 → `MatrixMix`。
- 环境变量前缀 `MATRIXMIX_*` **保留不变**（用户要求，避免破坏个人脚本引用）。
- 旧的 `~/.local/bin/MatrixMix` 运行本体已删除（用户选“干净改名”，不保留别名）。

## 架构 / Architecture
- **主体仓库（开发 + 发布源头）**：Oracle VM `~/sw_lab/sectors/sw_app/MatrixMix/`
- **本地备份**：Hermes bossbone profile `home/MatrixMix/`（仅预览/应急，本机 git 当前缺失）
- **GitHub 发布**：https://github.com/yamwhy-cmyk/MatrixMix （分支 `master`，Public）
- 同步方向：本地 → Oracle 写入/发布；Oracle → 本地仅恢复用。以 Oracle 为准。

## 发布记录 / Releases
- 2026-08-21：首次发布到 GitHub（yamwhy-cmyk/MatrixMix，master 分支），初始提交 `b65a166`。
- 发布方式：git + PAT（token 用完即弃，未持久化；远端已指回干净 origin，无 token 残留）。Oracle 无 gh CLI。

## 关键决策 / Key Decisions
- 安装包 `MatrixMix.tar.gz` **不进版本库**（.gitignore 已忽略），改好功能后再重新打包分发。
- MatrixMix 残留清理：本地 `MatrixMix.tar.gz` 已删；Oracle 上 `magrez_brain.md.bak.MatrixMix_cleanup.*` 属 magrez profile，按硬边界不碰。
- 环境变量 `MATRIXMIX_*` 沿用历史命名，不随更名改动（用户明确指示）。

## 待办 / TODO
- README 顶部补双语长描述（排法 B）。
- 功能改好后把 `MatrixMix/` 重新打包为 `MatrixMix.tar.gz` 供直接分发。
- 可选：补独立 `LICENSE` 文件（README 已声明 MIT，但仓库缺独立 LICENSE 文件）。

# MatrixMix 开发日志 / Dev Log

> 维护者与发布参考：发布状态、架构、关键决策统一记在这里。

## 架构 / Architecture
- **主体仓库（开发 + 发布源头）**：远程开发虚拟机上的 `~/sw_app/MatrixMix/`
- **GitHub 发布**：https://github.com/yamwhy-cmyk/MatrixMix （分支 `master`，Public）
- 同步方向：本地 → 远程写入/发布；远程 → 本地仅恢复用。

## 发布记录 / Releases
- 发布到 GitHub（yamwhy-cmyk/MatrixMix，master 分支），git + PAT（token 用完即弃，未持久化）。

## 关键决策 / Key Decisions
- 安装包 `MatrixMix.tar.gz` **不进版本库**（.gitignore 已忽略），改好功能后再重新打包分发。
- 命令名 / 仓库名 / 本体文件名 / 包名 / 运行本体 / 环境变量前缀 统一为 `MatrixMix` / `MATRIXMIX_*`。

## 待办 / TODO
- 功能改好后把 `MatrixMix/` 重新打包为 `MatrixMix.tar.gz` 供直接分发。
- 可选：补独立 `LICENSE` 文件（README 已声明 MIT，但仓库缺独立 LICENSE 文件）。

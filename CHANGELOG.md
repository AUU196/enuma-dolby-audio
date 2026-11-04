# Changelog

## v1.0

首个可工作版本。

- 以 *MiPad 5 Pro Audio X* 的完整调音配置为基础（42 个文件原样保留）
- 补回 `dlbatmos`：库声明 + 效果声明 + `patch` / `rerouting` / `music` 三个应用点
- 随模块携带 `libdlbatmos.so`（32-bit）与依赖 `libstdcda.so`
- 新增 `post-fs-data.sh`：修正模块文件的 SELinux 标签为 `vendor_file` / `vendor_configs_file`
- 修复前状态：`AudioPolicyEffects: failed to create Fx dlbatmos`，效果链 0 条
- 修复后状态：`1 Effect Chains / implementor: Dolby Laboratories, Inc.`

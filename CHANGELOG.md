# Changelog

## v1.1

音质与音量重新调校，并清理无效文件。

**音量**
- 关闭 Dolby `volume-leveler`（26 处）与 `volmax-boost`（19 处 +3.2 dB）——低档位不再被自动拉满
- 重写 `music` 组扬声器曲线：20% 处由 -38 dB 降到 -50 dB，满格由 0 dB 封顶到 -8 dB

**音质**
- 启用 IEQ（原来扬声器端 `ieq-enable=false`，作者调的曲线没生效）
- 重塑 `ieq_balanced`：234/328 Hz 下调 4.8 dB（去掉浑浊），4.7k–19k 分段提升（恢复层次与空气感），7.1k 克制以避免齿音
- `virtual-bass-overall-gain` +6 dB、二次谐波 -1.6→-0.8 dB（低频更沉更松）
- 虚拟扬声器角度 20°→24°（另一组 10°→14°），`surround-boost` 保持 0（过高会产生"假"声场）

**清理**
- 移除模块自带的 `MusicFX.apk`：系统未注册（缺 privapp 白名单），无效文件
- 手动均衡器改用 ROM 自带的 **AudioFX**（`/system_ext/priv-app/AudioFX`），与模块无关

## v1.0

首个可工作版本。

- 以 *MiPad 5 Pro Audio X* 的完整调音配置为基础（42 个文件原样保留）
- 补回 `dlbatmos`：库声明 + 效果声明 + `patch` / `rerouting` / `music` 三个应用点
- 随模块携带 `libdlbatmos.so`（32-bit）与依赖 `libstdcda.so`
- 新增 `post-fs-data.sh`：修正模块文件的 SELinux 标签为 `vendor_file` / `vendor_configs_file`
- 修复前状态：`AudioPolicyEffects: failed to create Fx dlbatmos`，效果链 0 条
- 修复后状态：`1 Effect Chains / implementor: Dolby Laboratories, Inc.`

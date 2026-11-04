# Dolby + MiPad 5 Pro Audio X for enuma (LineageOS 23.2)

把 **MiPad 5 Pro Audio X 的调音** 和 **ROM 自带的 Dolby（`dlbatmos`）** 合成一个能真正生效的 Magisk 模块，用于小米平板 5 Pro 5G（`enuma`）上的 LineageOS 23.2。

> Merges the MiPad 5 Pro Audio X tuning with the ROM's own Dolby effect (`dlbatmos`) into one working Magisk module for Xiaomi Pad 5 Pro 5G (`enuma`) on LineageOS 23.2.

---

## 为什么需要这个模块

在 enuma 的 LineageOS 23.2 上，音频听起来明显比 HyperOS 干瘪。逐个排查后发现**四个独立的问题叠在一起**，任何单独一个都会让音效失效：

| # | 问题 | 证据 |
|---|---|---|
| 1 | ROM 的 `audio_effects.xml` 声明了 `dlbatmos`，但**系统里根本没有这个库** | `/vendor/lib/soundfx/` 无 `libdlbatmos.so`；`AudioPolicyEffects: failed to create Fx dlbatmos` |
| 2 | MiPad 5 Pro Audio X 模块的 `<postprocess>` 里**没有 Dolby 应用点** | 它的配置只有 ring/alarm/voice_call/notification，没有 `patch`/`rerouting`/`music` |
| 3 | 模块文件被 Magisk 标记为 `system_file`，**audio HAL 无权读取** | `avc: denied { read } ... name="libdlbatmos.so" scontext=hal_audio_default tcontext=system_file` |
| 4 | `libdlbatmos.so` 依赖 `libstdcda.so`，**模块没有携带** | `strings libdlbatmos.so` 的 NEEDED 列表含 `libstdcda.so`；缺它则 `dlopen` 失败 |

四个问题解决后，效果链才出现：

```text
1 Effect Chains
  └─ implementor: Dolby Laboratories, Inc.
```

## 原理

- **调音层**：完整保留 MiPad 5 Pro Audio X 的 42 个配置文件（`audio_policy_configuration.xml`、`audio_configs.xml`、`audio_platform_info.xml`、`dax-default.xml` 等）+ `system.prop`
- **Dolby 层**：把 `dlbatmos` 补进 `audio_effects.xml` 的五个位置（库声明、效果声明、`patch`/`rerouting`/`music` 三个应用点），并随模块携带 `libdlbatmos.so` + `libstdcda.so`
- **SELinux 层**：`post-fs-data.sh` 在挂载后把模块源文件重标为 `vendor_file` / `vendor_configs_file`（挂载点只读，但 `/data` 上的源文件可写，挂载视图会继承标签）

## 安装

1. 已刷 Magisk
2. 从 [Releases](../../releases) 下载 `dolby_miaudio_enuma_v1.0.zip`
3. **Magisk App → 模块 → 从本地安装**
4. 重启

> 不要用 `magisk --install-module` 命令行安装，实测会漏拷贝文件。

## 验证

```bash
# 配置是否被采用
cmp -s /vendor/etc/audio_effects.xml /data/adb/modules/DolbyMi5AudioX/system/vendor/etc/audio_effects.xml && echo merged-config-active

# 库是否加载进 HAL（32 位进程）
pid=$(pidof android.hardware.audio.service)
grep -c dlbatmos /proc/$pid/maps      # > 0 表示已加载

# 效果链（需要正在播放音频）
dumpsys media.audio_flinger | grep -i -e "Effect Chains" -e implementor
# 期望：1 Effect Chains / implementor: Dolby Laboratories, Inc.

# SELinux 无拒绝
dmesg | grep avc | grep -i dlbatmos   # 空
```

## 保留的能力（来自 MiPad 5 Pro Audio X）

| 能力 | 证据位置 |
|---|---|
| 192kHz / 24bit 通路 | `audio_policy_configuration.xml` 含 `192000`；`persist.audio.format.24bit=true`、`hifi_audio.enable=true` |
| raw / 低延迟通路 | 策略含 `RAW`；`aaudio.mmap_policy=2`、`period_multiplier=4` |
| 扬声器曲线重调 | `audio_configs.xml`、`audio_platform_info.xml`、`audio_tuning_mixer.txt` |
| 低音下潜 | Mi5 的 `dolby/dax-default.xml` 生效，最低频段 47Hz |
| 延迟优化 | `vendor.audio.lowpower=false`、`buffering.ms=6`、offload/tunnel 开启 |

## 已知限制

- 调音曲线按 **elish（Pad 5 Pro Wi-Fi）** 的腔体制作。enuma 是同模具 5G 版，物理接近但不完全等同。
- 模块自带 `MusicFX.apk`，但**未被系统注册**（`pm list packages` 中不存在），因此暂无均衡器界面。
- 与 `Dolby Atmos elish`（Atmos）模块**互斥**：两者都覆盖 `audio_effects.xml`，不要同时启用。
- 仅在 `23.2-20260414-UNOFFICIAL-enuma` / Android 16 实测。

## Credits

- **调音配置与 `system.prop`**：来自 **Sc素菜** 的 *MiPad 5 Pro Audio X*，本仓库原样保留，只修复了使其在 LineageOS 上真正生效的链路问题。
- **Dolby 效果实现**：`libdlbatmos.so` / `libstdcda.so` 与 `dlbatmos` 配置来自 *Dolby Atmos elish* 模块（作者：酷安@次奥233333，基于 reiryuki 的 Dolby-Atmos-MagicRevision）及 ROM 自带配置。
- AOSP `audio_effects.xml` 结构，Apache-2.0。

## License

[Apache-2.0](LICENSE)

## 免责声明

修改 `/vendor` 配置有风险，最坏情况为无声或音频服务异常。请确认可用 Magisk 安全模式（开机动画时按住音量下）恢复。**任何时候都不要重新锁定 bootloader。**

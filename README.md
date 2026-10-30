# Mod C

《饥荒联机版》（Don't Starve Together）的服务端 Mod：取消植物对话，并在每次植物生长阶段结算时，按“玩家已经对话过”处理。

## 功能

- 移除农场植物和杂草的“对话 / 交谈”入口，包括鼠标交互和手柄动作键路径。
- 每次植物压力结算时忽略 `happiness`（未对话）这一项，效果等价于玩家在每个阶段结算前都对话过。
- “查看植物状态”不再提示这一项无法执行的对话压力。
- 保留植物图鉴 / 研究、查看植物状态、其它压力项（营养、水分、周围生物、拥挤、季节等）以及正常生长和收获逻辑。
- 旧存档不会回改历史结算数据；Mod 生效后的下一次阶段结算开始使用新规则。

## 兼容性

| 项目 | 值 |
|---|---|
| 游戏 | 饥荒联机版 |
| `api_version` | 10 |
| `dst_compatible` | `true` |
| `dont_starve_compatible` | `false` |
| `reign_of_giants_compatible` | `false` |
| `client_only_mod` | `false` |
| `all_clients_require_mod` | `true` |

由于 Mod 同时包含服务端结算逻辑和客户端手柄动作过滤，所有一起玩的玩家都需要安装并启用同一版本。

## 安装

1. 完全退出《饥荒联机版》。
2. 在游戏安装目录的 `mods` 文件夹中创建 `mod_c` 文件夹。
3. 将以下文件放入 `mods/mod_c/`：
   - `modinfo.lua`
   - `modmain.lua`
   - `preview.png`
4. 重新启动游戏，在 Mods 列表和当前世界设置中都启用 **Mod C**。
5. 进入世界后，确认植物不再显示“对话 / 交谈”选项。

最终目录结构应类似：

```text
Don't Starve Together/
└─ mods/
   └─ mod_c/
      ├─ modinfo.lua
      ├─ modmain.lua
      └─ preview.png
```

## 验证

进入世界后，客户端日志中应出现：

```text
[mod_c] loading | disable plant conversation; settle plants as if talked to every stage
[mod_c] loaded | plant conversation disabled, happiness stress ignored at every checkpoint
```

日志位置（Windows）：

```text
%USERPROFILE%\Documents\Klei\DoNotStarveTogether\client_log.txt
```

## 目录

- `modinfo.lua`：Mod 元数据、兼容性和客户端安装要求。
- `modmain.lua`：植物对话入口移除和植物压力结算逻辑。
- `preview.png`：Mod 预览图。

## 说明

- 该 Mod 不添加世界生成内容、不发起网络请求，也不修改 Klei / Steam 账号授权。
- Mod 安装后如果在创建世界时出现“授权失败”，应先检查 Steam/Klei 在线登录、网络、防火墙或专用服务器令牌，并用禁用 Mod 的新世界做对照测试。

## 状态

- 版本：`1.0.0`
- Workshop：尚未发布

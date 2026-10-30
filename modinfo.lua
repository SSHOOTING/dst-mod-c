name = "Mod C"
description = "取消植物对话：农场植物（含杂草）的“照料/对话”入口不再出现，并且每次生长阶段结算时都把“对话”这一项压力视为已满足，等价于玩家在每个阶段结算前都对话过。植物图鉴/研究、查看植物状态、其它压力项（killjoys/family/overcrowding/season/moisture/nutrients）以及正常生长与收获逻辑保持不变。"

author = "agent_c"
version = "1.0.0"

api_version = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

-- 玩法改动需要服务端权威结算；但“手柄动作键对植物提示对话”这一条只能在客户端
-- 侧拦掉，因此声明客户端也需要本 Mod（客户端接入时会按 DST 常规流程提示/获取）。
client_only_mod = false
all_clients_require_mod = true

server_filter_tags = {}

configuration_options = {}

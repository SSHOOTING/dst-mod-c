--[[
    Mod C  (mod_c)
    取消植物对话；默认按“玩家每次都对话过了”进行属性结算。

    ── 改动范围（只有两件事）────────────────────────────────────────────

    1) 取消“植物对话”入口
       农场植物/杂草通过 farmplanttendable 组件向引擎注册了一个 SCENE 动作收集器
       （scripts/componentactions.lua 的 farmplanttendable），它会在
       tendable_farmplant 标记存在时插入 ACTIONS.INTERACT_WITH，也就是界面上的
       “对话 / Talk To”。该动作列表 actioncomponents 由服务器同步给客户端，
       因此本 Mod 在服务器侧把该动作组件注销掉，所有客户端（含未装本 Mod 的）
       鼠标交互入口都会消失。
       手柄（控制器）的动作键提示走的是另一条路：playercontroller 直接按
       tendable_farmplant 标记取动作，与 actioncomponents 无关。因此本 Mod
       另外包了一层 PlayerController:GetActionButtonAction，把手柄对植物发出的
       INTERACT_WITH 过滤掉。这条改动在客户端执行，所以本 Mod 声明为
       all_clients_require_mod = true（客户端会按 DST 常规流程提示/自动获取）。

       注意：tendable_farmplant 标记本身刻意保留。它还承担 trident /
       gnarwail_horn / singingshell / phonograph / w_radio / panflute /
       wormwood 范围效果以及友好果蝇等机制的植物检索，删标记会误伤这些机制。
       本 Mod 只摘掉“对话入口”，不动标记。

    2) 属性结算等价于“每次都对话过”
       每个生长阶段结算时 MakeStressCheckpoint 会调用
       farmplantstress:MakeCheckpoint()，把当前处于压力状态的分类计入
       stress_points（随后把各分类复位为“有压力”）。其中 happiness 这一项
       在正常玩法里只能靠“对话”清掉。本 Mod 在统计前把 happiness 记为
       “不压力”，于是统计结果与“玩家在每个阶段结算前都对话过”完全一致，
       并且会正确影响 stress_points、生长时间(GetGrowTime)、体型
       (MakeStressCheckpoint 里的 scale) 与巨大化判定(GetFinalStressState)。

       同时让“查看植物状态”(ASSESSPLANTHAPPINESS -> GetStressDescription)
       在描述里忽略 happiness：既然对话入口已经取消、这一项在结算中永不计分，
       继续提示“它需要对话”只会给玩家一个无法执行的死提示。
       其余压力分类（nutrients / moisture / killjoys / family / overcrowding /
       season）与植物图鉴/研究、生长、收获逻辑完全不变。

    ── 边界说明 ────────────────────────────────────────────────────────

    · 旧存档：存档只记录 stressors / stress_points / final_stress_state，
      并不记录“每一阶段各自扣了几分”。已经结算过的历史 stress_points 无法
      安全地按来源回退，因此本 Mod 不回改历史数据，只保证“从本 Mod 生效之后
      的每一次结算”等价于每次都对话过。旧档里正在生长的植物，会在它下一次
      阶段结算时开始按新规则计算。
    · 本 Mod 不改动 farmplanttendable.tendable / tendable_farmplant 标记，
      所以雨棍、海妖角、唱歌贝壳、留声机、W 电台、排箫、沃姆伍德范围技
      等“照料植物”的效果仍与官方一致（在取消对话的前提下它们只是不再有
      实际收益）。友好果蝇会照常把“未被对话过”的植物当作照料目标，
      其行为与官方一致。
]]

print("[mod_c] loading | disable plant conversation; settle plants as if talked to every stage")

local TEND_COMPONENT = "farmplanttendable"   -- 提供“对话”SCENE 动作的组件
local FARM_PLANT_TAG = "farm_plant"          -- 仅农场植物与杂草携带（yotb_stager 等其它 INTERACT_WITH 目标不带）
local HAPPINESS      = "happiness"           -- “需要对话”这一项压力分类

-- 是否是“植物对话”这个目标。只认 farm_plant 标记：
-- 冬季盛典舞台等其它使用 INTERACT_WITH 的目标不带该标记，因此不会被误伤。
local function IsFarmPlant(inst)
    return inst ~= nil and inst:HasTag(FARM_PLANT_TAG)
end

--------------------------------------------------------------------------------
-- 1) 取消“植物对话”入口 —— 鼠标/界面路径
--    注销 farmplanttendable 注册的动作组件，让引擎不再为植物收集
--    ACTIONS.INTERACT_WITH。动作列表是服务器同步的网络数据，因此客户端
--    不需要装本 Mod 也会看到入口消失。
--------------------------------------------------------------------------------
AddPrefabPostInitAny(function(inst)
    if GLOBAL.TheWorld == nil or not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- 只有挂载了 tendable 组件的实体（农场植物、杂草）才需要处理
    if inst.components == nil or inst.components[TEND_COMPONENT] == nil then
        return
    end

    inst:UnregisterComponentActions(TEND_COMPONENT)
end)

--------------------------------------------------------------------------------
-- 1') 取消“植物对话”入口 —— 手柄动作键路径
--     playercontroller 的动作键是直接按 tendable_farmplant 标记取
--     INTERACT_WITH 的，不走 actioncomponents，所以这里再过滤一次。
--     只拦“目标是农场植物/杂草的 INTERACT_WITH”，不影响其它使用
--     INTERACT_WITH 的目标（例如冬季盛典舞台）。
--------------------------------------------------------------------------------
AddComponentPostInit("playercontroller", function(self)
    local _GetActionButtonAction = self.GetActionButtonAction
    if _GetActionButtonAction == nil then
        return
    end

    self.GetActionButtonAction = function(pc, force_target, ...)
        local act = _GetActionButtonAction(pc, force_target, ...)
        if act ~= nil and act.action == GLOBAL.ACTIONS.INTERACT_WITH and IsFarmPlant(act.target) then
            -- 植物对话入口已取消：手柄不再给出这个动作
            return nil
        end
        return act
    end
end)

--------------------------------------------------------------------------------
-- 2) 属性结算等价于“每次都对话过”
--    MakeCheckpoint 统计前把 happiness 记为“不压力”，统计后由原逻辑照常把
--    各分类复位，于是每个阶段的结算都相当于“玩家结算前对话过”。
--------------------------------------------------------------------------------
AddComponentPostInit("farmplantstress", function(self)
    local _MakeCheckpoint = self.MakeCheckpoint
    if _MakeCheckpoint ~= nil then
        self.MakeCheckpoint = function(cmp, ...)
            local stressors = cmp.stressors
            if stressors ~= nil and stressors[HAPPINESS] ~= nil then
                stressors[HAPPINESS] = false -- 视为“已对话”
            end
            return _MakeCheckpoint(cmp, ...)
        end
    end

    -- “查看植物状态”：既然这一项在结算中永不计分，描述里也不再报告它，
    -- 避免给出玩家无法执行的死提示。其余压力分类照常参与描述。
    local _GetStressDescription = self.GetStressDescription
    if _GetStressDescription ~= nil then
        self.GetStressDescription = function(cmp, viewer)
            local stressors = cmp.stressors
            local prev
            local patched = stressors ~= nil and stressors[HAPPINESS] ~= nil
            if patched then
                prev = stressors[HAPPINESS]
                stressors[HAPPINESS] = false
            end

            local desc = _GetStressDescription(cmp, viewer)

            if patched then
                stressors[HAPPINESS] = prev
            end

            return desc
        end
    end
end)

print("[mod_c] loaded | plant conversation disabled, happiness stress ignored at every checkpoint")

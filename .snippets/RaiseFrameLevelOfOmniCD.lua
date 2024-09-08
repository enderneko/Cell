-------------------------------------------------
-- 2024-09-08 16:38:53 GMT+8
-- raise frame level of OmniCD icons
-- 提升 OmniCD 图标的层级
-------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg)
    if arg == "OmniCD" then
        f:UnregisterAllEvents()

        local E = OmniCD[1]
        local P = E.Party

        hooksecurefunc(P, "UpdatePosition", function(self)
            for guid, info in pairs(self.groupInfo) do
                if not E.db.position.detached then
                    local relFrame = self:FindRelativeFrame(guid)
                    if relFrame then
                        info.bar:SetFrameLevel(relFrame:GetFrameLevel()+300)
                    end
                end
            end
        end)
    end
end)
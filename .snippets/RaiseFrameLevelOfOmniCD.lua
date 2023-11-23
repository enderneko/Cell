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
                        info.bar:SetFrameLevel(relFrame:GetFrameLevel()+20)
                    end
                end
            end
        end)
    end
end)
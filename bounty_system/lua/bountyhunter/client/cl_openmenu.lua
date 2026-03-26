surface.CreateFont("JFontTitle_Bounty", {
    font = "CloseCaption_Normal",
    size = 25,
} )

surface.CreateFont("JFontHeader_Bounty", {
    font = "CloseCaption_Normal",
    size = 15,
} )

-- Roboto is goated so im gonna see if I can get it working for all of them

surface.CreateFont("JumpzBounty_Title", {
    font = "Roboto",
    size = 20,
    weight = 800,
    extended = true})

surface.CreateFont("JumpzBounty_Name", {
    font = "Roboto",
    size = 20,
    weight = 600,
    extended = true
})

surface.CreateFont("JumpzBounty_Price", {
    font = "Roboto",
    size = 16,
    weight = 500,
    extended = true
})

surface.CreateFont("JumpzBounty_Watermark", {
    font = "Roboto",
    size = 32,
    weight = 800,
    extended = true
})

surface.CreateFont("JumpzBounty_Empty", {
    font = "Roboto",
    size = 18,
    weight = 500,
    extended = true
})

-- Just cos its nicer to see it say CR after

local function formatCredits(amount)
    local numeric = tonumber(amount) or 0
    numeric = math.floor(numeric)

    if string and string.Comma then
        return string.Comma(numeric)
    end

    local str = tostring(numeric)
    local k
    while true do
        str, k = str:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end

    return str
end

local function Jumpz_IsTeamAllowed(teamName)
    if not Jumpz or not Jumpz.BountyHunter or not Jumpz.BountyHunter.Config then return false end
    local allowed = Jumpz.BountyHunter.Config.AllowedTeams
    if not allowed or type(allowed) ~= "table" then return false end

    if allowed[teamName] then return true end

    if teamName and type(teamName) == "string" then
        local trimmed = teamName:gsub("^%s*(.-)%s*$","%1")
        local lowerName = string.lower(trimmed)
        for k, v in pairs(allowed) do
            if k and string.lower(tostring(k)) == lowerName then
                return true
            end
        end

        -- optional substring fallback for minor differences
        for k, v in pairs(allowed) do
            if k and string.find(lowerName, string.lower(tostring(k)), 1, true) then
                return true
            end
        end
    end

    return false
end

local function Jumpz_NormalizeBountyList(rawList)
    if not istable(rawList) then return {} end

    local numericEntries = {}

    for key, value in pairs(rawList) do
        if istable(value) then
            local numericKey

            if isnumber(key) then
                numericKey = key
            elseif isstring(key) then
                local parsed = tonumber(key)
                if parsed then
                    numericKey = parsed
                end
            end

            if numericKey then
                numericEntries[#numericEntries + 1] = { index = numericKey, data = value }
            end
        end
    end

    table.sort(numericEntries, function(a, b)
        return (a.index or 0) < (b.index or 0)
    end)

    local ordered = {}
    for i = 1, #numericEntries do
        ordered[i] = numericEntries[i].data
    end

    return ordered
end

local popup = {

    Init = function(self) 
        self.Header = self:Add("Panel")
        self.Header:Dock(TOP)
        self.Header:SetHeight(50)

        self.Title = self.Header:Add("DLabel")
        self.Title:SetFont("JFontTitle_Bounty")
        self.Title:SetTextColor(Color(255, 255, 255, 255))
        self.Title:SetSize(500, 150)
        self.Title:SetHeight(50)
        self.Title:SetContentAlignment(5)
        self.Title:DockMargin(0, 0, 0, 0)

        self.Close = self.Header:Add("DButton")
        self.Close:SetSize(25, 25)
        self.Close:Dock(RIGHT)
        self.Close:DockMargin(0, 0, 0, 0)
        self.Close:SetTextColor(Color(255, 255, 255))
        self.Close:SetText("X")
        self.Close.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0))
        end

        self.Options = self:Add("Panel")
        self.Options:Dock(FILL)
        self.Options:DockMargin(40, 20, 40, 20)
        self.Options:SetSize(500, 150)

        self.PlayerLabel = self.Options:Add("DLabel")
        self.PlayerLabel:SetFont("JFontHeader_Bounty")
        self.PlayerLabel:SetTextColor(Color(255, 255, 255, 255))
        self.PlayerLabel:CenterHorizontal( 0.375 )
        self.PlayerLabel:CenterVertical(0.2)
        self.PlayerLabel:SetSize(150, 20)

        self.Players = self.Options:Add("DComboBox")
        self.Players:SetValue("Player")
        self.Players:CenterHorizontal( 0.355 )
        self.Players:CenterVertical(0.35)
        self.Players:SetSize(150, 20)

        self.PriceLabel = self.Options:Add("DLabel")
        self.PriceLabel:SetFont("JFontHeader_Bounty")
        self.PriceLabel:SetTextColor(Color(255, 255, 255, 255))
        self.PriceLabel:CenterHorizontal( 0.375 )
        self.PriceLabel:CenterVertical(0.5)
        self.PriceLabel:SetSize(150, 20)

        self.Price = self.Options:Add("DTextEntry")
        self.Price:CenterHorizontal( 0.355 )
        self.Price:CenterVertical(0.65)
        self.Price:SetSize(150, 20)
        self.Price:SetNumeric(true)
        self.Price:SetUpdateOnType(false)

        self.Submit = self.Options:Add("DButton")
        self.Submit:CenterHorizontal( 0.355 )
        self.Submit:CenterVertical(0.8)
        self.Submit:SetSize(150, 20)
        self.Submit:SetTextColor(Color(255, 255, 255))
        self.Submit:SetText("Create")
        self.Submit.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 227, 74))
        end
        
    end,
    Setup = function(self) 
        self.Title:SetText("Setup New Bounty")
        self.PlayerLabel:SetText("Select Player")
        self.PriceLabel:SetText("Set Reward - Max " .. tostring(Jumpz.BountyHunter.Config.MaxBounty))

        self.Close.DoClick = function() 
            self:Remove()
        end

        local bountyList = Jumpz_NormalizeBountyList(Jumpz_OpenMenu_BountyList or {})

        for _, playerAll in pairs(player.GetAll()) do
            local pteam = team.GetName(playerAll:Team())

            if Jumpz.BountyHunter.Config.ExcludeBounty[pteam] or Jumpz_IsTeamAllowed(pteam) then
                -- continue lol
            else
                local foundBountyPlayer = false
                for _, v in ipairs(bountyList) do
                    if playerAll:SteamID64() == v["Player"] then
                        foundBountyPlayer = true
                        break
                    end
                end

                if not foundBountyPlayer then
                    self.Players:AddChoice(playerAll:Nick())
                end
            end
        end

        self.Submit.DoClick = function()
            local playerBounty = self.Players:GetSelected()
            local price = self.Price:GetInt()
            if(playerBounty == nil or price == nil) then
                LocalPlayer():ChatPrint("[Bounty Hunter] Please fill out valid information to start a bounty!")
                return
            end
            if(price > Jumpz.BountyHunter.Config.MaxBounty) then
                LocalPlayer():ChatPrint("[Bounty Hunter] Bounty value cannot exceed " .. Jumpz.BountyHunter.Config.MaxBounty)
                return
            end
            if(LocalPlayer():getDarkRPVar("money") - price < 0) then
                LocalPlayer():ChatPrint("[Bounty Hunter] You do not have enough money to start this bounty!")
                return
            end
            
            net.Start("Jumpz_SubmitBounty")
            net.WriteString(playerBounty)
            net.WriteInt(price, 32)
            net.WriteEntity(LocalPlayer())
            net.SendToServer()
            self:Remove()
        end
    end,
    PerformLayout = function(self)
        self:SetSize(500, 300)
        self:SetPos((ScrW()/2) - (500/2), (ScrH()/2) - (300/2))
    end,
    Paint = function(self, w, h) 
        draw.RoundedBox(8, 0, 0, w, h, Color(28, 28, 28))
    end,
    --Think = function(self, w, h) 
    --end 
}

popup = vgui.RegisterTable(popup, "EditablePanel")




net.Receive("Jumpz_OpenBountyMenu", function()
    Jumpz_OpenMenu_BountyList = Jumpz_NormalizeBountyList(net.ReadTable())
    Jumpz.BountyHunter.CreateBountyMenu = vgui.CreateFromTable(popup)
    Jumpz.BountyHunter.CreateBountyMenu:Setup()
    Jumpz.BountyHunter.CreateBountyMenu:MakePopup()
    Jumpz.BountyHunter.CreateBountyMenu:SetKeyBoardInputEnabled(true)
end)

local function Jumpz_DrawBountyOutline()
    for _, target in pairs(player.GetAll()) do
        if(target:GetNWBool("Jumpz_BountyTarget")) then
            local bountyTarget = target
            if Jumpz_IsTeamAllowed(team.GetName(LocalPlayer():Team())) then
                halo.Add({bountyTarget}, Color(255, 0, 0), 2, 2, 1, true, true)
            end
        end
    end
end

hook.Add("PreDrawHalos", "DrawBountyOutline", Jumpz_DrawBountyOutline)

local HUD_THEME = {
    maxVisible = 5,
    cardHeight = 86,
    cardSpacing = 10,
    headerHeight = 40,
    padding = 16,
    widthFrac = 0.22,
    widthMin = 280,
    widthMax = 360,
    frameOuter = Color(20, 0, 0, 180),
    frameInner = Color(10, 0, 0, 140),
    frameOutline = Color(255, 0, 0),
    frameOutlineAlpha = 120,
    frameDivider = Color(255, 0, 0, 80),
    titleColor = Color(255, 255, 255, 255),
    titleOutline = Color(120, 0, 0, 220),
    remainingColor = Color(255, 120, 120, 220),
    remainingOutline = Color(80, 0, 0, 200),
    emptyColor = Color(220, 120, 120, 220),
    emptyOutline = Color(0, 0, 0, 200),
    scanlineColor = Color(255, 60, 60, 25),
    overlayColor = Color(255, 0, 0),
    card = {
        footerShadow = Color(0, 0, 0, 90),
        baseLow = Color(10, 0, 0, 120),
        baseHigh = Color(20, 0, 0, 180),
        outline = Color(255, 40, 40, 90),
        accentLeft = Color(255, 0, 0, 110),
        accentRight = Color(255, 0, 0, 60),
        avatarOffset = 12,
        avatarSize = 64,
        avatarGlowColor = Color(255, 50, 50),
        avatarGlowBase = 60,
        avatarGlowWave = 35,
        avatarBackdrop = Color(255, 0, 0, 25),
        nameYOffset = 0.38,
        priceOffset = 24,
        textName = Color(255, 255, 255, 240),
        textPrice = Color(255, 120, 120, 200),
        outlineName = Color(255, 0, 0, 200),
        outlinePrice = Color(120, 0, 0, 180),
        watermark = Color(255, 80, 80, 35),
    }
}

local TERMINAL_THEME = {
    maxVisible = 6,
    cardHeight = 72,
    cardSpacing = 6,
    headerHeight = 30,
    padding = 10,
    widthFrac = 0.2,
    widthMin = 240,
    widthMax = 320,
    frameOuter = Color(70, 0, 0, 210),
    frameInner = Color(40, 0, 0, 180),
    frameOutline = Color(255, 30, 30),
    frameOutlineAlpha = 150,
    frameDivider = Color(255, 60, 60, 120),
    titleColor = Color(255, 230, 230, 255),
    titleOutline = Color(180, 0, 0, 220),
    remainingColor = Color(255, 120, 120, 220),
    remainingOutline = Color(80, 0, 0, 200),
    emptyColor = Color(220, 120, 120, 220),
    emptyOutline = Color(0, 0, 0, 200),
    scanlineColor = Color(255, 60, 60, 25),
    overlayColor = Color(255, 0, 0),
    card = {
        footerShadow = Color(0, 0, 0, 90),
        baseLow = Color(35, 0, 0, 130),
        baseHigh = Color(60, 0, 0, 200),
        outline = Color(255, 70, 70, 110),
        accentLeft = Color(255, 60, 60, 140),
        accentRight = Color(255, 40, 40, 80),
        avatarOffset = 10,
        avatarSize = 52,
        avatarGlowColor = Color(255, 70, 70),
        avatarGlowBase = 70,
        avatarGlowWave = 35,
        avatarBackdrop = Color(255, 0, 0, 35),
        nameYOffset = 0.36,
        priceOffset = 20,
        textName = Color(255, 255, 255, 240),
        textPrice = Color(255, 120, 120, 200),
        outlineName = Color(255, 0, 0, 200),
        outlinePrice = Color(120, 0, 0, 180),
        watermark = Color(255, 80, 80, 35),
    }
}

local BountyList = {

    ApplyTheme = function(self, theme)
        self.Theme = theme or HUD_THEME
        self.MaxVisible = self.Theme.maxVisible
        self.CardHeight = self.Theme.cardHeight
        self.CardSpacing = self.Theme.cardSpacing
        self.HeaderHeight = self.Theme.headerHeight
        self.Padding = self.Theme.padding

        for _, card in pairs(self.Cards or {}) do
            if IsValid(card) then
                card.Theme = self.Theme.card or HUD_THEME.card
                card:InvalidateLayout(true)
            end
        end
    end,

    Init = function(self)
        if isfunction(self.SetPaintBackground) then
            self:SetPaintBackground(false)
        elseif isfunction(self.SetPaintBackgroundEnabled) then
            self:SetPaintBackgroundEnabled(false)
        end
        self:SetMouseInputEnabled(false)
        self:SetKeyboardInputEnabled(false)

        self:ApplyTheme(HUD_THEME)
        self.ScanlineOffset = 0
        self.LastScreenW, self.LastScreenH = 0, 0

        self.Cards = {}
        self.VisibleCards = {}

        self:SetAlpha(255)
    end,

    Setup = function(self)
        self:SetBounties(Jumpz_ClientBountyList or {})
    end,

    SetTerminalTheme = function(self)
        self:ApplyTheme(TERMINAL_THEME)
        for _, card in pairs(self.Cards) do
            if IsValid(card) then
                card.Theme = self.Theme.card
                card:InvalidateLayout(true)
            end
        end
        self:InvalidateLayout(true)
    end,

    CreateCard = function(self, steamID)
        local card = vgui.Create("Panel", self)
        card:SetMouseInputEnabled(false)
        card:SetKeyboardInputEnabled(false)
        card:SetSize(0, self.CardHeight)
        card:SetAlpha(0)
        card:SetVisible(false)

        card.CurrentAlpha = 0
        card.TargetAlpha = 0
        card.SteamID = steamID
        card.Price = 0
        card.PlayerName = "Unknown Target" -- Default before assigned name
        card.GlowOffset = math.Rand(0, math.pi * 2)
        card.NextNameCheck = 0
        card.Theme = self.Theme and self.Theme.card or HUD_THEME.card

        card.Avatar = vgui.Create("AvatarImage", card) -- everyone should have this since we dont allow unverified clients
        card.Avatar:SetMouseInputEnabled(false)
        card.Avatar:SetKeyboardInputEnabled(false)
        card.Avatar:SetVisible(true)

        function card:FadeTo(targetAlpha, removeOnFinish)
            self.TargetAlpha = targetAlpha or 0
            self.RemoveOnFade = removeOnFinish or false
            if (self.TargetAlpha or 0) > 0 then
                self:SetVisible(true)
            end
        end

        function card:ResolvePlayerName()
            local steamID64 = self.SteamID
            if not steamID64 or steamID64 == "" then
                self.PlayerName = self.PlayerName or "Unknown Target"
                return
            end

            local bountyTarget = player.GetBySteamID64(steamID64)
            if IsValid(bountyTarget) then
                self.PlayerName = bountyTarget:Nick()
                return
            end

            if self.HaveRequestedInfo then return end
            self.HaveRequestedInfo = true

            if steamworks then
                steamworks.RequestPlayerInfo(steamID64, function(name)
                    if not IsValid(self) then return end
                    if name and name ~= "" then
                        self.PlayerName = name
                    end
                end)
            end
        end

        function card:SetBountyData(data)
            local newSteamID = tostring(data["Player"] or "")
            if self.SteamID ~= newSteamID then
                self.HaveRequestedInfo = nil
            end

            self.SteamID = newSteamID
            self.Price = tonumber(data["Price"]) or 0
            self.PriceText = "Price: " .. formatCredits(self.Price) .. " CR"
            self.PlayerName = self.PlayerName or "Unknown Target"
            self:ResolvePlayerName()

            if IsValid(self.Avatar) then
                if self.SteamID ~= "" then
                    self.Avatar:SetSteamID(self.SteamID, 64)
                    self.Avatar:SetVisible(true)
                else
                    self.Avatar:SetVisible(false)
                end
            end

            self.Theme = self.Theme or HUD_THEME.card
        end

        function card:PerformLayout(w, h)
            local theme = self.Theme or HUD_THEME.card
            local avatarSize = theme.avatarSize or 64
            if IsValid(self.Avatar) then
                self.Avatar:SetSize(avatarSize, avatarSize)
                self.Avatar:SetPos((theme.avatarOffset or 12), (self:GetTall() - avatarSize) / 2)
            end
        end
        function card:Think()
            self.CurrentAlpha = Lerp(FrameTime() * 6, self.CurrentAlpha or 0, self.TargetAlpha or 0)
            if math.abs((self.TargetAlpha or 0) - (self.CurrentAlpha or 0)) <= 0.5 then
                self.CurrentAlpha = self.TargetAlpha or self.CurrentAlpha
            end

            local alpha = math.Clamp(self.CurrentAlpha or 0, 0, 255)
            self:SetAlpha(alpha)

            if IsValid(self.Avatar) then
                self.Avatar:SetAlpha(alpha)
            end

            if (self.TargetAlpha or 0) <= 0 and alpha <= 1 and self.RemoveOnFade then
                self:Remove()
                return
            end

            if CurTime() >= (self.NextNameCheck or 0) then
                self:ResolvePlayerName()
                self.NextNameCheck = CurTime() + 2
            end
        end

        -- Colours for the overlay
        function card:Paint(w, h)
            local theme = self.Theme or HUD_THEME.card
            local alpha = math.Clamp(self.CurrentAlpha or self:GetAlpha(), 0, 255)
            if alpha <= 0 then return end

            local fade = alpha / 255

            surface.SetDrawColor(theme.footerShadow.r, theme.footerShadow.g, theme.footerShadow.b, math.floor((theme.footerShadow.a or 0) * fade))
            surface.DrawRect(6, h - 6, w - 12, 6)

            draw.RoundedBox(12, 0, 4, w, h - 4, Color(theme.baseLow.r, theme.baseLow.g, theme.baseLow.b, math.floor((theme.baseLow.a or 0) * fade)))
            draw.RoundedBox(12, 0, 0, w, h - 4, Color(theme.baseHigh.r, theme.baseHigh.g, theme.baseHigh.b, math.floor((theme.baseHigh.a or 0) * fade)))

            surface.SetDrawColor(theme.outline.r, theme.outline.g, theme.outline.b, math.floor((theme.outline.a or 0) * fade))
            surface.DrawOutlinedRect(0, 0, w, h - 4, 2)

            surface.SetDrawColor(theme.accentLeft.r, theme.accentLeft.g, theme.accentLeft.b, math.floor((theme.accentLeft.a or 0) * fade))
            surface.DrawRect(0, 0, 3, h - 4)
            surface.SetDrawColor(theme.accentRight.r, theme.accentRight.g, theme.accentRight.b, math.floor((theme.accentRight.a or 0) * fade))
            surface.DrawRect(w - 3, 0, 3, h - 4)

            local avatarSize = theme.avatarSize or 64
            local avatarX, avatarY = theme.avatarOffset or 12, (self:GetTall() - avatarSize) / 2
            local glowStrength = (theme.avatarGlowBase or 60) + (theme.avatarGlowWave or 35) * math.sin(CurTime() * 4 + self.GlowOffset)
            surface.SetDrawColor(theme.avatarGlowColor.r, theme.avatarGlowColor.g, theme.avatarGlowColor.b, math.Clamp(glowStrength * fade, 0, 200))
            surface.DrawOutlinedRect(avatarX - 2, avatarY - 2, avatarSize + 4, avatarSize + 4, 2)

            surface.SetDrawColor(theme.avatarBackdrop.r, theme.avatarBackdrop.g, theme.avatarBackdrop.b, math.floor((theme.avatarBackdrop.a or 0) * fade))
            surface.DrawRect(avatarX - 5, avatarY - 5, avatarSize + 10, avatarSize + 10)

            local textX = avatarX + avatarSize + 12
            local nameY = math.floor(h * (theme.nameYOffset or 0.38))
            local priceY = nameY + (theme.priceOffset or 24)

            local nameColor = Color(theme.textName.r, theme.textName.g, theme.textName.b, math.floor((theme.textName.a or 0) * fade))
            local priceColor = Color(theme.textPrice.r, theme.textPrice.g, theme.textPrice.b, math.floor((theme.textPrice.a or 0) * fade))

            draw.SimpleTextOutlined(self.PlayerName or "Unknown Target", "JumpzBounty_Name", textX, nameY, nameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(theme.outlineName.r, theme.outlineName.g, theme.outlineName.b, math.floor((theme.outlineName.a or 0) * fade)))
            draw.SimpleTextOutlined(self.PriceText or "Price: 0 CR", "JumpzBounty_Price", textX, priceY, priceColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(theme.outlinePrice.r, theme.outlinePrice.g, theme.outlinePrice.b, math.floor((theme.outlinePrice.a or 0) * fade)))

            draw.SimpleText("WANTED", "JumpzBounty_Watermark", w - 18, h - 10, Color(theme.watermark.r, theme.watermark.g, theme.watermark.b, math.floor((theme.watermark.a or 0) * fade)), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end

        return card
    end,

    SetBounties = function(self, bountyList)
        bountyList = Jumpz_NormalizeBountyList(bountyList)

        for _, card in pairs(self.Cards) do
            if IsValid(card) then
                card.PendingRemoval = true
            end
        end

        local visible = {}
        local displayIndex = 0
        local totalCount = #bountyList

        for i = 1, totalCount do
            local data = bountyList[i]
            if data then
                displayIndex = displayIndex + 1
                if displayIndex > self.MaxVisible then break end

                local steamID = tostring(data["Player"] or "")
                local card = self.Cards[steamID]

                if not IsValid(card) then
                    card = self:CreateCard(steamID)
                    self.Cards[steamID] = card
                end

                card.PendingRemoval = nil
                card.Theme = self.Theme and self.Theme.card or HUD_THEME.card
                card:SetBountyData(data)
                card.VisibleIndex = displayIndex
                card:FadeTo(255)
                card:SetVisible(true)
                card:InvalidateLayout(true)

                visible[#visible + 1] = card
            end
        end

        for steamID, card in pairs(self.Cards) do
            if IsValid(card) and card.PendingRemoval then
                card.PendingRemoval = nil
                card.VisibleIndex = nil
                card:FadeTo(0, true)
            end
        end

        self.VisibleCards = visible
        self.RemainingBounties = math.max(totalCount - #visible, 0)
        for steamID, card in pairs(self.Cards) do
            if not IsValid(card) then
                self.Cards[steamID] = nil
            end
        end
        self:InvalidateLayout()
    end,

    PerformLayout = function(self, w, h)
        local screenW, screenH = ScrW(), ScrH()
        local width = math.Clamp(screenW * (self.Theme.widthFrac or 0.22), self.Theme.widthMin or 240, self.Theme.widthMax or 320)
        local cardCount = #self.VisibleCards

        local height = self.Padding * 2 + self.HeaderHeight
        if cardCount > 0 then
            height = height + (self.CardHeight * cardCount) + (self.CardSpacing * (cardCount - 1))
        else
            height = height + 56
        end

        if (self.RemainingBounties or 0) > 0 then -- extend the bar for more targets
            height = height + 20
        end

        self:SetSize(width, height)
        self:SetPos(math.Round(screenW * 0.015), math.Round(screenH * 0.05))

        local x = self.Padding -- we love web development
        local y = self.Padding + self.HeaderHeight
        local availableWidth = width - (self.Padding * 2)

        for _, card in ipairs(self.VisibleCards) do
            if IsValid(card) then
                card:SetSize(availableWidth, self.CardHeight)
                card:SetPos(x, y)
                card:InvalidateLayout()
                y = y + self.CardHeight + self.CardSpacing
            end
        end

        for steamID, card in pairs(self.Cards) do
            if IsValid(card) and not card.VisibleIndex then
                local _, oldY = card:GetPos()
                card:SetSize(availableWidth, self.CardHeight)
                card:SetPos(x, oldY)
            end
        end

        self.LastScreenW, self.LastScreenH = screenW, screenH
    end,

    -- This is the actual settings for the main panel part
    Paint = function(self, w, h)
        local theme = self.Theme or HUD_THEME
        draw.RoundedBox(12, 0, 0, w, h, theme.frameOuter)
        draw.RoundedBox(12, 2, 2, w - 4, h - 4, theme.frameInner)

        local glow = (theme.frameOutlineAlpha or 120) + 40 * math.sin(CurTime() * 2)
        surface.SetDrawColor(theme.frameOutline.r, theme.frameOutline.g, theme.frameOutline.b, math.Clamp(glow, 0, theme.frameOutlineAlpha or 120))
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        local titleY = self.Padding + (self.HeaderHeight / 2)
        draw.SimpleTextOutlined("Open Bounties", "JumpzBounty_Title", self.Padding, titleY, theme.titleColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, theme.titleOutline)

        surface.SetDrawColor(theme.frameDivider.r, theme.frameDivider.g, theme.frameDivider.b, theme.frameDivider.a)
        surface.DrawRect(self.Padding, self.Padding + self.HeaderHeight, w - (self.Padding * 2), 1)

        self.ScanlineOffset = (self.ScanlineOffset + FrameTime() * 60) % (h + 40)
        local scanY = self.ScanlineOffset - 20
        if scanY > -20 and scanY < h then
            surface.SetDrawColor(theme.scanlineColor.r, theme.scanlineColor.g, theme.scanlineColor.b, theme.scanlineColor.a)
            surface.DrawRect(0, scanY, w, 2)
        end

        surface.SetDrawColor(theme.overlayColor.r, theme.overlayColor.g, theme.overlayColor.b, 6 + math.sin(CurTime() * 8) * 4)
        surface.DrawRect(0, 0, w, h)

        if (self.RemainingBounties or 0) > 0 then
            local suffix = self.RemainingBounties > 1 and " targets" or " target"
            local label = "+" .. self.RemainingBounties .. suffix
            draw.SimpleTextOutlined(label, "JumpzBounty_Price", w - self.Padding, h - self.Padding - 6, theme.remainingColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, theme.remainingOutline)
        end

        if #self.VisibleCards == 0 then
            draw.SimpleTextOutlined("No active bounties", "JumpzBounty_Empty", w / 2, self.Padding + self.HeaderHeight + 24, theme.emptyColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, theme.emptyOutline)
        end
    end,

    Think = function(self)
        -- Get rid of the UI if the player isnt in the allowed teams
        if not self.IgnoreTeamRequirement then
            local localPlayer = LocalPlayer()
            if not IsValid(localPlayer) then return end

            local teamName = team.GetName(localPlayer:Team())
            if not Jumpz_IsTeamAllowed(teamName) then
                if IsValid(Jumpz.BountyHunter.ShowBountyList) then
                    Jumpz.BountyHunter.ShowBountyList:Remove()
                    Jumpz.BountyHunter.ShowBountyList = nil
                end

                return
            end
        end
        local screenW, screenH = ScrW(), ScrH()
        if screenW ~= self.LastScreenW or screenH ~= self.LastScreenH then
            self:InvalidateLayout()
        end
    end

}

BountyList = vgui.RegisterTable(BountyList, "EditablePanel")

local function Jumpz_CanShowBountyUI()
    local localPlayer = LocalPlayer()
    if not IsValid(localPlayer) then return false end

    local teamName = team.GetName(localPlayer:Team())
    return Jumpz_IsTeamAllowed(teamName)
end

local function Jumpz_ShowBountyUI()
    if not Jumpz_CanShowBountyUI() then return false end

    local currentList = Jumpz.BountyHunter.ShowBountyList
    if not IsValid(currentList) or not isfunction(currentList.SetBounties) then
        if IsValid(currentList) then
            currentList:Remove()
        end

        Jumpz.BountyHunter.ShowBountyList = vgui.CreateFromTable(BountyList)
        Jumpz.BountyHunter.ShowBountyList:Setup()
        Jumpz.BountyHunter.ShowBountyList:MakePopup()
        Jumpz.BountyHunter.ShowBountyList:SetKeyBoardInputEnabled(false)
        Jumpz.BountyHunter.ShowBountyList:SetMouseInputEnabled(false)
    end

    if IsValid(Jumpz.BountyHunter.ShowBountyList) then
        Jumpz.BountyHunter.ShowBountyList:SetBounties(Jumpz_ClientBountyList or {})

        if timer.Exists("Jumpz_BountyUIRetry") then
            timer.Remove("Jumpz_BountyUIRetry")
        end

        return true
    end

    return false
end

local function Jumpz_ScheduleBountyUIRetry()
    if timer.Exists("Jumpz_BountyUIRetry") then return end

    timer.Create("Jumpz_BountyUIRetry", 0.25, 16, function()
        if Jumpz_ShowBountyUI() then
            timer.Remove("Jumpz_BountyUIRetry")
        end
    end)
end

local function Jumpz_ShowPublicBoard(bountyList)
    if not Jumpz or not Jumpz.BountyHunter then return end

    if IsValid(Jumpz.BountyHunter.PublicBoard) then
        Jumpz.BountyHunter.PublicBoard:Remove()
        Jumpz.BountyHunter.PublicBoard = nil
    end

    local frame = vgui.Create("DFrame")
    frame:SetTitle("Open Bounties")
    frame:SetSize(ScrW() * 0.36, ScrH() * 0.46)
    frame:Center()
    frame:MakePopup()
    frame.lblTitle:SetTextColor(Color(255, 230, 230))
    frame.lblTitle:SetFont("JumpzBounty_Title")
    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(60, 0, 0, 230))
        draw.RoundedBox(12, 2, 24, w - 4, h - 26, Color(35, 0, 0, 210))
        surface.SetDrawColor(255, 40, 40, 140)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        surface.DrawRect(0, 22, w, 2)
    end

    local list = vgui.CreateFromTable(BountyList, frame)
    list:ApplyTheme(TERMINAL_THEME)
    list.IgnoreTeamRequirement = true
    list:SetBounties(bountyList or {})
    list:Dock(FILL)
    list:DockMargin(8, 6, 8, 8)

    Jumpz.BountyHunter.PublicBoard = frame
end

net.Receive("Jumpz_StartBounty", function()
    Jumpz_ClientBountyList = Jumpz_NormalizeBountyList(net.ReadTable() or {})

    -- Try to show the UI immediately; if the team change hasn't propagated yet, retry shortly
    if Jumpz_ShowBountyUI() then
        return
    end

    Jumpz_ScheduleBountyUIRetry()
end)

net.Receive("Jumpz_OpenBountyBoard", function()
    local bountyList = Jumpz_NormalizeBountyList(net.ReadTable() or {})
    Jumpz_ShowPublicBoard(bountyList)
end)

net.Receive("Jumpz_CloseBountyMenu", function()

    if IsValid(Jumpz.BountyHunter.ShowBountyList) then
        Jumpz.BountyHunter.ShowBountyList:Remove()
        Jumpz.BountyHunter.ShowBountyList = nil
    end

    if timer.Exists("Jumpz_BountyUIRetry") then
        timer.Remove("Jumpz_BountyUIRetry")
    end

end)

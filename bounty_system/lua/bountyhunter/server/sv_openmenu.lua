util.AddNetworkString("Jumpz_OpenBountyMenu")
util.AddNetworkString("Jumpz_SubmitBounty")
util.AddNetworkString("Jumpz_StartBounty")
util.AddNetworkString("Jumpz_CloseBountyMenu")
util.AddNetworkString("Jumpz_OpenBountyBoard")

local function Jumpz_OpenMenu(ply, text)
    if(string.lower(text) == Jumpz.BountyHunter.Config.Command) then
        if(CAMI.PlayerHasAccess(ply, "[Bounty] Create", nil)) then
            net.Start("Jumpz_OpenBountyMenu")
            net.WriteTable(Jumpz.BountyHunter.Config.OpenBounties)
            net.Send(ply)
        else
            ply:ChatPrint("[Bounty Hunter] Sorry, you are not able to create a bounty")
        end
        return ""
    end

end

hook.Add("PlayerSay", "BountyHunterOpenMenu", Jumpz_OpenMenu)




net.Receive("Jumpz_SubmitBounty", function(_, ply)

    if not IsValid(ply) or not ply:IsPlayer() then return end

    local playerBountyName = net.ReadString()
    local price = net.ReadInt(32)

    net.ReadEntity()

    if price <= 0 then
        ply:ChatPrint("[Bounty Hunter] Please submit a bounty greater than 0 credits.")
        return
    end

    if price > Jumpz.BountyHunter.Config.MaxBounty then
        ply:ChatPrint("[Bounty Hunter] Bounty value cannot exceed " .. Jumpz.BountyHunter.Config.MaxBounty .. " credits.")
        return
    end

    local targetPlayer
    for _, v in pairs(player.GetAll()) do
        if v:Nick() == playerBountyName then
            targetPlayer = v
            break
        end
    end

    if not IsValid(targetPlayer) then
        ply:ChatPrint("[Bounty Hunter] Invalid bounty target.")
        return
    end

    if targetPlayer == ply then
        ply:ChatPrint("[Bounty Hunter] You cannot place a bounty on yourself.")
        return
    end

    local targetTeam = team.GetName(targetPlayer:Team())
    if Jumpz.BountyHunter.Config.ExcludeBounty[targetTeam] or Jumpz.BountyHunter.Config.AllowedTeams[targetTeam] then
        ply:ChatPrint("[Bounty Hunter] You cannot place a bounty on that player.")
        return
    end

    for _, bounty in pairs(Jumpz.BountyHunter.Config.OpenBounties or {}) do
        if bounty and bounty["Player"] == targetPlayer:SteamID64() then
            ply:ChatPrint("[Bounty Hunter] That player already has an active bounty.")
            return
        end
    end

    if not ply:getDarkRPVar("money") or (ply:getDarkRPVar("money") - price < 0) then
        ply:ChatPrint("[Bounty Hunter] You do not have enough credits to create this bounty.")
        return
    end

    local playerBounty = targetPlayer:SteamID64()

    table.insert(Jumpz.BountyHunter.Config.OpenBounties, {
        ["Player"] = playerBounty,
        ["Price"] = price,
        ["Creator"] = ply
    })

    for _, v in pairs(player.GetAll()) do
        if Jumpz.BountyHunter.Config.AllowedTeams[team.GetName(v:Team())] then
            net.Start("Jumpz_StartBounty")
            net.WriteTable(Jumpz.BountyHunter.Config.OpenBounties)
            net.Send(v)
        end
        if v:SteamID64() == playerBounty then
            v:SetNWBool("Jumpz_BountyTarget", true)
        end
    end

    ply:addMoney(-price)
end)

local function Jumpz_PlayerDisconnectCheck(ply)
    if(#Jumpz.BountyHunter.Config.OpenBounties > 0) then
        for k, v in pairs(Jumpz.BountyHunter.Config.OpenBounties) do
            if(ply:SteamID64() == v["Player"]) then
                v["Creator"]:setDarkRPVar("money", v["Creator"]:getDarkRPVar("money") + v["Price"])
                table.remove(Jumpz.BountyHunter.Config.OpenBounties, k)
                for _, target in pairs(player.GetAll()) do 
                    if(Jumpz.BountyHunter.Config.AllowedTeams[team.GetName(target:Team())]) then
                        DarkRP.talkToPerson(target, Color(230, 226, 5), "[Bounty Disconnect] " .. ply:Nick(), Color(0, 255, 255), "has disconnected, their bounty has been voided!")
                        if(#Jumpz.BountyHunter.Config.OpenBounties > 0) then
                            net.Start("Jumpz_StartBounty")
                                net.WriteTable(Jumpz.BountyHunter.Config.OpenBounties)
                            net.Send(target)
                        else
                            net.Start("Jumpz_CloseBountyMenu")
                            net.Send(target)
                        end
                    end
                end
            end
        end
    end
end

hook.Add("PlayerDisconnected", "Jumpz_PlayerDisconnectCheck", Jumpz_PlayerDisconnectCheck)


local function Jumpz_PlayerBountyKill(deadPlayer, weapon, attacker)
    if not (attacker:IsPlayer()) then return end
    if(Jumpz.BountyHunter.Config.AllowedTeams[team.GetName(attacker:Team())]) then
        for k, v in pairs(Jumpz.BountyHunter.Config.OpenBounties) do
            if(deadPlayer:SteamID64() == v["Player"]) then
                attacker:addMoney(v["Price"])
                for _, target in pairs(player.GetAll()) do
                    DarkRP.talkToPerson(target, Color(230, 226, 5), "[Bounty Reward] " .. attacker:Nick(), Color(0, 255, 255), "has claimed a bounty worth " .. tostring(v.Price) .. " by killing " .. deadPlayer:Nick())
                end
                table.remove(Jumpz.BountyHunter.Config.OpenBounties, k)
                deadPlayer:SetNWBool("Jumpz_BountyTarget", false)
                if(#Jumpz.BountyHunter.Config.OpenBounties == 0) then
                    for k, v in pairs(player.GetAll()) do
                        if Jumpz.BountyHunter.Config.AllowedTeams[team.GetName(v:Team())] then
                            net.Start("Jumpz_CloseBountyMenu")
                            net.Send(v)
                        end
                    end
                else
                    net.Start("Jumpz_StartBounty")
                    net.WriteTable(Jumpz.BountyHunter.Config.OpenBounties)
                    net.Send(attacker)
                end
            end
        end
    end
end
hook.Add("PlayerDeath", "Jumpz_PlayerBountyKill", Jumpz_PlayerBountyKill)

local function Jumpz_ChangeTeam(ply, oldTeam, newTeam)
    local oldName = team.GetName(oldTeam)
    local newName = team.GetName(newTeam)

    -- swapping off bounty hunter job
    if Jumpz.BountyHunter.Config.AllowedTeams[oldName] and not Jumpz.BountyHunter.Config.AllowedTeams[newName] then
        net.Start("Jumpz_CloseBountyMenu")
        net.Send(ply)
        ply:SetNWBool("Jumpz_BountyTarget", false)
        return
    end

    -- swapping onto bounty hunter job, enable gui
    if Jumpz.BountyHunter.Config.AllowedTeams[newName] then
        net.Start("Jumpz_StartBounty")
        net.WriteTable(Jumpz.BountyHunter.Config.OpenBounties or {})
        net.Send(ply)
        return
    end

    -- if swapped off, set flag to false
    if Jumpz.BountyHunter.Config.ExcludeBounty[newName] then
        ply:SetNWBool("Jumpz_BountyTarget", false)
    end
end

hook.Add("PlayerChangedTeam", "Jumpz_ChangeTeam", Jumpz_ChangeTeam)

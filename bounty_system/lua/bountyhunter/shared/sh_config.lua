Jumpz.BountyHunter = Jumpz.BountyHunter or {}
Jumpz.BountyHunter.Config = Jumpz.BountyHunter.Config or {}

timer.Simple(2, function()
    if CAMI then
        CAMI.RegisterPrivilege{
            Name = "[Bounty] Create",
            Description = "Allows access to the bounty command"
        }
    end
end)

Jumpz.BountyHunter.Config.AllowedTeams = { -- Teams able to see bounties
    ["Hired Bounty Hunter"] = true,
    ["Elite Headhunter"] = true,
    ["Cad Bane"] = true,
    ["Hondo Ohnaka"] = true,
    ["Bossk"] = true,
    ["Durge"] = true,
    ["Asajj Ventress"] = true,
    ["Young Boba Fett"] = true
}

Jumpz.BountyHunter.Config.ExcludeBounty = { -- Teams bounties cannot be placed on, this also includes any AllowedTeams
    ["Cadet"] = true,
    ["Jedi Youngling"] = true,
    ["Staff on Duty"] = true,
    ["Developer"] = true,
    ["Pre Viszla"] = true,
    ["Savage Opress"] = true,
    ["General Grievous"] = true,
    ["Darth Maul"] = true,
    ["Count Dooku"] = true,
    ["Event Character"] = true,
    ["Umbaran Trooper"] = true,
    ["Umbaran Heavy Trooper"] = true,
    ["Umbaran Sniper"] = true,
    ["Umbaran Engineer"] = true,
    ["Umbaran Officer"] = true,
    ["BX Commander Droid"] = true,
    ["BX Heavy Droid"] = true,
    ["BX Recon Droid"] = true,
    ["BX Splicer Droid"] = true,
    ["BX Slugthrower Droid"] = true,
    ["BX Assassin Droid"] = true,
    ["BX Commando Droid"] = true,
    ["Technical Droid"] = true,
    ["Sniper Droid"] = true,
    ["Tanker Droid"] = true,
    ["Tactical Droid"] = true,
    ["Magna Guard"] = true,
    ["Droideka"] = true,
    ["Super Jump Droid"] = true,
    ["Super Battle Droid"] = true,
    ["Sith"] = true,
    ["Commander Droid"] = true,
    ["Medical Droid"] = true,
    ["Engineer Droid"] = true,
    ["Recon Battle Droid"] = true,
    ["Heavy Battle Droid"] = true,
    ["Rocket Droid"] = true,
    ["CQ Battle Droid"] = true,
    ["Battle Droid"] = true,
    ["Elite Rifleman"] = true,
    ["Elite CQC Operative"] = true,
    ["Elite Rocket Launcher Operator"] = true,
    ["Elite Heavy Assault Trooper"] = true,
    ["Elite Sniper"] = true,
    ["Elite Engineer"] = true,
    ["Elite Medical Unit"] = true,
    ["Elite Commander"] = true,
    ["Sith Assassin"] = true,
    ["Elite Tanker"] = true,
    ["Elite Heavy Ordinance Unit"] = true,
    ["Elite Fire Support Operator"] = true,
    ["Elite Splicer Enforcer"] = true,
    ["Hired Bounty Hunter"] = true,
    ["Fallen Mandalorian"] = true,
    ["Self Detonation Operative"] = true,
    ["Elite Scorcher"] = true,
    ["Sith Apprentice"] = true,
    ["Elite Infiltrator"] = true,
    ["Elite Headhunter"] = true,
    ["Super Tactical Droid"] = true,
    ["Sith Lord"] = true,
    ["Umbaran Soldier"] = true

}

Jumpz.BountyHunter.Config.Command = "!bounty" -- Command to open bounty menu
Jumpz.BountyHunter.Config.MaxBounty = 50000 -- Max credits that can be set for bounty reward

Jumpz.BountyHunter.Config.OpenBounties = {}
--[[ Table Structure:

[1] = {
    ["Player"] = "SteamID",
    ["Price"] = 50000,
    ["Creator"] = Player (Used to return money if bounty cancelled)
} 
]]

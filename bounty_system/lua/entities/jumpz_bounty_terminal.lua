AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Bounty Terminal"
ENT.Author = "Jumpz"
ENT.Category = "[MVG] Miscellaneous Entities"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/ace/sw/rh/cgi_console_03.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    self._NextUse = self._NextUse or 0
    if self._NextUse > CurTime() then return end
    self._NextUse = CurTime() + 1.5

    net.Start("Jumpz_OpenBountyMenu")
    net.WriteTable(Jumpz.BountyHunter.Config.OpenBounties or {})
    net.Send(activator)
end

function ENT:Draw()
    if SERVER then return end
    self:DrawModel()
    
    local ang = self:LocalToWorldAngles(Angle(0,90, 90))

    cam.Start3D2D(self:LocalToWorld(Vector(0,0,self:OBBMaxs().z)) + Vector(0,0,9), ang, 0.075)
        draw.SimpleText("Bounty Terminal", "NCS_DATAPAD_OVERHEAD", 0, 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
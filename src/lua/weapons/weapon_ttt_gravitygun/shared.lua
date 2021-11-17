-- Credit goes to MKA0207 for the original addon: https://steamcommunity.com/profiles/76561197996267438
-- Currently maintained by 06000208: https://steamcommunity.com/profiles/76561198077168160
-- Workshop Addon: https://steamcommunity.com/sharedfiles/filedetails/?id=1414206909
-- Repository: https://github.com/06000208/ttt-gravity-gun
-- Version: 1.4

-- Files & initialization

AddCSLuaFile()

DEFINE_BASECLASS( "weapon_tttbase" ) -- https://wiki.facepunch.com/gmod/Global.DEFINE_BASECLASS

if SERVER then
    resource.AddFile("materials/vgui/ttt/icon_06000208_gravity_gun.vmt")
end

-- REVIEW: Why on earth is this precached?
util.PrecacheModel("models/props_c17/canisterchunk01b.mdl")

-- SWEP Basics
SWEP.Base = "weapon_tttbase"
SWEP.PrintName = "Gravity Gun"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Author = "06000208 and MKA0207"
SWEP.Contact = "https://github.com/06000208/ttt-gravity-gun/issues"

-- SWEP Weapon Variables
SWEP.Kind = WEAPON_EQUIP2
SWEP.Slot = 7
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Weight = 5 -- Controls the autoswitch weight (default = 5)
SWEP.DrawAmmo = true
SWEP.DeploySpeed = 1.4 -- Default
-- Refillable ammo (SWEP.AmmoEnt) is not used
SWEP.Primary.Ammo = "xbowbolt"
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Secondary.Ammo = "xbowbolt"
SWEP.Secondary.ClipSize = 10
SWEP.Secondary.DefaultClip = 10
SWEP.Secondary.Automatic = false

-- SWEP Model
SWEP.HoldType = "physgun"
SWEP.UseHands = true
SWEP.ViewModelFOV = 57
SWEP.ViewModel = "models/weapons/c_physcannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"

-- TTT Shop Variables
SWEP.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}
SWEP.LimitedStock = true
SWEP.EquipMenuData = {
    type = "item_weapon",
    desc = "A tractor beam-type weapon, originally\ndesigned for handling hazardous materials...\n\nAllows to you move and punt large props"
};
SWEP.Icon = "vgui/ttt/icon_06000208_gravity_gun"

-- Custom variables
SWEP.PuntForce = 90000
SWEP.PullForce = 2000
SWEP.MaxMass = 700
SWEP.MaxPuntRange = 1055
SWEP.MaxPickupRange = 855
SWEP.Distance = 60
local HoldSound = Sound("Weapon_MegaPhysCannon.HoldSound")

-- This method overrides weapon_tttbase's Initialize()
-- https://wiki.facepunch.com/gmod/WEAPON:Initialize
function SWEP:Initialize()
    -- Intentionally doesn't call BaseClass.Initialize(Self)
    if SERVER then
        self:SetSkin(0) -- Orange Gravity Gun
    end
    self:SetHoldType(self.HoldType)
    self:SetDeploySpeed(self.DeploySpeed)
end

-- https://wiki.facepunch.com/gmod/WEAPON:OwnerChanged
function SWEP:OwnerChanged()
    self:SetSkin(0)
    self:TPrem()
    if self.HP then
        self.HP = nil
    end
end

-- This method overrides weapontttbase's Think()
-- https://wiki.facepunch.com/gmod/WEAPON:Think
function SWEP:Think()
    BaseClass.Think(Self)
    local trace = self:GetOwner():GetEyeTrace()
    local tgt = trace.Entity

    --[[
    if math.random(  6,  98 ) == 16 and !self.TP and !self:GetOwner():KeyDown(IN_ATTACK2) and !self:GetOwner():KeyDown(IN_ATTACK) then
    --    self:ZapEffect()
    end
    ]]

    if self:GetOwner():KeyPressed(IN_ATTACK2) then
        -- self:GlowEffect()
        self:RemoveCore()
    elseif self:GetOwner():KeyReleased(IN_ATTACK2) and !self.TP then
        self:RemoveGlow()
        -- self:CoreEffect()
    end

    if !self:GetOwner():KeyDown(IN_ATTACK) then
        self:SetNextPrimaryFire( CurTime() - 0.55 );
    end

    if self:GetOwner():KeyPressed(IN_ATTACK2) then
        if self.HP then return end

        if !tgt or !tgt:IsValid() then
            self:EmitSound("Weapon_PhysCannon.TooHeavy")
            return
        end

        if (SERVER) then
            if tgt:GetMoveType() == MOVETYPE_VPHYSICS then
                local Mass = tgt:GetPhysicsObject():GetMass()
                if Mass >= (self.MaxMass + 1) then
                    self:EmitSound("Weapon_PhysCannon.TooHeavy")
                    return
                end
            else
                self:EmitSound("Weapon_PhysCannon.TooHeavy")
                return
            end
        end
    end

    if self.TP then
        if self.HP and self.HP != NULL then
            if (SERVER) then
                HPrad = self.HP:BoundingRadius()
                self.TP:SetPos(self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * (self.Distance + HPrad))
                self.TP:PointAtEntity(self:GetOwner())

                self.HP:GetPhysicsObject():Wake()
            end
        else
            self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
            self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

            self.Secondary.Automatic = true
            self:SetNextSecondaryFire( CurTime() + 0.5 );
            self:EmitSound("Weapon_MegaPhysCannon.Drop")

            timer.Simple( 0.4, function()
                self:SendWeaponAnim(ACT_VM_IDLE)
            end )

            -- self:CoreEffect()
            -- self:RemoveGlow()

            if self.TP then
                self.TP:Remove()
                self.TP = nil
            end

            if self.HP then
                self.HP = nil
            end

            self:StopSound(HoldSound)
        end

        if CurTime() >= PropLockTime and (self.HP:GetPos() - (self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * (self.Distance + HPrad))):Length() >= 80 then
            self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
            self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
            self:Drop()
        end
    end
end

-- REVIEW: Unused function
function SWEP:ZapEffect()
    if SERVER then
        --[[
        if math.random() == 1 then
        --    self.Zap =  ents.Create("PhyscannonZap1")
            else
            --self.Zap =  ents.Create("PhyscannonZap2")
            -- else
            -- self.Zap =  ents.Create("PhyscannonZap3")
        end
        --]]
        self.Zap:SetPos( self:GetOwner():GetShootPos() )
        self.Zap:Spawn()
        self.Zap:SetParent(self:GetOwner())
        self.Zap:SetOwner(self:GetOwner())
    end
end

function SWEP:NotAllowedClass()
    local trace = self:GetOwner():GetEyeTrace()
    local class = trace.Entity:GetClass()
    if class == "npc_strider"
        or class == "npc_helicopter"
        or class == "npc_combinedropship"
        or class == "npc_barnacle"
        or class == "npc_antliongrub"
        or class == "npc_strider"
        or class == "npc_turret_ceiling"
        or class == "npc_combine_camera"
        or class == "npc_combinegunship"
        or class == "npc_helicopter"
        or class == "prop_vehicle_apc"
        or class == "prop_vehicle_cannon"
        or class == "prop_vehicle_crane"
        or class == "weapon_ttt_unarmed"
        or class == "weapon_zm_carry"
        or class == "weapon_zm_improvised" then
    return true
    else
    return false
    end
end

function SWEP:AllowedClass()
    local trace = self:GetOwner():GetEyeTrace()
    local class = trace.Entity:GetClass()
    -- if trace.Entity:GetMoveType() == MOVETYPE_VPHYSICS then
    if class == "npc_manhack"
        or class == "npc_turret_floor"
        or class == "npc_turret_ground"
        or class == "npc_sscanner"
        or class == "npc_cscanner"
        or class == "npc_clawscanner"
        or class == "npc_rollermine"
        or class == "npc_grenade_frag"
        --hl2 ammos & extras
        or class == "item_ammo_357"
        or class == "item_ammo_ar2_altfire"
        or class == "item_ammo_crossbow"
        or class == "item_ammo_pistol"
        or class == "item_ammo_smg1"
        or class == "item_ammo_smg1_grenade"
        or class == "item_battery"
        or class == "item_box_buckshot"
        or class == "item_healthvial"
        or class == "item_healthkit"
        or class == "item_rpg_round"
        or class == "item_ammo_ar2"
        --ttt weapons and equipment
        or class == "weapon_ttt_beacon"
        or class == "weapon_ttt_binoculars"
        or class == "weapon_ttt_c4"
        or class == "weapon_ttt_confgrenade"
        or class == "weapon_ttt_cse"
        or class == "weapon_ttt_decoy"
        or class == "weapon_ttt_defuser"
        or class == "weapon_ttt_flaregun"
        or class == "weapon_ttt_glock"
        or class == "weapon_ttt_health_station"
        or class == "weapon_ttt_knife"
        or class == "weapon_ttt_m16"
        or class == "weapon_ttt_phammer"
        or class == "weapon_ttt_push"
        or class == "weapon_ttt_radio"
        or class == "weapon_ttt_sipistol"
        or class == "weapon_ttt_smokegrenade"
        or class == "weapon_ttt_stungun"
        or class == "weapon_ttt_teleport"
        or class == "weapon_ttt_wtester"
        or class == "weapon_tttbasegrenade"
        or class == "weapon_zm_mac10"
        or class == "weapon_zm_molotov"
        or class == "weapon_zm_pistol"
        or class == "weapon_zm_revolver"
        or class == "weapon_zm_rifle"
        or class == "weapon_zm_shotgun"
        or class == "weapon_zm_sledge"
        --ttt ammo
        or class == "item_ammo_357_ttt"
        or class == "item_ammo_pistol_ttt"
        or class == "item_ammo_revolver_ttt"
        or class == "item_ammo_smg1_ttt"
        or class == "item_box_buckshot_ttt"
        --ttt entities/projectiles
        or class == "ttt_basegrenade_proj"
        or class == "ttt_smokegrenade_proj"
        or class == "ttt_knife_proj"
        or class == "ttt_confgrenade_proj"
        or class == "ttt_radio"
        or class == "ttt_hat_deerstalker"
        or class == "ttt_health_station"
        --[[or class == "weapon_357"
        or class == "weapon_annabelle"
        or class == "weapon_alyxgun"
        or class == "weapon_ar2"
        or class == "weapon_bugbait"
        or class == "weapon_crossbow"
        or class == "weapon_crowbar"
        or class == "weapon_physcannon"
        or class == "weapon_frag"
        or class == "weapon_physgun"
        or class == "weapon_pistol"
        or class == "weapon_rpg"
        or class == "weapon_shotgun"
        or class == "weapon_slam"
        or class == "weapon_smg1"
        or class == "weapon_stunstick"]]
        or class == "weapon_striderbuster"
        or class == "combine_mine"
        --[[or class == "gmod_tool"
        or class == "gmod_camera"]]
        -- misc
        or class == "helicopter_chunk"
        or class == "grenade_helicopter"
        or class == "prop_combine_ball"
        or class == "prop_wheel"
        --fun
        or class == "npc_alyx"
        or class == "npc_barney"
        or class == "npc_breen"
        or class == "npc_citizen"
        or class == "npc_dog"
        or class == "npc_eli"
        or class == "npc_gman"
        or class == "npc_monk"
        or class == "npc_mossman"
        or class == "npc_kleiner"
        or class == "npc_crow"
        or class == "npc_pigeon"
        or class == "npc_seagull"
        or class == "npc_metropolice"
        or class == "npc_zombie"
        or class == "npc_fastzombie"
        or class == "npc_poisonzombie"
        or class == "npc_headcrab"
        or class == "npc_headcrab_black"
        or class == "npc_headcrab_fast"
        or class == "npc_stalker"
        or class == "npc_vortigaunt"
        or class == "npc_ichthyosaur"
        -- vehicles
        or class == "prop_vehicle"
        or class == "prop_vehicle_airboat"
        or class == "prop_vehicle_driveable"
        or class == "prop_vehicle_jeep"
        or class == "prop_vehicle_prisoner_pod"
        -- funcs
        or class == "func_physbox"
        or class == "func_physbox_multiplayer"
        or class == "func_breakable"
        -- ragdolls
        or class == "prop_ragdoll"
        or class == "physics_prop_ragdoll"
        -- physics
        or class == "prop_physics_override"
        or class == "prop_physics_respawnable"
        or class == "prop_physics_multiplayer"
        or class == "prop_physics" then
        return true
    else
        return false
    end
end

--[[function SWEP:OpenClaws()
    self:EmitSound("Weapon_MegaPhysCannon.Charge")
    local Open = self:LookupSequence("ProngsOpen")
    self:SetSequence(Open)
end]]

function SWEP:PrimaryAttack()

if !self:CanPrimaryAttack() then return end
    self:GetOwner():SetAnimation( ACT_VM_SECONDARYATTACK )
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self:SetNextPrimaryFire( CurTime() + 0.55 );
    self:SetNextSecondaryFire( CurTime() + 0.3 );
    self:GetOwner():ViewPunch( Angle( 0, 6, 0 ) ) --makes the screen shake
    self:GetOwner():SetAnimation( PLAYER_ATTACK1 ) --makes our player have thirdperson anims
    self:TakePrimaryAmmo(1)

    --[[
    timer.Simple( 0.4, function()
        self:SendWeaponAnim(ACT_VM_IDLE)
    end )
    --]]

    if self.TP then
        self:DropAndShoot()
        return
    end

    local trace = self:GetOwner():GetEyeTrace()
    local tgt = trace.Entity

    if !tgt or !tgt:IsValid() or (self:GetOwner():GetShootPos() - tgt:GetPos()):Length() > self.MaxPuntRange or self:NotAllowedClass() then
        self:EmitSound("Weapon_MegaPhysCannon.DryFire")
        return
    end

    if tgt:IsNPC() and !self:AllowedClass() and !self:NotAllowedClass() or tgt:IsPlayer() then
        if (SERVER) then
            if (tgt:IsPlayer() and RunConsoleCommand( "sbox_playershurtplayers" ) == 1) then
                self:EmitSound("Weapon_MegaPhysCannon.DryFire")
                return
            end
            local ragdoll = ents.Create( "prop_ragdoll" )
            ragdoll:SetPos( tgt:GetPos())
            ragdoll:SetAngles(tgt:GetAngles() - Angle(tgt:GetAngles().p,0,0))
            ragdoll:SetModel( tgt:GetModel() )
            ragdoll:SetSkin( tgt:GetSkin() )
            ragdoll:SetMaterial( tgt:GetMaterial() )

            --[[
            if server_settings.Int( "ai_keepragdolls" ) == 0 then
                ragdoll.Entity:Fire("FadeAndRemove","",0.3)
            else
                ragdoll.Entity:Fire("FadeAndRemove","",120)
                end
            --]]

            if !entity then return end

            cleanup.Add (self:GetOwner(), "props", ragdoll);
            undo.Create ("ragdoll");
            undo.AddEntity (ragdoll);
            undo.SetPlayer (self:GetOwner());
            undo.Finish();

            if tgt:IsPlayer() then
                tgt:KillSilent()
                tgt:AddDeaths(1)
                tgt:SpectateEntity(ragdoll)
                tgt:Spectate(OBS_MODE_CHASE)
            elseif tgt:IsNPC() then
                tgt:Fire("Kill","",0)
            end

            self:GetOwner():AddFrags(1)

            ragdoll:Spawn()
            ragdoll:Fire("StartRagdollBoogie","",0)
            ragdoll:Fire("SetBodygroup","15",0)

            RagdollVisual(ragdoll, 1)

            for i = 1, ragdoll:GetPhysicsObjectCount() do
                local bone = ragdoll:GetPhysicsObjectNum(i)

                if bone and bone.IsValid and bone:IsValid() then
                    local bonepos, boneang = tgt:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))

                    timer.Simple( 0.01, function()
                        bone:SetPos(bonepos)
                        bone:SetAngle(boneang)
                        bone:AddVelocity(self:GetOwner():GetAimVector() * self.PuntForce / 8)
                    end )
                end
            end
        end
        self:Visual()
    end

    if self:AllowedClass() or tgt:GetClass() == "prop_vehicle_airboat" or tgt:GetClass() == "prop_vehicle_jeep" and tgt:GetPhysicsObject():IsMoveable() then
        self:Visual()
        if (SERVER) then
            local position = trace.HitPos
            tgt:GetPhysicsObject():ApplyForceCenter(self:GetOwner():GetAimVector() * self.PuntForce)
            tgt:GetPhysicsObject():ApplyForceOffset(self:GetOwner():GetAimVector() * self.PuntForce, position )
            tgt:SetPhysicsAttacker(self:GetOwner())
            tgt:Fire("physdamagescale","99999",0)
        end
    end
end

function SWEP:DropAndShoot()
    self.HP:Fire("EnablePhyscannonPickup","",1)
    self.HP:SetCollisionGroup(COLLISION_GROUP_NONE)
    self.HP:SetPhysicsAttacker(self:GetOwner())

    self.Secondary.Automatic = true
    self:SetNextSecondaryFire( CurTime() + 0.5 );
    self:SetNextPrimaryFire( CurTime() + 0.55 );

    -- self:CoreEffect()
    self:RemoveGlow()
    -- self:Visual()
    self:TPrem()

    self:StopSound(HoldSound)

    if self.HP:GetClass() == "prop_ragdoll" then
        self.HP:Fire("StartRagdollBoogie","",0)
        RagdollVisual(self.HP, 1)

        for i = 1, self.HP:GetPhysicsObjectCount() do
            local bone = self.HP:GetPhysicsObjectNum(i)

            if bone and bone.IsValid and bone:IsValid() then
                timer.Simple( 0.02, function()
                    bone:AddVelocity(self:GetOwner():GetAimVector() * self.PuntForce / 8)
                end )
            end
        end
    else
        local trace = self:GetOwner():GetEyeTrace()
        local position = trace.HitPos

        timer.Simple( 0.02, function()
            self.HP:GetPhysicsObject():ApplyForceCenter(self:GetOwner():GetAimVector() * self.PuntForce)
            self.HP:GetPhysicsObject():ApplyForceOffset(self:GetOwner():GetAimVector() * self.PuntForce,position )
        end )

        self.HP:Fire("physdamagescale","9999",0)
    end

    timer.Simple( 0.04, function()
        self.HP = nil
    end )
end

function SWEP:SecondaryAttack()
    if !self:CanPrimaryAttack() then return end

    if self.TP then
        self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
        self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
        self:TakePrimaryAmmo(1)
        self:Drop()
        return
    end

    local trace = self:GetOwner():GetEyeTrace()
    local tgt = trace.Entity

    if !tgt or !tgt:IsValid() then
        return
    end

    if (CLIENT) then return end

    --[[
    if !self:NotAllowedClass() and !self:AllowedClass() then
    end
    --]]

    if tgt:GetMoveType() == MOVETYPE_VPHYSICS and SERVER then
        local Mass = tgt:GetPhysicsObject():GetMass()
        local Dist = (tgt:GetPos() - self:GetOwner():GetPos()):Length()
        local vel = self.PullForce / (Dist * 0.002)

        if Mass >= (self.MaxMass + 1) then
            return
        end

        if tgt:GetClass() == "prop_ragdoll" or self:AllowedClass() and tgt:GetPhysicsObject():IsMoveable() and ( !constraint.HasConstraints( tgt ) ) then
            if Dist < self.MaxPickupRange then
                self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
                self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
                self.HP = tgt

                self:Pickup()
                self:SetNextSecondaryFire( CurTime() + 0.2 );
                self:SetNextPrimaryFire( CurTime() + 0.1 );
                self.Secondary.Automatic = false
            else
                tgt:GetPhysicsObject():ApplyForceCenter(self:GetOwner():GetAimVector() * -vel )
            end
        end
    end
end

function SWEP:Pickup()
    self:EmitSound("Weapon_MegaPhysCannon.Pickup")

    PropLockTime = CurTime() + 1

    timer.Simple( 0.4, function()
        self:SendWeaponAnim(ACT_VM_RELOAD)
    end )

    local trace = self:GetOwner():GetEyeTrace()

    self.HP:Fire("DisablePhyscannonPickup","",0)

    self.TP = ents.Create("prop_physics")
    -- self.TP:SetPos(self.HP:GetPhysicsObject():GetMassCenter())
    self.TP:SetPos(self.HP:GetPhysicsObject():GetPos())
    self.TP:SetModel("models/props_junk/PopCan01a.mdl")
    self.TP:SetMaterial("Models/effects/vol_light001") --We do this so the can supporting the body is invisible
    self.TP:Spawn()
    self.TP:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self.TP:SetColor(Color(0,0,0,0))
    self.TP:PointAtEntity(self:GetOwner())
    self.TP:GetPhysicsObject():SetMass(50000)
    self.TP:GetPhysicsObject():EnableMotion(false)

    local bone = math.Clamp(trace.PhysicsBone,0,1)
    self.Const = constraint.Weld(self.TP, self.HP, 0, bone,0,1)

    self.HP:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    self:EmitSound(HoldSound)
end

function SWEP:Drop()
    self.HP:Fire("EnablePhyscannonPickup","",1)
    self.HP:SetCollisionGroup(COLLISION_GROUP_NONE)

    if self.HP:GetClass() == "prop_ragdoll" then
        RagdollVisual(self.HP, 1)
        self.HP:Fire("StartRagdollBoogie","",0)
    end

    self.Secondary.Automatic = true
    self:EmitSound("Weapon_MegaPhysCannon.Drop")
    self:SetNextSecondaryFire( CurTime() + 0.5 );

    timer.Simple( 0.4,
    function()
        self:SendWeaponAnim(ACT_VM_IDLE)
    end )

    -- self:CoreEffect()
    -- self:RemoveGlow()

    self:TPrem()
    if self.HP then
        self.HP = nil
    end

    self:StopSound(HoldSound)
    self:EmitSound( "Weapon_MegaPhysCannon.Launch" )
end

function SWEP:Visual()
    self:EmitSound( "Weapon_MegaPhysCannon.Launch" )
    self:GetOwner():ViewPunch( Angle( -5, 0, 0 ) )

    local trace = self:GetOwner():GetEyeTrace()

    local effectdata = EffectData()
    effectdata:SetOrigin( trace.HitPos )
    effectdata:SetStart( self:GetOwner():GetShootPos() )
    effectdata:SetAttachment( 1 )
    effectdata:SetEntity( self )
    util.Effect( "ToolTracer", effectdata )

    local e = EffectData()
    e:SetMagnitude(30)
    e:SetScale(30)
    e:SetRadius(30)
    e:SetOrigin(trace.HitPos)
    e:SetNormal(trace.HitNormal)
    -- util.Effect("PhyscannonImpact", e)
    util.Effect("ManhackSparks", e)
    util.Effect( "ToolTracer", e )
end

function RagdollVisual(ent, val)
        if ent:IsValid() then
        if !entity then return end

        val = val + 1

        local effect = EffectData()
        effect:SetEntity(ent)
        effect:SetMagnitude(30)
        effect:SetScale(30)
        effect:SetRadius(30)
        util.Effect("TeslaHitBoxes", effect)
        util.Effect( "ToolTracer", effect )

        -- ent:EmitSound("Weapon_StunStick.Activate")

        if val <= 26 then
            timer.Simple(math.random(8,20) / 100, RagdollVisual, ent, val)
        end
    end
end

function SWEP:Deploy()
    -- self:SendWeaponAnim( ACT_VM_DRAW ) --DRAW animation
    self:EmitSound("items/battery_pickup.wav")
    self:SetSkin(0)
    -- self:CoreEffect()
end

function SWEP:Holster()
    if self.TP then
        return false
    else
        self:RemoveFX()
        self:TPrem()
        if self.HP then
            self.HP = nil
        end
        return true
    end
end

function SWEP:OnDrop()
    self:RemoveFX()
    self:TPrem()
    if self.HP then
        self.HP = nil
    end
end

function SWEP:TPrem()
    if self.TP then
        self.TP:Remove()
        self.TP = nil
    end

    if self.Const then
        self.Const:Remove()
        self.Const = nil
    end
end

function SWEP:RemoveFX()
    if self.Core then
        self.Core:Remove()
        self.Core = nil
    end

    if self.Glow then
        self.Glow:Remove()
        self.Glow = nil
    end
end

-- REVIEW: This function uses a non-existent entity
-- REVIEW: Unused function, leftover part of unfinished code
function SWEP:CoreEffect()
    if SERVER then
        if !self.Core then
            self.Core = ents.Create("PhyscannonCore")
            self.Core:SetPos( self:GetOwner():GetShootPos() )
            self.Core:Spawn()
        end
        self.Core:SetParent(self:GetOwner())
        self.Core:SetOwner(self:GetOwner())
    end
end

-- REVIEW: This function uses a non-existent entity
-- REVIEW: Unused function, leftover part of unfinished code
function SWEP:GlowEffect()
    if SERVER then
        if !self.Glow then
            self.Glow = ents.Create("PhyscannonGlow")
            self.Glow:SetPos( self:GetOwner():GetShootPos() )
            self.Glow:Spawn()
        end
        self.Glow:SetParent(self:GetOwner())
        self.Glow:SetOwner(self:GetOwner())
    end
end

-- REVIEW: Part of unfinished code
function SWEP:RemoveCore()
    if CLIENT then return end
    if !self.Core then return end
    self.Core:Remove()
    self.Core = nil
end

-- REVIEW: Part of unfinished code
function SWEP:RemoveGlow()
    if CLIENT then return end
    if !self.Glow then return end
    self.Glow:Remove()
    self.Glow = nil
end




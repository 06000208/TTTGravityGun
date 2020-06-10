A gravity gun for the terrortown gamemode.
This is an edit of [url=https://steamcommunity.com/id/mka0207]mka0207[/url]'s [url=https://steamcommunity.com/sharedfiles/filedetails/?id=224881520]ttt gravity gun[/url] addon that i made for a server.
[h1]Full credit to them for the vast majority of the code.[/h1]

[u]The changes between mine and their version are listed below[/u], [b]although this list may be incomplete.[/b]

fixed: incorrectly being an automatic weapon/being able to spam/hold down attack
fixed: and the subsequent "no ammo" sound spam if you're out and try to use it of the above
fixed: incorrect skin between viewmodel and worldmodel, both are now the normal orange gravity gun
fixed: incorrect HoldType (changed from ar2 to physgun)
fixed: SWEP.WeaponID which shouldn't have been in there
fixed: several entities such as prop_physics_respawnable not working
added: many ttt specific entities are now able to be picked up
changed: punt force (lowered)
changed: max mass of grab able objects (raised)
changed: slot (takes up slot 8 now)
changed: weapon kind to WEAPON_EQUIP2
changed: description
changed: shop icon
changed: canbuy (both role_traitor and role_detective)
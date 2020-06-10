### `v1.3` Jun 10 @ 1:18am 

- Rewrote workshop addon description and gave it a real icon
- Setup the github repository
- Cleaned up the addon (reorganized the groups of swep declarations, commented out unused code, fixed spacing, etc)
- Improved shop icon
- Changed shop icon format from png to vtf
- Rewrote some of the past change notes to be more clear

### `v1.2` Jun 18, 2018 @ 9:35am 

- Included more entities in the allow and disallow lists, primarily ttt specific entities

### `v1.1` Jun 17, 2018 @ 10:28pm 

- Changed icon name

### `v1.0`

Initial version! Differences from the older workshop addon are as follows:

- Fixed being able to spam/hold down attack as well as the the subsequent "no ammo" sound spam if you're out (No longer considered an automatic weapon)
- Fixed mismatched skins between viewmodel and worldmodel, both are now the orange gravity gun as expected
- Changed HoldType from ar2 to physgun
- Removed SWEP.WeaponID which shouldn't have been in there
- Added several entities such as prop_physics_respawnable as well as some ttt specific ones to the allowed props list
- Lowered punt force
- Raised the maximum mass of props/entities allowing more to be picked up
- Changed slot to `8` and weapon kind to `WEAPON_EQUIP2`
- Changed shop description and icon
- Changed canbuy, detectives and traitors can both enjoy it now


## 1.4 (Unreleased)

- Better changelog syntax on github + Starting to use github releases
- Source code now using [code anchors](https://marketplace.visualstudio.com/items?itemName=ExodiusStudios.comment-anchors), most notably the review anchor
- Project is now utilizing [github projects](https://github.com/06000208/ttt-gravity-gun/projects)
- Reorganized code to make more sense and with comments rather than arbitrary spacing
- Exposed some SWEP variables to the server that were previously only exposed on the client as good practice
- Updated deprecated code (self:SetWeaponHoldType, SWEP.AdminSpawnable, self.Owner, self.Weapon)
- Removed code for a nonexistent entity, fixes wrong parameter used with SetColor ([PR #12](https://github.com/06000208/ttt-gravity-gun/pull/12))
- Fixed deploy speed (closes [#9](https://github.com/06000208/ttt-gravity-gun/issues/9))
- Added DEFINE_BASECLASS preprocessor
<!-- - Removed a bunch of code for nonexistent entities and unused effects -->

## [1.3](https://github.com/06000208/ttt-gravity-gun/releases/tag/1.3) (Jun 10, 2020)

- Rewrote workshop addon description and gave it a real icon
- Setup the github repository
- Cleaned up the addon (reorganized the groups of swep declarations, commented out unused code, fixed spacing, etc)
- Improved shop icon
- Changed shop icon format from png to vtf
- Rewrote some of the past change notes to be more clear
- No longer purchasable more than once

## 1.2 (Jun 18, 2018)

- Included more entities in the allow and disallow lists, primarily ttt specific entities

## 1.1 (Jun 17, 2018)

- Changed icon name

## 1.0 (Jun 17, 2018)

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

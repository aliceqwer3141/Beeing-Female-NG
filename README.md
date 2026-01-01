# Beeing Female NG

SKSE plugin built with CommonLibSSE-NG and xmake.

## Requirements

- Visual Studio 2022 (MSVC v143)
- xmake 2.9.5+
- CommonLibSSE-NG checked out at `lib/commonlibsse-ng`

## Setup


To add the submodule in a fresh clone:

```sh
git submodule add https://github.com/CharmedBaryon/CommonLibSSE-NG.git lib/commonlibsse-ng
git submodule update --init --recursive
```

## Build

Debug:

```sh
xmake f -m debug
xmake
```

Release:

```sh
xmake f -m release
xmake
```

## Output

The plugin and PDB (debug only) are copied to:

```
dist/Core/skse/plugins
```

## Changes

- Migrated from legacy SKSE/CommonLibSSE to CommonLibSSE-NG.
- Switched build system to xmake (no VS solution required).
- Updated plugin entry point to `SKSEPluginLoad` with NG logging/serialization.
- Papyrus native registration updated to NG signatures; scripts unchanged.
- Added a player damage cap in `dist/Core/source/scripts/FWSystem.psc` so difficulties below 4 cannot reduce health below 1 HP.
- Removed FNIS/OAR gating so animation playback is no longer forced off when FNIS is missing.
- Labor pains duration can be tuned via `Global_Duration_09_LaborPains` in `dist/Core/BeeingFemale/AddOn/Global Settings.ini`.
- Integrated fixes from BeeingFemaleSE Opt by aliceqwer3141 and Beeing Female SE 2.8.1 Patch V14d by Bane Master and Garkin.
- Modified the SexLab add-on and added an OStim add-on.
- Bathing in Skyrim addon targets Bathing in Skyrim Renewed instead of the original mod.

## Notes

- `xmake-requires.lock` is tracked to keep dependency versions stable.
- Papyrus sources live in `dist/Core/Source/Scripts`.

## Integrations

- OStim: optional integration via `dist/Core/source/scripts/BFA_Ostim.psc` that listens for OStim orgasm events and applies sperm/impregnation logic when a male and female pair have vaginal sex (supports OStim API 23+ with NG thread events when available).
- SexLab: optional integration via `dist/Core/source/scripts/BFA_ssl.psc` and `dist/Core/source/scripts/BFA_AbilityEffectPMSSexHurt.psc` that hooks orgasm and stage events to apply sperm/impregnation logic and PMS sex-hurt effects; also uses the SexLab AnimatingFaction and optionally Devious Devices keywords when present. Recognises hentairim tags now and is more precise

## Papyrus ModEvents

Beeing Female NG listens for a few mod events you can emit from your own Papyrus scripts.

- `BeeingFemale` (SendModEvent): command-style event; sender must be an Actor (typically the female).
  - `AddContraception` (numArg = %): add contraception to the actor.
  - `AddSperm` (numArg = donor FormID): add sperm from the donor to the actor.
  - `WashOutSperm` (numArg = %): wash out a percentage of stored sperm. Strength applied to the chances in the ini file
  - `ChangeState` (numArg = 0..8): force a cycle state by index (e.g. 3 = menstruation).
  - `InfoBox` (numArg = sort mode): open the info window for the actor.
  - `DamageBaby` / `HealBaby` (numArg = amount): apply damage/heal to the unborn baby.
  - `CanBecomePregnant` / `CanBecomePMS` (numArg = 1 or 0): toggle eligibility flags for the actor.
  - `TestScale` (numArg = scale): run a scaling test on the actor.
  - `CheckAbortus` (numArg unused): force an abortus check.
  - `Update` (numArg unused): refresh actor data/state.
  - `Belly` / `Birth` (numArg unused): refresh belly state (birth triggers the same update path).
  - `Dispel` (numArg unused): dispel the BF effect on the actor.
  - `ConceptionChance` (numArg = 1 player, 2 follower, 3 npc): update auto-impregnation flags by target group.
- `AddActorSperm` and `AddSperm` (ModEvent): push two Actor forms (woman first, donor second).

Examples:

```papyrus
; BeeingFemale command event (SendModEvent is a Form method)
FemaleActor.SendModEvent("BeeingFemale", "AddContraception", 100)
FemaleActor.SendModEvent("BeeingFemale", "AddSperm", MaleActor.GetFormID())
FemaleActor.SendModEvent("BeeingFemale", "WashOutSperm", 100)
FemaleActor.SendModEvent("BeeingFemale", "ChangeState", 3)
FemaleActor.SendModEvent("BeeingFemale", "InfoBox", 100)
FemaleActor.SendModEvent("BeeingFemale", "DamageBaby", 30)
FemaleActor.SendModEvent("BeeingFemale", "HealBaby", 60)
FemaleActor.SendModEvent("BeeingFemale", "CanBecomePregnant", 1)
FemaleActor.SendModEvent("BeeingFemale", "CanBecomePMS", 1)
FemaleActor.SendModEvent("BeeingFemale", "TestScale", 1.0)
FemaleActor.SendModEvent("BeeingFemale", "CheckAbortus")
FemaleActor.SendModEvent("BeeingFemale", "Update")
FemaleActor.SendModEvent("BeeingFemale", "Belly")
FemaleActor.SendModEvent("BeeingFemale", "Birth")
FemaleActor.SendModEvent("BeeingFemale", "Dispel")
FemaleActor.SendModEvent("BeeingFemale", "ConceptionChance", 2)
```

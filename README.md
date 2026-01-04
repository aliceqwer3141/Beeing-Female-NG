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
- Bathing in Skyrim Renewed addon added.
  Changelog:
	https://github.com/crajjjj/Beeing-Female-NG/releases

## Notes

- `xmake-requires.lock` is tracked to keep dependency versions stable.
- Papyrus sources live in `dist/Core/Source/Scripts`.
- SSEEDIT_locations is just for reference. Don't compile or import

## For Modders

## Add-on Framework

Beeing Female NG ships an INI-driven add-on framework that lets external mods extend or override pregnancy/cycle behavior without editing core scripts. Add-ons are discovered from `dist/Core/BeeingFemale/AddOn/*.ini` and loaded at runtime.

### Add-on Types

- `misc`: scripted hooks (camera, birth effects, integrations like SexLab/OStim, Bathing in Skyrim).
- `race`: per-race tuning (durations, scales, pregnancy chance, protected/PC dialogue, custom baby actors/items).
- `actor`: per-actor overrides (same knobs as race, but scoped to a single actor).
- `cme`: cycle magic effect lists for each stage (Always/Sometimes).

### Capabilities

- Global/default tunables for cycle timings, pregnancy chance, belly/breast scaling, pain, multiple births, and baby spawn pacing.
- Per-race or per-actor overrides (pregnancy scales, duration multipliers, protected child flags, etc.).
- Custom baby actor/item/armor selection for parent race/actor (with fallback behavior).
- Integration hooks via misc add-ons (SexLab/OStim/Bathing in Skyrim).
- Add-on event hooks: `OnGiveBirthStart/End`, `OnLaborPain`, `OnBabySpawn`, `OnMagicEffectApply`, camera start/stop.

### Default Behaviors

- Uses global defaults from `Global Settings.ini` (or internal defaults if not set).
- If no custom baby actor is found, falls back to the parent actor base.
- Pregnancy visuals are driven by trimester scales plus `BellyMaxScale` and respect the selected visual scaling mode.
- Add-on lists refresh on game load when the AddOn directory hash changes or cached data is invalid.

## Integrations

- OStim: optional integration via `dist/Core/source/scripts/BFA_Ostim.psc` that listens for OStim orgasm events and applies sperm/impregnation logic when a male and female pair have vaginal sex (supports OStim API 23+ with NG thread events when available).
- SexLab: optional integration via `dist/Core/source/scripts/BFA_ssl.psc` and `dist/Core/source/scripts/BFA_AbilityEffectPMSSexHurt.psc` that hooks orgasm and stage events to apply sperm/impregnation logic and PMS sex-hurt effects; also uses the SexLab AnimatingFaction and optionally Devious Devices keywords when present. Recognises hentairim tags now and is more precise


### Reading State and Sperm Info

Use StorageUtil to read the current state and inspect stored sperm data.

```papyrus
; Current state (0..8)
int s = StorageUtil.GetIntValue(PlayerRef, "FW.CurrentState", 0)

; Check if there is significant sperm stored
int sa = StorageUtil.FormListCount(PlayerRef, "FW.SpermName")
bool isCumInside = false
while sa > 0
	sa -= 1
	float amo = StorageUtil.FloatListGet(PlayerRef, "FW.SpermAmount", sa)
	if amo > 0.3
		isCumInside = true
	endif
endwhile
```

### Papyrus ModEvents

Beeing Female NG listens for a few mod events you can emit from your own Papyrus scripts.

- `BeeingFemale` (SendModEvent): command-style event; sender must be an Actor (typically the female).
  - `AddContraception` (numArg = %): add contraception to the sender; values > 0 only.
  - `AddSperm` (numArg = donor FormID): add sperm from the donor to the sender; donor must resolve to an Actor.
  - `WashOutSperm` (numArg = %): wash out a percentage of stored sperm on the sender; strength scales the configured washout chances (higher % increases the effective washout chance for that call).
  - `ChangeState` (numArg = 0..8): force a cycle state by index; only valid for female actors.
    - `0` Follicular, `1` Ovulating, `2` Luteal, `3` Menstruating
    - `4` 1st Trimester, `5` 2nd Trimester, `6` 3rd Trimester
    - `7` Labor pains, `8` Replenish from birth
    - Note: UI-only states `20` (Pregnant) and `21` (Pregnant by chaurus) are not valid targets here.
  - `InfoBox` (numArg = sort mode): open the info window for the sender; 100 is the default sort mode.
  - `DamageBaby` / `HealBaby` (numArg = amount): apply damage/heal to the unborn baby of the sender.
  - `CanBecomePregnant` / `CanBecomePMS` (numArg = 1 or 0): toggle eligibility flags for the sender (1 = allow, 0 = disallow).
  - `TestScale` (numArg = scale): run a scaling test on the sender (debug).
  - `CheckAbortus` (numArg unused): run the abortus state machine on the sender; it may start/advance/resolve abortus based on unborn health, trimester timing, and randomness.
  - `Update` (numArg unused): refresh cached data/state for the sender.
  - `Belly` / `Birth` (numArg unused): refresh belly visuals for the sender.
  - `Dispel` (numArg unused): dispel the BeeingFemale effect on the sender.
  - `ConceptionChance` (numArg = 1 player, 2 follower, 3 npc): update auto-impregnation flags for the sender based on target group.
- `AddActorSperm` and `AddSperm` (ModEvent): push two Actor forms (woman first, donor second). Both must be valid actors; adds sperm without using a command string.

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

Abortus trigger example (requires a pregnant actor and abortus enabled in config):

```papyrus
; Reduce unborn health, then force a check
FemaleActor.SendModEvent("BeeingFemale", "DamageBaby", 999)
FemaleActor.SendModEvent("BeeingFemale", "CheckAbortus")
```

### Custom Race Add-ons

Use a race add-on INI to customize pregnancy/cycle behavior per custom race.

1) Copy `dist/Core/BeeingFemale/AddOn/CustomRace AddOn Example.ini` and rename it.
2) In `[AddOn]`:
   - Set `name`, `description`, `author`, and `type=race`.
   - Set `required=YourRacePlugin.esp` (optional but recommended. Races for ActorTypeNPC should have "child" as part of the name).
   - Set `enabled=true` if you want it active by default (or enable it in MCM later).
3) Set `races=N`, then add `[Race1]...[RaceN]` sections.
4) In each `[RaceN]`, set `id=PluginName:FormID` (hex FormID without `0x`; commas allowed).
5) Edit the per-race settings you need (durations, pain scales, pregnancy chance, etc.).
6) (Optional) If you need custom baby actors/items, follow `dist/Core/BeeingFemale/AddOn/ChildActor AddOn Example.ini`.

After saving the INI, enable the add-on in the BeeingFemale MCM if it is not enabled by default.

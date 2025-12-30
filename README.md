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

## Notes

- `xmake-requires.lock` is tracked to keep dependency versions stable.
- Papyrus sources live in `dist/Core/Source/Scripts`.

## Integrations

- OStim: optional integration via `dist/Core/source/scripts/BFA_Ostim.psc` that listens for OStim orgasm events and applies sperm/impregnation logic when a male and female pair have vaginal sex (supports OStim API 23+ with NG thread events when available).
- SexLab: optional integration via `dist/Core/source/scripts/BFA_ssl.psc` and `dist/Core/source/scripts/BFA_AbilityEffectPMSSexHurt.psc` that hooks orgasm and stage events to apply sperm/impregnation logic and PMS sex-hurt effects; also uses the SexLab AnimatingFaction and optionally Devious Devices keywords when present. Recognises hentairim tags now and is more precise

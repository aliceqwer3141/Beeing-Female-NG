#pragma once

#include <RE/Skyrim.h>
#include <SKSE/SKSE.h>
#include <SKSE/API.h>
#include <SKSE/Interfaces.h>

#include <algorithm>
#include <cstdint>

using SInt32 = std::int32_t;
using UInt32 = std::uint32_t;
using UInt16 = std::uint16_t;
using UInt8 = std::uint8_t;

using BSFixedString = RE::BSFixedString;
using TESForm = RE::TESForm;
using TESQuest = RE::TESQuest;
using TESObjectWEAP = RE::TESObjectWEAP;
using TESObjectREFR = RE::TESObjectREFR;
using TESRace = RE::TESRace;
using Actor = RE::Actor;
using SpellItem = RE::SpellItem;
using ActiveEffect = RE::ActiveEffect;
using BGSHeadPart = RE::BGSHeadPart;
using BGSKeyword = RE::BGSKeyword;
using BGSKeywordForm = RE::BGSKeywordForm;
using DataHandler = RE::TESDataHandler;
using ModInfo = RE::TESFile;
using StaticFunctionTag = RE::StaticFunctionTag;
using VMClassRegistry = RE::BSScript::IVirtualMachine;

#define DEFINE_MEMBER_FN(a_name, a_ret, a_addr, ...) a_ret a_name(__VA_ARGS__);

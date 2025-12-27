#include "skse64/PapyrusGame.h"
#include "skse64/PapyrusColorForm.h"
#include "skse64/GameRTTI.h"
#include "skse64/GameAPI.h"
#include "skse64/GameReferences.h"
#include "skse64/GameData.h"
#include "skse64/GameSettings.h"
#include "skse64/GameForms.h"
#include "skse64/GameCamera.h"
#include "skse64/GameMenus.h"
#include "skse64/GameThreads.h"
#include "skse64/GameExtraData.h"
#include "skse64/PapyrusKeyword.h"
#include "skse64/GameForms.h"
#include "skse64/GameObjects.h"
#include "skse64/GameData.h"
#include "common/ICriticalSection.h"
#include "skse64/PapyrusNativeFunctions.h"
#include "iniH.h"

namespace FWChildEnchant {

	BSFixedString GetModFile(StaticFunctionTag* base, BSFixedString enchFile) {
		std::string f = "Data/BeeingFemale/Enchantment/";
		f.append(enchFile.data);
		return iniH::getIniString(f, "modName");
	}

	UInt32 GetFormID(StaticFunctionTag* base, BSFixedString enchFile) {
		std::string f = "Data/BeeingFemale/Enchantment/";
		f.append(enchFile.data);
		return iniH::getIniUInt32(f, "form");
	}

	UInt32 GetPowerMin(StaticFunctionTag* base, BSFixedString enchFile) {
		std::string f = "Data/BeeingFemale/Enchantment/";
		f.append(enchFile.data);
		return iniH::getIniUInt32(f, "power_min");
	}

	UInt32 GetPowerMax(StaticFunctionTag* base, BSFixedString enchFile) {
		std::string f = "Data/BeeingFemale/Enchantment/";
		f.append(enchFile.data);
		return iniH::getIniUInt32(f, "power_max");
	}

	bool RegisterFuncs(VMClassRegistry* registry) {
		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("GetModFile", "FWChildEnchant", FWChildEnchant::GetModFile, registry));
		registry->SetFunctionFlags("FWChildEnchant", "GetModFile", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, UInt32, BSFixedString>("GetFormID", "FWChildEnchant", FWChildEnchant::GetFormID, registry));
		registry->SetFunctionFlags("FWChildEnchant", "GetFormID", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, UInt32, BSFixedString>("GetPowerMin", "FWChildEnchant", FWChildEnchant::GetPowerMin, registry));
		registry->SetFunctionFlags("FWChildEnchant", "GetPowerMin", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, UInt32, BSFixedString>("GetPowerMax", "FWChildEnchant", FWChildEnchant::GetPowerMax, registry));
		registry->SetFunctionFlags("FWChildEnchant", "GetPowerMax", VMClassRegistry::kFunctionFlag_NoWait);
		return true;
	}

}
#include "FWChildEnchant.h"
#include "iniH.h"

namespace FWChildEnchant {

	BSFixedString GetModFile(StaticFunctionTag* base, BSFixedString enchFile) {
		std::string f = "Data/BeeingFemale/Enchantment/";
		f.append(enchFile.data());
		return iniH::getIniString(f, "modName");
	}

	UInt32 GetFormID(StaticFunctionTag* base, BSFixedString enchFile) {
		std::string f = "Data/BeeingFemale/Enchantment/";
		f.append(enchFile.data());
		return iniH::getIniUInt32(f, "form");
	}

	UInt32 GetPowerMin(StaticFunctionTag* base, BSFixedString enchFile) {
		std::string f = "Data/BeeingFemale/Enchantment/";
		f.append(enchFile.data());
		return iniH::getIniUInt32(f, "power_min");
	}

	UInt32 GetPowerMax(StaticFunctionTag* base, BSFixedString enchFile) {
		std::string f = "Data/BeeingFemale/Enchantment/";
		f.append(enchFile.data());
		return iniH::getIniUInt32(f, "power_max");
	}

	bool RegisterFuncs(VMClassRegistry* registry) {
		registry->RegisterFunction("GetModFile", "FWChildEnchant", FWChildEnchant::GetModFile);

		registry->RegisterFunction("GetFormID", "FWChildEnchant", FWChildEnchant::GetFormID);

		registry->RegisterFunction("GetPowerMin", "FWChildEnchant", FWChildEnchant::GetPowerMin);

		registry->RegisterFunction("GetPowerMax", "FWChildEnchant", FWChildEnchant::GetPowerMax);
		return true;
	}

}



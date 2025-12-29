#include "CommonLibCompat.h"


namespace FWChildEnchant {
	BSFixedString GetModFile(StaticFunctionTag* base, BSFixedString enchFile);
	UInt32 GetFormID(StaticFunctionTag* base, BSFixedString enchFile);
	UInt32 GetPowerMin(StaticFunctionTag* base, BSFixedString enchFile);
	UInt32 GetPowerMax(StaticFunctionTag* base, BSFixedString enchFile);
	bool RegisterFuncs(VMClassRegistry* registry);
}

#include "skse64/PluginAPI.h"
#include "skse64/PapyrusArgs.h"
#include "skse64/PapyrusClass.h"
#include "skse64/PapyrusVM.h"
#include "skse64/PapyrusNativeFunctions.h"
#include <string>

namespace FWTextContents {
	void IOReadTranslation(StaticFunctionTag* base, BSFixedString lng);
	BSFixedString getLangText(StaticFunctionTag* base, BSFixedString content, BSFixedString VarName, BSFixedString DefaultValue);
	UInt32 getLangSize(StaticFunctionTag* base);

	bool RegisterFuncs(VMClassRegistry* registry);
}
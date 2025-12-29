#pragma once

#include "CommonLibCompat.h"
#include <string>

namespace FWTextContents {
	void IOReadTranslation(StaticFunctionTag* base, BSFixedString lng);
	BSFixedString getLangText(StaticFunctionTag* base, BSFixedString VarName);
	UInt32 getLangSize(StaticFunctionTag* base);
	UInt32 getErrorCode(StaticFunctionTag* base);
	BSFixedString getFilePath(StaticFunctionTag* base);

	bool RegisterFuncs(VMClassRegistry* registry);
}

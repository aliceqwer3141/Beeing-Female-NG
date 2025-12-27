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

namespace FWSystem {

	//SInt32 IsValidateFemaleActor(StaticFunctionTag* Base, Character *c);
	//SInt32 IsValidateGeneralActor(Character *c);
	bool HasKeyword(BGSKeywordForm keywordForm, char* s);
	bool Contains(const char* Text, char* contains, bool bIgnoreCase);

	bool RegisterFuncs(VMClassRegistry* registry);
}
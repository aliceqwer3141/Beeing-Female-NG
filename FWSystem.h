#include "CommonLibCompat.h"




namespace FWSystem {

	//SInt32 IsValidateFemaleActor(StaticFunctionTag* Base, Character *c);
	//SInt32 IsValidateGeneralActor(Character *c);
	bool HasKeyword(BGSKeywordForm* keywordForm, char* s);
	bool Contains(const char* Text, char* contains, bool bIgnoreCase);

	bool RegisterFuncs(VMClassRegistry* registry);
}

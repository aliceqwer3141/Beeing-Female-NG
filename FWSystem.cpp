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


//#include "skse64/PapyrusKeyword.h"
#include "skse64/GameForms.h"
#include "skse64/GameObjects.h"
#include "skse64/GameData.h"
#include "common/ICriticalSection.h"

#include "skse64/PapyrusNativeFunctions.h"

#include "FWSystem.h"
#include <string.h>


namespace FWSystem {

	bool HasKeyword(BGSKeywordForm* keywordForm, char* s) {
		/*UInt32 count = keywordForm->numKeywords;
		BGSKeyword ** keywords = keywordForm->keywords;
		if(keywords)
			for(int i = 0; i < count; i++) {
				BGSKeyword * pKey = keywords[i];
				if(pKey) {
					const char * keyString = pKey->keyword.Get();
					if(keyString == s)
						return true;
				}
			}*/
		return false;
	}

	bool Contains(const char* Text, char* contains, bool bIgnoreCase) {
		/*int i=0;
		int j=0;
		if(bIgnoreCase) {
			while(Text[i]!='\0') {
				if((Text[i] | 32) == (contains[j] | 32)) {
					while ((Text[i] | 32) == (contains[j] | 32) && contains[j]!='\0') {
						j++;
						i++;
					}
					if(contains[j]=='\0')
						return true;
					j=0;
				}
				i++;
			}
		} else {
			while(Text[i]!='\0'){
				if(Text[i] == contains[j]){
					while (Text[i] == contains[j] && contains[j]!='\0') {
						j++;
						i++;
					}
					if(contains[j]=='\0')
						return true;
					j=0;
				}
				i++;
			}
		}*/
		return false;
	}

	bool RegisterFuncs(VMClassRegistry* registry) {
		//_MESSAGE("registering functions");

		//registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, SInt32, Character*>("IsValidateFemaleActor", "FWSystem", FWSystem::IsValidateFemaleActor, registry));
		//registry->SetFunctionFlags("FWSystem", "IsValidateFemaleActor", VMClassRegistry::kFunctionFlag_NoWait);

		return true;
	}

}
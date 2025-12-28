

//#include "skse64/PapyrusKeyword.h"


#include "CommonLibCompat.h"
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

		//registry->RegisterFunction("IsValidateFemaleActor", "FWSystem", FWSystem::IsValidateFemaleActor);

		return true;
	}

}


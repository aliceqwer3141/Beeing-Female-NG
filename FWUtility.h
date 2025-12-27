#include "skse64/GameForms.h"
#include "skse64/GameRTTI.h"

#include "skse64/GameTypes.h"
#include "skse64/PapyrusArgs.h"
#include "skse64/GameForms.h"
#include "skse64/GameObjects.h"

#include "skse64/PluginAPI.h"
#include "skse64/PapyrusArgs.h"
#include "skse64/PapyrusClass.h"
#include "skse64/PapyrusVM.h"
#include "skse64/PapyrusNativeFunctions.h"

#include <string> 
#include <vector>

namespace FWUtility {

	template<typename T2, typename T1>
	inline T2 lexical_cast(const T1& in) {
		T2 out;
		std::stringstream ss;
		ss << in;
		ss >> out;
		return out;
	}
	template <class T>
	void endswap(T* objp) {
		unsigned char* memp = reinterpret_cast<unsigned char*>(objp);
		std::reverse(memp, memp + sizeof(T));
	}

	SInt32 GetQuestObjectCount(StaticFunctionTag*, BSFixedString modName);
	TESQuest* GetQuestObject(StaticFunctionTag*, BSFixedString modName, SInt32 index);

	TESForm* GetFormFromString(BSFixedString objString);
	BSFixedString GetStringFromForm(StaticFunctionTag* base, TESForm* frm);
	BSFixedString GetModFromForm(StaticFunctionTag* base, TESForm* frm);

	bool ScriptHasString(StaticFunctionTag* base, BSFixedString src, BSFixedString searchStr);
	SInt32 ScriptStringCount(StaticFunctionTag* base, BSFixedString src);
	BSFixedString ScriptUser(StaticFunctionTag* base, BSFixedString src);
	BSFixedString ScriptSource(StaticFunctionTag* base, BSFixedString src);
	BSFixedString ScriptMashine(StaticFunctionTag* base, BSFixedString src);
	BSFixedString ScriptStringGet(StaticFunctionTag* base, BSFixedString src, SInt32 Num);

	unsigned long ScriptFile_GetLong(std::ifstream& fs);
	unsigned int ScriptFile_GetInt(std::ifstream& fs);
	unsigned short ScriptFile_GetShort(std::ifstream& fs);
	unsigned char ScriptFile_GetByte(std::ifstream& fs);
	std::string ScriptFile_GetString(std::ifstream& fs);


	std::string ws2s(std::wstring const& text);
	std::string ReplaceAll(std::string str, const std::string& from, const std::string& to);
	//BSFixedString IOReadTranslation(StaticFunctionTag* base, BSFixedString lng);
	//BSFixedString getLangText(StaticFunctionTag* base, BSFixedString content, BSFixedString VarName, BSFixedString DefaultValue);
	UInt32 GetFileCount(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion);
	BSFixedString GetFileName(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion, UInt32 ID);

	BSFixedString GetDirectoryHash(StaticFunctionTag* Base, BSFixedString Directory);
	BSFixedString Hex(StaticFunctionTag* Base, SInt32 value, SInt32 Digits);
	std::string Hex_str(long value, int Digits);
	std::string HexDigit(long value, long max, int shift);
	long logical_right_shift(long x, long n);

	BSFixedString getIniPath(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file);


	BSFixedString getIniString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, BSFixedString def);
	bool getIniBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, bool def);
	SInt32 getIniInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, SInt32 variable, SInt32 def);
	float getIniFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, float variable, float def);

	BSFixedString getIniCString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, BSFixedString def);
	bool getIniCBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, bool def);
	SInt32 getIniCInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, SInt32 variable, SInt32 def);
	float getIniCFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, float variable, float def);



	void setIniString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, BSFixedString value);
	void setIniBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, bool value);
	void setIniInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, SInt32 value);
	void setIniFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, float value);

	void setIniCString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, BSFixedString value);
	void setIniCBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, bool value);
	void setIniCInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, SInt32 value);
	void setIniCFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, float value);

	// Array

	/*VMResultArray<BSFixedString*> getIniStringA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable);
	VMResultArray<bool> getIniBoolA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable);
	VMResultArray<SInt32> getIniIntA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable);
	VMResultArray<float> getIniFloatA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable);*/

	BSFixedString getNextAutoFile(StaticFunctionTag* base, BSFixedString Directory, BSFixedString FileName, BSFixedString Extention);
	bool FileExists(StaticFunctionTag* base, BSFixedString FilePath);
	BSFixedString getTypeString(UInt32 id);


	void split(const std::string& s, char delim, std::vector<std::string>& elems);
	std::vector<std::string> split(const std::string& s, char delim);

	bool RegisterFuncs(VMClassRegistry* registry);
}
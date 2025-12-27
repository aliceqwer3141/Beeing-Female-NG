#include "skse64/ScaleformLoader.h"

#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>

#include "skse64/GameAPI.h"
#include "skse64/GameData.h"
#include "skse64/GameTypes.h"
#include "skse64/GameForms.h"
#include "skse64/GameRTTI.h"
#include "skse64/Translation.h"
#include "skse64/ScaleformState.h"

#include "FWUtility.h"
#include "skse64/PapyrusNativeFunctions.h"
//#include "../common/IFileStream.h"
#include <fstream>
#include <codecvt>
#include <sys/stat.h>
#include <iostream>
#include <iomanip>

#include <clocale>
#include <locale>
#include <vector>
#include <algorithm>
#include <string>
#include <sstream>

#include "stdint.h"
#include <cstdint>
#include <windows.h>
#include <tchar.h>

#include "inisetting.h"

#include "common/IDirectoryIterator.h"


namespace FWUtility {


	TESQuest* GetQuestObject(StaticFunctionTag*, BSFixedString modName, SInt32 index) {
		DataHandler* dataHandler = DataHandler::GetSingleton();
		const ModInfo* modInfo = nullptr;
		modInfo = dataHandler->LookupModByName(modName.data);
		if (!modInfo) {
			std::string espName = modName.data;
			espName.append(".esp");
			modInfo = dataHandler->LookupModByName(espName.c_str());
		}
		if (!modInfo) {
			std::string esmName = modName.data;
			esmName.append(".esm");
			modInfo = dataHandler->LookupModByName(esmName.c_str());
		}
		int j = index;
		if (!modInfo) {
			TESQuest* quest = NULL;
			for (UInt32 i = 0; i < dataHandler->quests.count; i++) {
				dataHandler->quests.GetNthItem(i, quest);
				if ((quest->formID >> 24) != modInfo->modIndex)
					continue;
				if (j <= 0)
					return quest;
				j -= 1;
			}
		}
		return NULL;
	}

	SInt32 GetQuestObjectCount(StaticFunctionTag*, BSFixedString modName) {
		DataHandler* dataHandler = DataHandler::GetSingleton();
		const ModInfo* modInfo = nullptr;
		modInfo = dataHandler->LookupModByName(modName.data);
		if (!modInfo) {
			std::string espName = modName.data;
			espName.append(".esp");
			modInfo = dataHandler->LookupModByName(espName.c_str());
		}
		if (!modInfo) {
			std::string esmName = modName.data;
			esmName.append(".esm");
			modInfo = dataHandler->LookupModByName(esmName.c_str());
		}

		int c = 0;
		if (!modInfo) {
			TESQuest* quest = NULL;
			for (UInt32 i = 0; i < dataHandler->quests.count; i++) {
				dataHandler->quests.GetNthItem(i, quest);
				if ((quest->formID >> 24) != modInfo->modIndex)
					continue;
				c++;
			}
		}
		return c;
	}



	//static std::string language;

	int exist(char* name) {
		struct stat   buffer;
		return (stat(name, &buffer) == 0);
	}


	SInt32 ScriptStringCount(StaticFunctionTag* base, BSFixedString src) {
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/Scripts/";
		FileName.append(src.data);
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return -2;
		}
		if (fs.is_open()) {
			/*unsigned int fMagic;
			unsigned char fMajor;
			unsigned char fMinor;
			unsigned short fGameID;
			unsigned long fCompileTime;
			std::string fSourceFileName;
			std::string fUserName;
			std::string fMachineName;
			fs.read(reinterpret_cast<char*>(&fMagic), 4);
			fs.read(reinterpret_cast<char*>(&fMajor), 1);
			fs.read(reinterpret_cast<char*>(&fMinor), 1);
			fs.read(reinterpret_cast<char*>(&fGameID), 2);
			fs.read(reinterpret_cast<char*>(&fCompileTime), 8);
			fSourceFileName = ScriptHasString_GetString(fs);
			fUserName = ScriptHasString_GetString(fs);
			fMachineName = ScriptHasString_GetString(fs);*/

			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);

			fs.close();
			return StringTableCount;
		}
		return -1;
	}

	BSFixedString ScriptUser(StaticFunctionTag* base, BSFixedString src) {
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/Scripts/";
		FileName.append(src.data);
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return BSFixedString("");
		}
		if (fs.is_open()) {
			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);
			fs.close();
			return BSFixedString(fUserName.c_str());
		}
		return BSFixedString("");
	}

	BSFixedString ScriptSource(StaticFunctionTag* base, BSFixedString src) {
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/Scripts/";
		FileName.append(src.data);
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return BSFixedString("");
		}
		if (fs.is_open()) {
			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);
			fs.close();
			return BSFixedString(fSourceFileName.c_str());
		}
		return BSFixedString("");
	}

	BSFixedString ScriptMashine(StaticFunctionTag* base, BSFixedString src) {
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/Scripts/";
		FileName.append(src.data);
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return BSFixedString("");
		}
		if (fs.is_open()) {
			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);
			fs.close();
			return BSFixedString(fMachineName.c_str());
		}
		return BSFixedString("");
	}

	BSFixedString ScriptStringGet(StaticFunctionTag* base, BSFixedString src, SInt32 Num) {
		int n = Num;
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/Scripts/";
		FileName.append(src.data);
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return BSFixedString("");
		}
		if (fs.is_open()) {
			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);

			while (StringTableCount > 0) {
				StringTableCount -= 1;
				if (n <= 0) {
					fs.close();
					std::string str1 = ScriptFile_GetString(fs);
					return BSFixedString(str1.c_str());
				}
				n -= 1;
			}
			fs.close();
			return BSFixedString("");
		}
		return BSFixedString("");
	}

	bool ScriptHasString(StaticFunctionTag* base, BSFixedString src, BSFixedString searchStr) {
		std::string sStr = searchStr.data;
		const char* cStr = sStr.c_str();
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/scripts/";
		FileName.append(src.data);
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return false;
		}
		bool bFound = false;
		if (fs.is_open()) {
			//unsigned int fMagic;
			//unsigned char fMajor;
			//unsigned char fMinor;
			//unsigned short fGameID;
			//unsigned long fCompileTime;
			//std::string fSourceFileName;
			//std::string fUserName;
			//std::string fMachineName;
			//fs.read(reinterpret_cast<char*>(&fMagic), 4);
			//fs.read(reinterpret_cast<char*>(&fMajor), 1);
			//fs.read(reinterpret_cast<char*>(&fMinor), 1);
			//fs.read(reinterpret_cast<char*>(&fGameID), 2);
			//fs.read(reinterpret_cast<char*>(&fCompileTime), 8);
			//fSourceFileName = ScriptHasString_GetString(fs);
			//fUserName = ScriptHasString_GetString(fs);
			//fMachineName = ScriptHasString_GetString(fs);

			//unsigned short StringTableCount;
			//fs.read( reinterpret_cast<char*>(&StringTableCount) , sizeof(StringTableCount));
			//if(StringTableCount>0x4000)
			//	endswap(&StringTableCount);

			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);
			while (StringTableCount > 0 && !bFound) {
				StringTableCount -= 1;
				std::string str1 = ScriptFile_GetString(fs);
				if (strcmp(str1.c_str(), cStr) == 0)
					bFound = true;
			}
			fs.close();
		}
		return bFound;
	}

	unsigned char ScriptFile_GetByte(std::ifstream& fs) {
		//unsigned char b1;
		//fs>>b1;
		char b1;
		fs.read(&b1, 1);
		return b1;
	}

	unsigned short ScriptFile_GetShort(std::ifstream& fs) {
		char b1;
		char b2;
		fs.read(&b1, 1);
		fs.read(&b2, 1);
		unsigned short i1 = (int)b1;
		unsigned short i2 = (int)b2;
		return (i1 << 8) + i2;

		//unsigned char b1;
		//unsigned char b2;
		//fs>>b1;
		//fs>>b2;
		//return (b1*256) + b2;
	}

	unsigned int ScriptFile_GetInt(std::ifstream& fs) {
		//unsigned char b1;
		//unsigned char b2;
		//unsigned char b3;
		//unsigned char b4;
		//fs>>b1;
		//fs>>b2;
		//fs>>b3;
		//fs>>b4;
		//return (b1*0x1000000) + (b2*0x10000) + (b3*0x100) + b4;
		char b1;
		char b2;
		char b3;
		char b4;
		fs.read(&b1, 1);
		fs.read(&b2, 1);
		fs.read(&b3, 1);
		fs.read(&b4, 1);
		unsigned int i1 = (int)b1;
		unsigned int i2 = (int)b2;
		unsigned int i3 = (int)b3;
		unsigned int i4 = (int)b4;
		return (i1 << 24) + (i2 << 16) + (i3 << 8) + i4;
	}

	unsigned long ScriptFile_GetLong(std::ifstream& fs) {
		unsigned char b1;
		unsigned char b2;
		unsigned char b3;
		unsigned char b4;
		unsigned char b5;
		unsigned char b6;
		unsigned char b7;
		unsigned char b8;
		fs >> b1;
		fs >> b2;
		fs >> b3;
		fs >> b4;
		fs >> b5;
		fs >> b6;
		fs >> b7;
		fs >> b8;
		return 0; // Ignore - don't know how to read in a 64-bit integer
		//return (unsigned long)b8 | (unsigned long)b7<<8 | (unsigned long)b6<<16 | (unsigned long)b5<<24 | ((unsigned long)b4<<32) | ((unsigned long)b3<<40) | ((unsigned long)b2<<48) | ((unsigned long)b1<<56);
	}

	std::string ScriptFile_GetString(std::ifstream& fs) {
		unsigned short i_var = ScriptFile_GetShort(fs);

		/*char b1;
		char b2;
		fs.read(&b1, 1);
		fs.read(&b2, 1);
		unsigned short i1 = (int)b1;
		unsigned short i2 = (int)b2;
		unsigned short i_var = (i1<<8) + i2;*/

		std::string res;
		res.resize(i_var);
		fs.read(&res[0], i_var);
		return res;
		/*std::string res2;
		res2.append("(");
		res2.append(boost::lexical_cast<std::string>(i1));
		res2.append("+");
		res2.append(boost::lexical_cast<std::string>(i2));
		res2.append("=");
		res2.append(boost::lexical_cast<std::string>(i_var));
		res2.append(")");
		res2.append(res);
		return res2;*/
	}


	TESForm* GetFormFromString(StaticFunctionTag* base, BSFixedString fstr) {
		std::string objString = fstr.data;
		if (objString == "0")
			return NULL;
		std::vector<std::string> var;
		boost::split(var, objString, boost::is_any_of("_"));
		std::string mod = "";
		int i = 0;
		for (i = 0; i < var.size() - 1; i++) {
			if (i > 0) mod.append("_");
			mod.append(var[i]);
		}
		std::string esm = mod;
		std::string esp = mod;
		esm.append(".esm");
		esp.append(".esp");

		std::string id = var[var.size() - 1];

		const ModInfo* modInfo = nullptr;
		// Check for .esp extention
		modInfo = DataHandler::GetSingleton()->LookupModByName(esp.c_str());
		if (modInfo) {
			UInt8 indexEsp = modInfo->modIndex;
			TESForm* frmEsp = LookupFormByID((((UInt32)indexEsp) << 24) | strtol(id.c_str(), NULL, 16));
			if (frmEsp != NULL)
				return frmEsp;
		}

		// Check for .esm extention
		modInfo = DataHandler::GetSingleton()->LookupModByName(esm.c_str());
		if (modInfo) {
			UInt8 indexEsm = modInfo->modIndex;
			TESForm* frmEsm = LookupFormByID((((UInt32)indexEsm) << 24) | strtol(id.c_str(), NULL, 16));
			if (frmEsm != NULL)
				return frmEsm;
		}

		// Check with including extention
		modInfo = DataHandler::GetSingleton()->LookupModByName(mod.c_str());
		if (modInfo) {
			UInt8 index = modInfo->modIndex;
			TESForm* frm = LookupFormByID((((UInt32)index) << 24) | strtol(id.c_str(), NULL, 16));
			if (frm != NULL)
				return frm;
		}

		return NULL;
	}

	BSFixedString GetModFromString(StaticFunctionTag* base, BSFixedString fstr, bool bExt) {
		std::string objString = fstr.data;
		if (objString == "0")
			return NULL;
		std::vector<std::string> var;
		boost::split(var, objString, boost::is_any_of("_"));
		std::string mod = "";
		int i = 0;
		for (i = 0; i < var.size() - 1; i++) {
			if (i > 0) mod.append("_");
			mod.append(var[i]);
		}
		std::string esm = mod;
		std::string esp = mod;
		esm.append(".esm");
		esp.append(".esp");

		std::string id = var[var.size() - 1];

		const ModInfo* modInfo = nullptr;
		// Check for .esp extention
		modInfo = DataHandler::GetSingleton()->LookupModByName(esp.c_str());
		if (modInfo) {
			UInt8 indexEsp = modInfo->modIndex;
			TESForm* frmEsp = LookupFormByID((((UInt32)indexEsp) << 24) | strtol(id.c_str(), NULL, 16));
			if (frmEsp != NULL) {
				if (bExt) esp.append(".esp");
				return BSFixedString(esp.c_str());
			}
		}
		
		// Check for .esm extention
		modInfo = DataHandler::GetSingleton()->LookupModByName(esm.c_str());
		if (modInfo) {
			UInt8 indexEsm = modInfo->modIndex;
			TESForm* frmEsm = LookupFormByID((((UInt32)indexEsm) << 24) | strtol(id.c_str(), NULL, 16));
			if (frmEsm != NULL) {
				if (bExt) esm.append(".esm");
				return BSFixedString(esm.c_str());
			}
		}

		// Check with including extention
		modInfo = DataHandler::GetSingleton()->LookupModByName(mod.c_str());
		if (modInfo) {
			UInt8 index = modInfo->modIndex;
			TESForm* frm = LookupFormByID((((UInt32)index) << 24) | strtol(id.c_str(), NULL, 16));
			if (frm != NULL) {
				if (!bExt) {
					int lastindex = mod.find_last_of(".");
					mod = mod.substr(0, lastindex);
				}
				return BSFixedString(mod.c_str());
			}
		}

		return BSFixedString("NULL");
	}

	UInt32 GetFormIDFromString(StaticFunctionTag* base, BSFixedString fstr) {
		std::string objString = fstr.data;
		if (objString == "0")
			return NULL;
		std::vector<std::string> var;
		boost::split(var, objString, boost::is_any_of("_"));
		std::string mod = "";
		int i = 0;
		for (i = 0; i < var.size() - 1; i++) {
			if (i > 0) mod.append("_");
			mod.append(var[i]);
		}
		std::string esm = mod;
		std::string esp = mod;
		esm.append(".esm");
		esp.append(".esp");

		std::string id = var[var.size() - 1];

		const ModInfo* modInfo = nullptr;
		// Check for .esp extention
		modInfo = DataHandler::GetSingleton()->LookupModByName(esp.c_str());
		if (modInfo) {
			UInt8 indexEsp = modInfo->modIndex;
			TESForm* frmEsp = LookupFormByID((((UInt32)indexEsp) << 24) | strtol(id.c_str(), NULL, 16));
			if (frmEsp != NULL) {
				return frmEsp->formID;
			}
		}

		// Check for .esm extention
		modInfo = DataHandler::GetSingleton()->LookupModByName(esm.c_str());
		if (modInfo) {
			UInt8 indexEsm = modInfo->modIndex;
			TESForm* frmEsm = LookupFormByID((((UInt32)indexEsm) << 24) | strtol(id.c_str(), NULL, 16));
			if (frmEsm != NULL) {
				return frmEsm->formID;
			}
		}

		// Check with including extention
		modInfo = DataHandler::GetSingleton()->LookupModByName(mod.c_str());
		if (modInfo) {
			UInt8 index = modInfo->modIndex;
			TESForm* frm = LookupFormByID((((UInt32)index) << 24) | strtol(id.c_str(), NULL, 16));
			if (frm != NULL) {
				return frm->formID;
			}
		}
		return 0;
	}

	BSFixedString GetStringFromForm(StaticFunctionTag* base, TESForm* frm) {
		if (frm == NULL) return BSFixedString("");
		int frmID = frm->formID;
		int baseFormID = frmID % 0x1000000;
		int modID = frmID - baseFormID;
		modID /= 0x1000000;

		ModList ml = DataHandler::GetSingleton()->modList;
		std::string str = ml.loadedMods[modID]->name;

		int lastindex = str.find_last_of(".");
		str = str.substr(0, lastindex);

		str.append("_");
		str.append(Hex_str(baseFormID, 0));

		return BSFixedString(str.c_str());
	}

	BSFixedString GetModFromForm(StaticFunctionTag* base, TESForm* frm, bool bExt) {
		if (frm == NULL) return BSFixedString("");
		int frmID = frm->formID;
		int baseFormID = frmID % 0x1000000;
		int modID = frmID - baseFormID;
		if (modID < 0) return BSFixedString("-1");
		modID /= 0x1000000;
		if (modID > 255) return BSFixedString("-2");
		ModList ml = DataHandler::GetSingleton()->modList;
		if (modID > ml.loadedMods.count) return BSFixedString("-3");
		std::string str = ml.loadedMods[modID]->name;

		if (!bExt) {
			size_t lastindex = str.find_last_of(".");
			if (lastindex != std::string::npos)
				str = str.substr(0, lastindex);
		}

		return BSFixedString(str.c_str());
	}

	std::string ws2s(std::wstring const& text) {
		std::locale const loc("");
		wchar_t const* from = text.c_str();
		std::size_t const len = text.size();
		std::vector<char> buffer(len + 1);
		std::use_facet<std::ctype<wchar_t> >(loc).narrow(from, from + len, '_', &buffer[0]);
		return std::string(&buffer[0], &buffer[len]);
	}

	std::string ReplaceAll(std::string str, const std::string& from, const std::string& to) {
		size_t start_pos = 0;
		int maxCount = 20;
		while ((start_pos = str.find(from, start_pos)) != std::string::npos) {
			str.replace(start_pos, from.length(), to);
			start_pos += to.length();
			if (maxCount <= 0)
				break;
			maxCount--;
		}
		return str;
	}

	bool FileExists(StaticFunctionTag* base, BSFixedString FilePath) {
		std::fstream fi;
		std::string f = "Data/BeeingFemale/";
		f.append(FilePath.data);
		fi.open(f);
		if (fi.is_open() == true) {
			fi.close();
			return true;
		}
		else
			return false;
	}

	BSFixedString getNextAutoFile(StaticFunctionTag* base, BSFixedString Directory, BSFixedString FileName, BSFixedString Extention) {
		for (int i = 0; i < 128; i++) {
			std::string f = "Data/BeeingFemale/";
			f.append(Directory.data);
			f.append("/");
			f.append(FileName.data);
			if (i < 10)
				f.append("00");
			else if (i < 100)
				f.append("0");
			std::stringstream ss;
			ss << i;
			f.append(ss.str());
			f.append(".");
			f.append(Extention.data);

			std::fstream fi;
			fi.open(f);
			if (fi.is_open() == true) {
				fi.close();
			}
			else {
				std::string res = "";
				res.append(FileName.data);
				if (i < 10)
					res.append("00");
				else if (i < 100)
					res.append("0");
				res.append(ss.str());
				res.append(".");
				res.append(Extention.data);
				return BSFixedString(res.c_str());
			}
		}
		return "";
	}

	BSFixedString toLower(StaticFunctionTag* base, BSFixedString str) {
		std::string s = str.data;
		boost::to_lower(s);
		return BSFixedString(s.c_str());
	}
	BSFixedString toUpper(StaticFunctionTag* base, BSFixedString str) {
		std::string s = str.data;
		boost::to_upper(s);
		return BSFixedString(s.c_str());
	}

	/*BSFixedString IOReadTranslation(StaticFunctionTag* base, BSFixedString lng){
		std::wifstream fs;

		// Generating file name
		std::string FileName="Data/Interface/Translations/BeeingFemale_";
		FileName.append(lng.data);
		FileName.append(".txt");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		} catch (std::exception*){
			language = "";
			return NULL;
		}
		if (fs.is_open()) {
			// imbue the file stream
			//fs.imbue(std::locale(fs.getloc(), new std::codecvt_utf16<wchar_t, 0x10ffff, std::little_endian>));
			fs.imbue(std::locale(fs.getloc(), new std::codecvt_utf16<wchar_t, 0xFEFF, std::little_endian>));

			// Creating the converter
			std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> converter;

			// read file into file_content
			std::wstring file_content;
			fs.seekg(0, std::ios::end);
			file_content.resize(fs.tellg());
			fs.seekg(0, std::ios::beg); // Reset pos to 2
			fs.read(&file_content[0], file_content.size());
			fs.close();

			delete fs;

			// Convert and return the contents
			std::string res = converter.to_bytes(file_content.c_str());
			//std::string res = ws2s(file_content);
			language=res;
			//return BSFixedString(res.c_str());
			return NULL;
		} else {
			return NULL;
		}
	}



	BSFixedString getLangText(StaticFunctionTag* Base, BSFixedString content, BSFixedString VarName) {
		/*GFxLoader * tmpLoader = GFxLoader::GetSingleton();
		BSScaleformTranslator * trans = tmpLoader->stateBag->GetTranslator();

		TranslationTableItem * tti = trans->translations.Find(content.c_str());
		return BSFixedString(tti->translation.c_str());*/

		//std::string c = content.data;
		/*std::string c = language;
		std::string find;
		find.append("$");
		find.append(VarName.data);
		find.append("\t");
		if(c.length()==0)
			return "";

		int pos=c.find (find);
		if( pos!=-1) {

			int posStart = pos + find.length();
			int posEnd1 = c.find("\r",posStart);
			int posEnd2 = c.find("\n",posStart);
			int posEnd = -1;
			if(posEnd1>-1 && posEnd1<posEnd2)
				posEnd=posEnd1;
			else if(posEnd2>-1 && posEnd2<posEnd1)
				posEnd=posEnd2;
			if(posEnd==-1)
				posEnd = c.length();
			int len=posEnd - posStart;
			return BSFixedString(c.substr(posStart,len).c_str());
		}
		//Console_Print("Variable not found: ",VarName.data);
		return "";
	}*/

	BSFixedString StringReplace(StaticFunctionTag* Base, BSFixedString content, BSFixedString Find, BSFixedString Replace) {
		std::string str1 = content.data;
		std::string res = ReplaceAll(str1, Find.data, Replace.data);
		return BSFixedString(res.c_str());
	}

	BSFixedString MultiStringReplace(StaticFunctionTag* Base, BSFixedString content, BSFixedString Replace0, BSFixedString Replace1, BSFixedString Replace2, BSFixedString Replace3, BSFixedString Replace4, BSFixedString Replace5) {
		std::string str1 = content.data;
		std::string res1 = ReplaceAll(str1, "{0}", Replace0.data);
		std::string res2 = ReplaceAll(res1, "{1}", Replace1.data);
		std::string res3 = ReplaceAll(res2, "{2}", Replace2.data);
		std::string res4 = ReplaceAll(res3, "{3}", Replace3.data);
		std::string res5 = ReplaceAll(res4, "{4}", Replace4.data);
		std::string res6 = ReplaceAll(res5, "{5}", Replace5.data);
		return BSFixedString(res6.c_str());
	}


	BSFixedString GetDirectoryHash(StaticFunctionTag* Base, BSFixedString Directory) {
		WIN32_FIND_DATA FindData;
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		std::string dir2 = dir;
		dir2.append("*.*");
		HANDLE hFind = FindFirstFile(dir2.c_str(), &FindData);
		int count = 0;
		int FNameLen = 0;
		long FSize = 0;
		if (&FindData) {
			do {
				std::string x = FindData.cFileName;

				if (x != "." && x != "..") {
					// Get FileName Length
					FNameLen += x.length();

					// Get FileSize
					std::wifstream fs;
					std::string FileName = dir;
					FileName.append(x);
					try {
						fs.open(FileName, std::ifstream::binary);
						fs.seekg(0, std::ifstream::end);
						FSize += fs.tellg();
						fs.close();
					}
					catch (std::exception*) {
						return BSFixedString("");
					}

					// Add Counter*/
					count++;
				}
			} while (FindNextFile(hFind, &FindData));
		}

		FindClose(hFind);

		// Example Result: 0079-7d7-08b-6c57-000862
		std::string res = Hex_str(count, 3);
		res.append(Hex_str((count % 13) + 2, 1));
		res.append("-");
		res.append(Hex_str(FNameLen % 11, 1));
		res.append(Hex_str(FNameLen % 14, 1));
		res.append(Hex_str((FNameLen % 9) + 3, 1));
		res.append("-");
		res.append(Hex_str(FNameLen % 2100, 3));
		res.append("-");
		res.append(Hex_str((FSize % 11) + 5, 1));
		res.append(Hex_str((FSize % 10) + 6, 1));
		res.append(Hex_str((FSize % 230) + 11, 2));
		res.append("-");
		res.append(Hex_str(FSize % 8388500, 6));
		return BSFixedString(res.c_str());
	}

	BSFixedString Hex(StaticFunctionTag* Base, SInt32 value, SInt32 Digits) {
		return BSFixedString(Hex_str(value, Digits).c_str());
	}
	std::string Hex_str(long value, int Digits) {
		std::stringstream ss;
		if (Digits > 8)
			Digits = 8;
		else if (Digits < 0)
			Digits = 1;
		if (Digits == 0) {
			ss << std::setfill('0') << std::setw(1)
				<< std::hex << value;
		}
		else {
			ss << std::setfill('0') << std::setw(Digits)
				<< std::hex << value;
		}
		std::string s = ss.str();
		if (s.size() > Digits && Digits > 0)
			s = s.substr(s.size() - Digits);
		return s;

		// This code is overdue
		/*std::string sHex="";
		switch(Digits) {
		case 0: return "";
		case 1: // signed Byte
			return HexDigit(value,0xf,0);
		case 2: // Byte
			sHex = HexDigit(value,0xf0,4);
			sHex.append(HexDigit(value,0xf,0));
		case 3: // unsigned short
			sHex = HexDigit(value,0xf00,8);
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 4: // short
			sHex = HexDigit(value,0xf000,12);
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 5:
			sHex = HexDigit(value,0xf0000,16);
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 6: // unsigned int
			sHex = HexDigit(value,0xf00000,20);
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 7:
			sHex = HexDigit(value,0xf000000,24);
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 8: // int
			sHex = HexDigit(value,0xf0000000,28);
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		*/
		/*case 9:
			sHex = HexDigit(value,0xf00000000,32);
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 10:
			sHex = HexDigit(value,0xf000000000,36);
			sHex.append(HexDigit(value,0xf00000000,32));
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 11:
			sHex = HexDigit(value,0xf0000000000,40);
			sHex.append(HexDigit(value,0xf000000000,36));
			sHex.append(HexDigit(value,0xf00000000,32));
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 12:
			sHex = HexDigit(value,0xf00000000000,44);
			sHex.append(HexDigit(value,0xf0000000000,40));
			sHex.append(HexDigit(value,0xf000000000,36));
			sHex.append(HexDigit(value,0xf00000000,32));
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 13: //
			sHex = HexDigit(value,0xf000000000000,48);
			sHex.append(HexDigit(value,0xf00000000000,44));
			sHex.append(HexDigit(value,0xf0000000000,40));
			sHex.append(HexDigit(value,0xf000000000,36));
			sHex.append(HexDigit(value,0xf00000000,32));
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 14: // unsigned long
			sHex = HexDigit(value,0xf0000000000000,52);
			sHex.append(HexDigit(value,0xf000000000000,48));
			sHex.append(HexDigit(value,0xf00000000000,44));
			sHex.append(HexDigit(value,0xf0000000000,40));
			sHex.append(HexDigit(value,0xf000000000,36));
			sHex.append(HexDigit(value,0xf00000000,32));
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));*/
			//}
			//return sHex;
	}
	std::string HexDigit(long value, long max, int shift) {
		long x = 0;
		if (shift < 1)
			x = value && max;
		else
			x = logical_right_shift(value && max, shift);
		switch (x) {
		case 0: return "0";
		case 1: return "1";
		case 2: return "2";
		case 3: return "3";
		case 4: return "4";
		case 5: return "5";
		case 6: return "6";
		case 7: return "7";
		case 8: return "8";
		case 9: return "9";
		case 10: return "A";
		case 11: return "B";
		case 12: return "C";
		case 13: return "D";
		case 14: return "E";
		case 15: return "F";
		}
		return "";
	}
	long logical_right_shift(long x, long n) {
		return (unsigned)x >> n;
	}


	UInt32 GetFileCount(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion) {
		WIN32_FIND_DATA FindData;
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append("*.").append(extantion.data);
		HANDLE hFind = FindFirstFile(dir.c_str(), &FindData);
		int count = 0;
		if (&FindData) {
			count++;
			while (FindNextFile(hFind, &FindData))
				count++;
		}
		FindClose(hFind);
		return count;
	}

	BSFixedString GetFileName(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion, UInt32 ID) {
		WIN32_FIND_DATA FindData;
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append("*.").append(extantion.data);
		HANDLE hFind = FindFirstFile(dir.c_str(), &FindData);
		int count = 0;
		if (&FindData) {
			do {
				if (ID == count) {
					//std::string x = FindData.cFileName;
					//return BSFixedString(x.c_str());
					FindClose(hFind);
					return BSFixedString(FindData.cFileName);
				}
				count++;
			} while (FindNextFile(hFind, &FindData));
		}
		FindClose(hFind);
		return "";
	}

	/*BSFixedString GetFileName(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion, UInt32 ID) {
		std::string dir = Directory.data;
		if(dir.substr(dir.length() - 1,1) != "/" && dir.substr(dir.length() - 1,1) != "\\")
			dir.append("/");
		dir.append("*.").append(extantion.data);

		WIN32_FIND_DATA FindData;
		HANDLE hFind = FindFirstFile(dir.c_str(), &FindData);
		int count=0;
		std::string name1="";
		PTSTR name2;
		char* name3;
		char* name4;
		//_MESSAGE("BeeingFemale::GetFileName()");
		if(&FindData) {
			//_MESSAGE(FindData.cFileName);
			do {
				if(count==ID) {
					name1=std::string(FindData.cFileName).c_str();
					name2=FindData.cFileName;
					name3=FindData.cFileName;
					name4=_T("%s",FindData.cFileName.c_str());
					break;
				}
				count++;
			} while(FindNextFile(hFind, &FindData));
		}
		FindClose(hFind);
		//return BSFixedString(name1.c_str());
		//return BSFixedString(name2);
		return BSFixedString(name3);
		return BSFixedString(name4);
	}*/


	BSFixedString getIniPath(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		return BSFixedString(dir.c_str());
	}


	BSFixedString getIniString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, BSFixedString def) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpDef = def.data;
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, tmpDef, tmpDir);
		return BSFixedString(x.c_str());
	}
	bool getIniBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, bool def) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpDef = def ? "True" : "False";
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, tmpDef, tmpDir);
		return x == "y" || x == "Y" || x == "1" || x == "true" || x == "TRUE" || x == "True" || x == "Yes" || x == "yes" || x == "YES";
	}
	SInt32 getIniInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, SInt32 def) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();

		std::string tmpString = GetPrivateProfile<std::string>(tmpType, tmpVariable, "", tmpDir);
		if (tmpString != "")
			if (tmpString.substr(0, 2) == "0x" && tmpString.length() <= 10) {
				if (tmpString.length() == 2) return 0;
				//signed int conv = std::stoul(tmpString, nullptr, 32);
				int conv;
				std::stringstream ss;
				ss << std::hex << tmpString.substr(2);
				ss >> conv;
				return conv;
			}

		SInt32 x = GetPrivateProfile<int>(tmpType, tmpVariable, def, tmpDir);
		return x;
	}
	float getIniFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, float def) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();

		float x = GetPrivateProfile<float>(tmpType, tmpVariable, def, tmpDir);
		return x;
	}

	BSFixedString getIniCString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, BSFixedString def) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		const char* tmpType = categorie.data;
		const char* tmpVariable = variable.data;
		const char* tmpDef = def.data;
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, tmpDef, tmpDir);
		return BSFixedString(x.c_str());
	}
	bool getIniCBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, bool def) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data);
		const char* tmpType = categorie.data;
		const char* tmpVariable = variable.data;
		const char* tmpDef = def ? "True" : "False";
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, tmpDef, tmpDir);
		return x == "y" || x == "Y" || x == "1" || x == "true" || x == "TRUE" || x == "True" || x == "Yes" || x == "yes" || x == "YES";
	}
	SInt32 getIniCInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, SInt32 def) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		const char* tmpType = categorie.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();

		std::string tmpString = GetPrivateProfile<std::string>(tmpType, tmpVariable, "", tmpDir);
		if (tmpString != "")
			if (tmpString.substr(0, 2) == "0x" && tmpString.length() <= 10) {
				if (tmpString.length() == 2) return 0;
				//signed int conv = std::stoul(tmpString, nullptr, 32);
				int conv;
				std::stringstream ss;
				ss << std::hex << tmpString.substr(2);
				ss >> conv;
				return conv;
			}

		SInt32 x = GetPrivateProfile<int>(tmpType, tmpVariable, def, tmpDir);
		return x;
	}
	float getIniCFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, float def) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data);
		const char* tmpType = categorie.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();

		float x = GetPrivateProfile<float>(tmpType, tmpVariable, def, tmpDir);
		return x;
	}

	void setIniString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, BSFixedString value) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpVal = value.data;
		const char* tmpDir = dir.c_str();
		WritePrivateProfile<std::string>(tmpType, tmpVariable, tmpVal, tmpDir);
		return;
	}
	void setIniBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, bool value) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpVal = value ? "True" : "False";
		const char* tmpDir = dir.c_str();
		WritePrivateProfile<std::string>(tmpType, tmpVariable, tmpVal, tmpDir);
		return;
	}
	void setIniInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, SInt32 value) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();
		WritePrivateProfile<SInt32>(tmpType, tmpVariable, value, tmpDir);
		return;
	}
	void setIniFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, float value) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();

		WritePrivateProfile<float>(tmpType, tmpVariable, value, tmpDir);
		return;
	}

	void setIniCString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, BSFixedString value) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		const char* tmpType = categorie.data;
		const char* tmpVariable = variable.data;
		const char* tmpVal = value.data;
		const char* tmpDir = dir.c_str();
		WritePrivateProfile<std::string>(tmpType, tmpVariable, tmpVal, tmpDir);
		return;
	}
	void setIniCBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, bool value) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data);
		const char* tmpType = categorie.data;
		const char* tmpVariable = variable.data;
		const char* tmpVal = value ? "True" : "False";
		const char* tmpDir = dir.c_str();
		WritePrivateProfile<std::string>(tmpType, tmpVariable, tmpVal, tmpDir);
		return;
	}
	void setIniCInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, SInt32 value) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		const char* tmpType = categorie.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();

		WritePrivateProfile<SInt32>(tmpType, tmpVariable, value, tmpDir);
		return;
	}
	void setIniCFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, float value) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data);
		const char* tmpType = categorie.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();

		WritePrivateProfile<float>(tmpType, tmpVariable, value, tmpDir);
		return;
	}




	/*VMResultArray<BSFixedString*> getIniStringA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if(dir.substr(dir.length() - 1,1) != "/" && dir.substr(dir.length() - 1,1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, "", tmpDir);
		std::vector<std::string> a = split('|',x);
		VMResultArray<BSFixedString> ab;
		ab.resize(a.size(), 0);
		int i=0;
		while(i<ab.size()) {
			ab[i]=BSFixedString(a[i].c_str());
			i++;
		}
		return ab;
	}
	VMResultArray<bool> getIniBoolA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if(dir.substr(dir.length() - 1,1) != "/" && dir.substr(dir.length() - 1,1) != "\\")
			dir.append("/");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, "", tmpDir);
		std::vector<std::string> a = split('|',x);
		VMResultArray<bool> ab;
		ab.resize(a.size(), 0);
		int i=0;
		while(i<ab.size()) {
			ab[i]=(x=="y"||x=="Y"||x=="1"||x=="true"||x=="TRUE"||x=="True"||x=="Yes"||x=="yes"||x=="YES");
			i++;
		}
		return ab;
	}
	VMResultArray<SInt32> getIniIntA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data);
		if(dir.substr(dir.length() - 1,1) != "/" && dir.substr(dir.length() - 1,1) != "\\")
			dir.append("\\");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, "", tmpDir);
		std::vector<std::string> a = split('|',x);
		VMResultArray<SInt32> ab;
		ab.resize(a.size(), 0);
		int i=0;
		while(i<ab.size()) {
			if(a[i]=="") {
				ab[i]=0;
			} else if(a[i].size()>=2 && a[i].substr(0,2)=="0x") {
				if(a[i].size()==2)
					ab[i]=0;
				else
					ab[i]=(int)strtol(a[i].substr(2), NULL, 16);
			} else if(a[i].size()<11) {
				bool bIsNumeric=true;
				int j=0;
				while(j<a[i].size() && bIsNumeric) {
					switch(a[i].substr(j,1))
					case "0":
					case "1":
					case "2":
					case "3":
					case "4":
					case "5":
					case "6":
					case "7":
					case "8":
					case "9":
						break;
					case"-":
						if(j>0)
							bIsNumeric=false;
						break;
					default:
						bIsNumeric=false;
						break;
					j++;
				}
				if(bIsNumeric) {
					ab[i]=(int)strtol(a[i], NULL, 16);
				} else
					ab[i]=0;
			} else
				ab[i]=0;
			i++;
		}
		return ab;
	}
	VMResultArray<float> getIniFloatA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data);
		if(dir.substr(dir.length() - 1,1) != "/" && dir.substr(dir.length() - 1,1) != "\\")
			dir.append("/");
		dir.append(file.data);
		const char* tmpType = Directory.data;
		const char* tmpVariable = variable.data;
		const char* tmpDir = dir.c_str();

		float x = GetPrivateProfile<float>(tmpType, tmpVariable, 0, tmpDir);
		std::vector<std::string> a = split('|',x);
		VMResultArray<float> ab;
		ab.resize(a.size(), 0);
		int i=0;
		while(i<ab.size()) {
			if(a[i]=="") {
				ab[i]=0;
			} else if(a[i].size()<16) {
				bool bIsNumeric=true;
				int j=0;
				while(j<a[i].size() && bIsNumeric) {
					switch(a[i].substr(j,1))
					case "0":
					case "1":
					case "2":
					case "3":
					case "4":
					case "5":
					case "6":
					case "7":
					case "8":
					case "9":
					case ".":
						break;
					case"-":
						if(j>0)
							bIsNumeric=false;
						break;
					default:
						bIsNumeric=false;
						break;
					j++;
				}
				if(bIsNumeric) {
					ab[i]=(float)atof(a[i].c_str());
				} else
					ab[i]=0.0;
			} else
				ab[i]=0.0;
			i++;
		}
		return ab;
	}*/





	BSFixedString getTypeString(StaticFunctionTag* Base, UInt32 id) {
		switch (id) {
		case 83: return "kANIO"; break;
		case 102: return "kARMA"; break;
		case 16: return "kAcousticSpace"; break;
		case 6: return "kAction"; break;
		case 24: return "kActivator"; break;
		case 95: return "kActorValueInfo"; break;
		case 94: return "kAddonNode"; break;
		case 42: return "kAmmo"; break;
		case 33: return "kApparatus"; break;
		case 26: return "kArmor"; break;
		case 64: return "kArrowProjectile"; break;
		case 125: return "kArt"; break;
		case 123: return "kAssociationType"; break;
		case 69: return "kBarrierProjectile"; break;
		case 66: return "kBeamProjectile"; break;
		case 93: return "kBodyPartData"; break;
		case 27: return "kBook"; break;
		case 97: return "kCameraPath"; break;
		case 96: return "kCameraShot"; break;
		case 60: return "kCell"; break;
		case 62: return "kCharacter"; break;
		case 10: return "kClass"; break;
		case 55: return "kClimate"; break;
		case 132: return "kCollisionLayer"; break;
		case 133: return "kColorForm"; break;
		case 80: return "kCombatStyle"; break;
		case 68: return "kConeProjectile"; break;
		case 49: return "kConstructibleObject"; break;
		case 28: return "kContainer"; break;
		case 117: return "kDLVW"; break;
		case 88: return "kDebris"; break;
		case 107: return "kDefaultObject"; break;
		case 115: return "kDialogueBranch"; break;
		case 29: return "kDoor"; break;
		case 129: return "kDualCastData"; break;
		case 18: return "kEffectSetting"; break;
		case 85: return "kEffectShader"; break;
		case 21: return "kEnchantment"; break;
		case 103: return "kEncounterZone"; break;
		case 120: return "kEquipSlot"; break;
		case 87: return "kExplosion"; break;
		case 13: return "kEyes"; break;
		case 11: return "kFaction"; break;
		case 67: return "kFlameProjectile"; break;
		case 39: return "kFlora"; break;
		case 110: return "kFootstep"; break;
		case 111: return "kFootstepSet"; break;
		case 40: return "kFurniture"; break;
		case 3: return "kGMST"; break;
		case 9: return "kGlobal"; break;
		case 37: return "kGrass"; break;
		case 65: return "kGrenadeProjectile"; break;
		case 2: return "kGroup"; break;
		case 51: return "kHazard"; break;
		case 12: return "kHeadPart"; break;
		case 78: return "kIdle"; break;
		case 47: return "kIdleMarker"; break;
		case 89: return "kImageSpace"; break;
		case 90: return "kImageSpaceModifier"; break;
		case 100: return "kImpactData"; break;
		case 101: return "kImpactDataSet"; break;
		case 30: return "kIngredient"; break;
		case 45: return "kKey"; break;
		case 4: return "kKeyword"; break;
		case 72: return "kLand"; break;
		case 20: return "kLandTexture"; break;
		case 44: return "kLeveledCharacter"; break;
		case 53: return "kLeveledItem"; break;
		case 82: return "kLeveledSpell"; break;
		case 31: return "kLight"; break;
		case 108: return "kLightingTemplate"; break;
		case 91: return "kList"; break;
		case 81: return "kLoadScreen"; break;
		case 104: return "kLocation"; break;
		case 5: return "kLocationRef"; break;
		case 126: return "kMaterial"; break;
		case 99: return "kMaterialType"; break;
		case 8: return "kMenuIcon"; break;
		case 105: return "kMessage"; break;
		case 32: return "kMisc"; break;
		case 63: return "kMissileProjectile"; break;
		case 36: return "kMovableStatic"; break;
		case 127: return "kMovementType"; break;
		case 116: return "kMusicTrack"; break;
		case 109: return "kMusicType"; break;
		case 59: return "kNAVI"; break;
		case 43: return "kNPC"; break;
		case 73: return "kNavMesh"; break;
		case 0: return "kNone"; break;
		case 48: return "kNote"; break;
		case 124: return "kOutfit"; break;
		case 70: return "kPHZD"; break;
		case 79: return "kPackage"; break;
		case 92: return "kPerk"; break;
		case 46: return "kPotion"; break;
		case 50: return "kProjectile"; break;
		case 77: return "kQuest"; break;
		case 14: return "kRace"; break;
		case 106: return "kRagdoll"; break;
		case 61: return "kReference"; break;
		case 57: return "kReferenceEffect"; break;
		case 58: return "kRegion"; break;
		case 121: return "kRelationship"; break;
		case 134: return "kReverbParam"; break;
		case 122: return "kScene"; break;
		case 19: return "kScript"; break;
		case 23: return "kScrollItem"; break;
		case 56: return "kShaderParticleGeometryData"; break;
		case 119: return "kShout"; break;
		case 17: return "kSkill"; break;
		case 52: return "kSoulGem"; break;
		case 15: return "kSound"; break;
		case 130: return "kSoundCategory"; break;
		case 128: return "kSoundDescriptor"; break;
		case 131: return "kSoundOutput"; break;
		case 22: return "kSpell"; break;
		case 34: return "kStatic"; break;
		case 35: return "kStaticCollection"; break;
		case 112: return "kStoryBranchNode"; break;
		case 114: return "kStoryEventNode"; break;
		case 113: return "kStoryQuestNode"; break;
		case 1: return "kTES4"; break;
		case 74: return "kTLOD"; break;
		case 86: return "kTOFT"; break;
		case 25: return "kTalkingActivator"; break;
		case 7: return "kTextureSet"; break;
		case 75: return "kTopic"; break;
		case 76: return "kTopicInfo"; break;
		case 38: return "kTree"; break;
		case 98: return "kVoiceType"; break;
		case 84: return "kWater"; break;
		case 41: return "kWeapon"; break;
		case 54: return "kWeather"; break;
		case 118: return "kWordOfPower"; break;
		case 71: return "kWorldSpace"; break;
		default: return "UNKNOWN";
		}
	}

	void split(const std::string& s, char delim, std::vector<std::string>& elems) {
		std::stringstream ss;
		ss.str(s);
		std::string item;
		while (std::getline(ss, item, delim)) {
			elems.push_back(item);
		}
	}
	std::vector<std::string> split(const std::string& s, char delim) {
		std::vector<std::string> elems;
		split(s, delim, elems);
		return elems;
	}

	bool RegisterFuncs(VMClassRegistry* registry) {
		//_MESSAGE("registering functions");

		//registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("IOReadTranslation", "FWUtility", FWUtility::IOReadTranslation, registry));
		//registry->SetFunctionFlags("FWUtility", "IOReadTranslation", VMClassRegistry::kFunctionFlag_NoWait);

		//registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, BSFixedString, BSFixedString, BSFixedString>("getLangText", "FWUtility", FWUtility::getLangText, registry));
		//registry->SetFunctionFlags("FWUtility", "getLangText", VMClassRegistry::kFunctionFlag_NoWait);


		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("toLower", "FWUtility", FWUtility::toLower, registry));
		registry->SetFunctionFlags("FWUtility", "toLower", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("toUpper", "FWUtility", FWUtility::toUpper, registry));
		registry->SetFunctionFlags("FWUtility", "toUpper", VMClassRegistry::kFunctionFlag_NoWait);


		registry->RegisterFunction(new NativeFunction3<StaticFunctionTag, BSFixedString, BSFixedString, BSFixedString, BSFixedString>("StringReplace", "FWUtility", FWUtility::StringReplace, registry));
		registry->SetFunctionFlags("FWUtility", "StringReplace", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction7<StaticFunctionTag, BSFixedString, BSFixedString, BSFixedString, BSFixedString, BSFixedString, BSFixedString, BSFixedString, BSFixedString>("MultiStringReplace", "FWUtility", FWUtility::MultiStringReplace, registry));
		registry->SetFunctionFlags("FWUtility", "MultiStringReplace", VMClassRegistry::kFunctionFlag_NoWait);



		registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, TESQuest*, BSFixedString, SInt32>("GetQuestObject", "FWUtility", FWUtility::GetQuestObject, registry));
		registry->SetFunctionFlags("FWUtility", "GetQuestObject", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, SInt32, BSFixedString>("GetQuestObjectCount", "FWUtility", FWUtility::GetQuestObjectCount, registry));
		registry->SetFunctionFlags("FWUtility", "GetQuestObjectCount", VMClassRegistry::kFunctionFlag_NoWait);




		registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, UInt32, BSFixedString, BSFixedString>("GetFileCount", "FWUtility", FWUtility::GetFileCount, registry));
		registry->SetFunctionFlags("FWUtility", "GetFileCount", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction3<StaticFunctionTag, BSFixedString, BSFixedString, BSFixedString, UInt32>("GetFileName", "FWUtility", FWUtility::GetFileName, registry));
		registry->SetFunctionFlags("FWUtility", "GetFileName", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, UInt32>("getTypeString", "FWUtility", FWUtility::getTypeString, registry));
		registry->SetFunctionFlags("FWUtility", "getTypeString", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, BSFixedString, BSFixedString, BSFixedString>("getIniPath", "FWUtility", FWUtility::getIniPath, registry));
		registry->SetFunctionFlags("FWUtility", "getIniPath", VMClassRegistry::kFunctionFlag_NoWait);



		// Script Functions
		registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, bool, BSFixedString, BSFixedString>("ScriptHasString", "FWUtility", FWUtility::ScriptHasString, registry));
		registry->SetFunctionFlags("FWUtility", "ScriptHasString", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, SInt32, BSFixedString>("ScriptStringCount", "FWUtility", FWUtility::ScriptStringCount, registry));
		registry->SetFunctionFlags("FWUtility", "ScriptStringCount", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("ScriptUser", "FWUtility", FWUtility::ScriptUser, registry));
		registry->SetFunctionFlags("FWUtility", "ScriptUser", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("ScriptSource", "FWUtility", FWUtility::ScriptSource, registry));
		registry->SetFunctionFlags("FWUtility", "ScriptSource", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("ScriptMashine", "FWUtility", FWUtility::ScriptMashine, registry));
		registry->SetFunctionFlags("FWUtility", "ScriptMashine", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, BSFixedString, BSFixedString, SInt32>("ScriptStringGet", "FWUtility", FWUtility::ScriptStringGet, registry));
		registry->SetFunctionFlags("FWUtility", "ScriptStringGet", VMClassRegistry::kFunctionFlag_NoWait);


		//SInt32 ScriptStringCount(StaticFunctionTag* base, BSFixedString src)
		//BSFixedString ScriptUser(StaticFunctionTag* base, BSFixedString src)
		//BSFixedString ScriptSource(StaticFunctionTag* base, BSFixedString src)
		//BSFixedString ScriptMashine(StaticFunctionTag* base, BSFixedString src)
		//BSFixedString ScriptStringGet(StaticFunctionTag* base, BSFixedString src, SInt32 Num)


		// Ini get
		registry->RegisterFunction(new NativeFunction4<StaticFunctionTag, BSFixedString, BSFixedString, BSFixedString, BSFixedString, BSFixedString>("getIniString", "FWUtility", FWUtility::getIniString, registry));
		registry->SetFunctionFlags("FWUtility", "getIniString", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction4<StaticFunctionTag, bool, BSFixedString, BSFixedString, BSFixedString, bool>("getIniBool", "FWUtility", FWUtility::getIniBool, registry));
		registry->SetFunctionFlags("FWUtility", "getIniBool", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction4<StaticFunctionTag, SInt32, BSFixedString, BSFixedString, BSFixedString, SInt32>("getIniInt", "FWUtility", FWUtility::getIniInt, registry));
		registry->SetFunctionFlags("FWUtility", "getIniInt", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction4<StaticFunctionTag, float, BSFixedString, BSFixedString, BSFixedString, float>("getIniFloat", "FWUtility", FWUtility::getIniFloat, registry));
		registry->SetFunctionFlags("FWUtility", "getIniFloat", VMClassRegistry::kFunctionFlag_NoWait);

		// Ini get via Categorie
		registry->RegisterFunction(new NativeFunction5<StaticFunctionTag, BSFixedString, BSFixedString, BSFixedString, BSFixedString, BSFixedString, BSFixedString>("getIniCString", "FWUtility", FWUtility::getIniCString, registry));
		registry->SetFunctionFlags("FWUtility", "getIniCString", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction5<StaticFunctionTag, bool, BSFixedString, BSFixedString, BSFixedString, BSFixedString, bool>("getIniCBool", "FWUtility", FWUtility::getIniCBool, registry));
		registry->SetFunctionFlags("FWUtility", "getIniCBool", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction5<StaticFunctionTag, SInt32, BSFixedString, BSFixedString, BSFixedString, BSFixedString, SInt32>("getIniCInt", "FWUtility", FWUtility::getIniCInt, registry));
		registry->SetFunctionFlags("FWUtility", "getIniCInt", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction5<StaticFunctionTag, float, BSFixedString, BSFixedString, BSFixedString, BSFixedString, float>("getIniCFloat", "FWUtility", FWUtility::getIniCFloat, registry));
		registry->SetFunctionFlags("FWUtility", "getIniCFloat", VMClassRegistry::kFunctionFlag_NoWait);




		// Ini set
		registry->RegisterFunction(new NativeFunction4<StaticFunctionTag, void, BSFixedString, BSFixedString, BSFixedString, BSFixedString>("setIniString", "FWUtility", FWUtility::setIniString, registry));
		registry->SetFunctionFlags("FWUtility", "setIniString", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction4<StaticFunctionTag, void, BSFixedString, BSFixedString, BSFixedString, bool>("setIniBool", "FWUtility", FWUtility::setIniBool, registry));
		registry->SetFunctionFlags("FWUtility", "setIniBool", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction4<StaticFunctionTag, void, BSFixedString, BSFixedString, BSFixedString, SInt32>("setIniInt", "FWUtility", FWUtility::setIniInt, registry));
		registry->SetFunctionFlags("FWUtility", "setIniInt", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction4<StaticFunctionTag, void, BSFixedString, BSFixedString, BSFixedString, float>("setIniFloat", "FWUtility", FWUtility::setIniFloat, registry));
		registry->SetFunctionFlags("FWUtility", "setIniFloat", VMClassRegistry::kFunctionFlag_NoWait);

		// Ini set via Categorie
		registry->RegisterFunction(new NativeFunction5<StaticFunctionTag, void, BSFixedString, BSFixedString, BSFixedString, BSFixedString, BSFixedString>("setIniCString", "FWUtility", FWUtility::setIniCString, registry));
		registry->SetFunctionFlags("FWUtility", "setIniCString", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction5<StaticFunctionTag, void, BSFixedString, BSFixedString, BSFixedString, BSFixedString, bool>("setIniCBool", "FWUtility", FWUtility::setIniCBool, registry));
		registry->SetFunctionFlags("FWUtility", "setIniCBool", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction5<StaticFunctionTag, void, BSFixedString, BSFixedString, BSFixedString, BSFixedString, SInt32>("setIniCInt", "FWUtility", FWUtility::setIniCInt, registry));
		registry->SetFunctionFlags("FWUtility", "setIniCInt", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction5<StaticFunctionTag, void, BSFixedString, BSFixedString, BSFixedString, BSFixedString, float>("setIniCFloat", "FWUtility", FWUtility::setIniCFloat, registry));
		registry->SetFunctionFlags("FWUtility", "setIniCFloat", VMClassRegistry::kFunctionFlag_NoWait);



		registry->RegisterFunction(new NativeFunction3<StaticFunctionTag, BSFixedString, BSFixedString, BSFixedString, BSFixedString>("getNextAutoFile", "FWUtility", FWUtility::getNextAutoFile, registry));
		registry->SetFunctionFlags("FWUtility", "getNextAutoFile", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, bool, BSFixedString>("FileExists", "FWUtility", FWUtility::FileExists, registry));
		registry->SetFunctionFlags("FWUtility", "FileExists", VMClassRegistry::kFunctionFlag_NoWait);


		registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, BSFixedString, SInt32, SInt32>("Hex", "FWUtility", FWUtility::Hex, registry));
		registry->SetFunctionFlags("FWUtility", "Hex", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("GetDirectoryHash", "FWUtility", FWUtility::GetDirectoryHash, registry));
		registry->SetFunctionFlags("FWUtility", "GetDirectoryHash", VMClassRegistry::kFunctionFlag_NoWait);




		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, TESForm*, BSFixedString>("GetFormFromString", "FWUtility", FWUtility::GetFormFromString, registry));
		registry->SetFunctionFlags("FWUtility", "GetFormFromString", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, BSFixedString, BSFixedString, bool>("GetModFromString", "FWUtility", FWUtility::GetModFromString, registry));
		registry->SetFunctionFlags("FWUtility", "GetModFromString", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, UInt32, BSFixedString>("GetFormIDFromString", "FWUtility", FWUtility::GetFormIDFromString, registry));
		registry->SetFunctionFlags("FWUtility", "GetFormIDFromString", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, TESForm*>("GetStringFromForm", "FWUtility", FWUtility::GetStringFromForm, registry));
		registry->SetFunctionFlags("FWUtility", "GetStringFromForm", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction2<StaticFunctionTag, BSFixedString, TESForm*, bool>("GetModFromForm", "FWUtility", FWUtility::GetModFromForm, registry));
		registry->SetFunctionFlags("FWUtility", "GetModFromForm", VMClassRegistry::kFunctionFlag_NoWait);

		return true;
	}

}
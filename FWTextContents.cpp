#include "FWTextContents.h"
#include "skse64/PapyrusNativeFunctions.h"
#include <fstream>
#include <codecvt>
#include <iostream>
#include <string>
#include <sstream>
#include <cstdint>
#include <windows.h>
#include <tchar.h>


namespace FWTextContents {

	static std::string language;
	static std::string FileName;
	static int errNo = 99;
	static int fileSize = 0;

	void IOReadTranslation(StaticFunctionTag* base, BSFixedString lng) {
		errNo = 1;
		std::wifstream fs;

		// Generating file name
		FileName = "Data/Interface/Translations/BeeingFemale_";
		FileName.append(lng.data);
		FileName.append(".txt");

		errNo = 2;

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
			errNo = 3;
		}
		catch (std::exception*) {
			language = "";
			errNo = 4;
			return;
		}
		if (fs.is_open()) {
			errNo = 5;
			// imbue the file stream
			fs.imbue(std::locale(fs.getloc(), new std::codecvt_utf16<wchar_t, 0xFEFF, std::little_endian>));
			errNo = 6;
			// Creating the converter
			std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> converter;
			errNo = 7;
			// read file into file_content
			std::wstring file_content;
			errNo = 8;
			fs.seekg(0, std::ios::end);
			errNo = 9;
			fileSize = fs.tellg();
			file_content.resize(fileSize);
			errNo = 10;
			fs.seekg(0, std::ios::beg); // Reset pos to 2
			errNo = 11;
			fs.read(&file_content[0], file_content.size());
			errNo = 12;
			fs.close();
			errNo = 13;
			errNo = 14;
			// Convert and return the contents
			language = converter.to_bytes(file_content.c_str());
			errNo = 15;
		}
		else
			errNo = 16;
	}

	BSFixedString getLangText(StaticFunctionTag* Base, BSFixedString VarName) {
		std::string find;
		find.append("$");
		find.append(VarName.data);
		find.append("\t");
		if (language.length() == 0)
			return "";

		int pos = language.find(find);
		if (pos != -1) {

			int posStart = pos + find.length();
			int posEnd1 = language.find("\r", posStart);
			int posEnd2 = language.find("\n", posStart);
			int posEnd = -1;
			if (posEnd1 > -1 && posEnd1 < posEnd2)
				posEnd = posEnd1;
			else if (posEnd2 > -1 && posEnd2 < posEnd1)
				posEnd = posEnd2;
			if (posEnd == -1)
				posEnd = language.length();
			int len = posEnd - posStart;
			return BSFixedString(language.substr(posStart, len).c_str());
		}
		return "";
	}


	UInt32 getLangSize(StaticFunctionTag* base) {
		return language.size();
	}

	UInt32 getErrorCode(StaticFunctionTag* base) {
		return errNo;
	}

	BSFixedString getFilePath(StaticFunctionTag* base) {
		return BSFixedString(FileName.c_str());
	}

	bool RegisterFuncs(VMClassRegistry* registry) {
		//_MESSAGE("registering functions");

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, void, BSFixedString>("IOReadTranslation", "FWTextContents", FWTextContents::IOReadTranslation, registry));
		registry->SetFunctionFlags("FWTextContents", "IOReadTranslation", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, BSFixedString, BSFixedString>("getLangText", "FWTextContents", FWTextContents::getLangText, registry));
		registry->SetFunctionFlags("FWTextContents", "getLangText", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction0<StaticFunctionTag, UInt32>("getLangSize", "FWTextContents", FWTextContents::getLangSize, registry));
		registry->SetFunctionFlags("FWTextContents", "getLangSize", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction0<StaticFunctionTag, BSFixedString>("getFilePath", "FWTextContents", FWTextContents::getFilePath, registry));
		registry->SetFunctionFlags("FWTextContents", "getFilePath", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction0<StaticFunctionTag, UInt32>("getErrorCode", "FWTextContents", FWTextContents::getErrorCode, registry));
		registry->SetFunctionFlags("FWTextContents", "getErrorCode", VMClassRegistry::kFunctionFlag_NoWait);

		return true;
	}
}
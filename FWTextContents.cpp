#include "FWTextContents.h"
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
static std::streamoff fileSize = 0;

void IOReadTranslation(StaticFunctionTag* /*base*/, BSFixedString lng) {
		errNo = 1;
		std::wifstream fs;

		// Generating file name
		FileName = "Data/Interface/Translations/BeeingFemale_";
		FileName.append(lng.data());
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
		if (fileSize > 0) {
			file_content.resize(static_cast<std::size_t>(fileSize));
		}
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

BSFixedString getLangText(StaticFunctionTag* /*Base*/, BSFixedString VarName) {
		std::string find;
		find.append("$");
		find.append(VarName.data());
		find.append("\t");
		if (language.length() == 0)
			return "";

	auto pos = language.find(find);
	if (pos != std::string::npos) {
		auto posStart = pos + find.length();
		auto posEnd1 = language.find("\r", posStart);
		auto posEnd2 = language.find("\n", posStart);
		auto posEnd = std::string::npos;
		if (posEnd1 != std::string::npos && (posEnd1 < posEnd2 || posEnd2 == std::string::npos))
			posEnd = posEnd1;
		else if (posEnd2 != std::string::npos)
			posEnd = posEnd2;
		if (posEnd == std::string::npos)
			posEnd = language.length();
		auto len = posEnd - posStart;
		return BSFixedString(language.substr(posStart, len).c_str());
	}
	return "";
}


UInt32 getLangSize(StaticFunctionTag* /*base*/) {
	return static_cast<UInt32>(language.size());
}

UInt32 getErrorCode(StaticFunctionTag* /*base*/) {
	return errNo;
}

BSFixedString getFilePath(StaticFunctionTag* /*base*/) {
	return BSFixedString(FileName.c_str());
}

	bool RegisterFuncs(VMClassRegistry* registry) {
		//_MESSAGE("registering functions");

	registry->RegisterFunction("IOReadTranslation", "FWTextContents", &FWTextContents::IOReadTranslation);
	registry->RegisterFunction("getLangText", "FWTextContents", &FWTextContents::getLangText);
	registry->RegisterFunction("getLangSize", "FWTextContents", &FWTextContents::getLangSize);
	registry->RegisterFunction("getFilePath", "FWTextContents", &FWTextContents::getFilePath);
	registry->RegisterFunction("getErrorCode", "FWTextContents", &FWTextContents::getErrorCode);

		return true;
	}
}



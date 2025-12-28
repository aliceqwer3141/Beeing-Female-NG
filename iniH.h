#pragma once

#include "CommonLibCompat.h"

#include <algorithm>
#include <cctype>
#include <codecvt>
#include <fstream>
#include <functional>
#include <locale>
#include <string>
#include <sys/stat.h>

namespace iniH {

	BSFixedString getIniString(std::string file, std::string var);
	UInt32 getIniUInt32(std::string file, std::string var);

	UInt32 FromHex(std::string hex);
	std::string getIniData(std::string file, std::string var);
	// trim from start
	inline std::string& ltrim(std::string& s);
	// trim from end
	inline std::string& rtrim(std::string& s);
	// trim from both ends
	inline std::string& trim(std::string& s);

}

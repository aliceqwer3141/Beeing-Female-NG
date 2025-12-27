#include <fstream>
#include <string>
#include <codecvt>
#include <sys/stat.h>
#include <algorithm> 
#include <functional> 
#include <cctype>
#include <locale>
#include "skse64/GameData.h"

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
#include <sstream>
#include <iostream>
#include <fstream>
#include <string>
#include <codecvt>
#include <sys/stat.h>
#include <algorithm> 
#include <functional> 
#include <cctype>
#include <locale>
#include "skse64/GameData.h"
#include "iniH.h"

namespace iniH {

	BSFixedString getIniString(std::string file, std::string var) {
		return BSFixedString(getIniData(file, var).c_str());
	}

	UInt32 getIniUInt32(std::string file, std::string var) {
		std::string tmp = getIniData(file, var);
		if (tmp.substr(0, 1) == "#")
			return FromHex(tmp.substr(1));
		else if (tmp.substr(0, 2) == "0x")
			return FromHex(tmp.substr(2));
		else
			return atoi(tmp.c_str());
	}

	UInt32 FromHex(std::string hexString) {
		UInt32 x;
		std::stringstream ss;
		ss << std::hex << hexString;
		ss >> x;
		return x;
	}

	std::string getIniData(std::string file, std::string var) {
		std::wifstream fs;
		try {
			// Try to open
			fs.open(file, std::ios::binary);
		}
		catch (std::exception*) {
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

			// Convert and return the contents
			std::string res = converter.to_bytes(file_content.c_str());
			int resl = res.length();
			int pos = 0;
			while (pos >= 0) {
				// Check if it's at a line beginning
				if (pos == 0 || res.substr(pos - 1, 1) == "\r" || res.substr(pos - 1, 1) == "\n") {
					// Check if it's not only the same beginning
					pos += var.length();
					if (pos < resl - 2) {
						if (res.substr(pos, 1) == "\t" || res.substr(pos + var.length()) == " ") {
							// Skip whitechars till ':'
							while ((res.substr(pos, 1) == "\t" || res.substr(pos, 1) == " ") && pos < resl - 2)
								pos++;
						}
						if (res.substr(pos, 1) == "=") {
							pos++;
							// Found! now get the rest of the line
							std::string tmp = "";
							while (pos < resl || res.substr(pos, 1) == "\r" || res.substr(pos, 1) == "\n")
								tmp.append(res.substr(pos, 1));
							return trim(tmp);
						}
					}
				}
				pos = res.find(var);
			}
			return res.c_str();
		}
		else {
			return "";
		}
	}

	// trim from start
	inline std::string& ltrim(std::string& s) {
		s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](int c) {return !std::isspace(c); }));
		return s;
	}

	// trim from end
	inline std::string& rtrim(std::string& s) {
		s.erase(std::find_if(s.rbegin(), s.rend(), [](int c) {return !std::isspace(c); }).base(), s.end());
		return s;
	}

	// trim from both ends
	inline std::string& trim(std::string& s) {
		return ltrim(rtrim(s));
	}

}
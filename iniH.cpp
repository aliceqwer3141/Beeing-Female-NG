#include "iniH.h"

#include <iostream>
#include <sstream>

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
			return "";
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
			const auto resl = res.size();
			auto pos = res.find(var);
			while (pos != std::string::npos) {
				// Check if it's at a line beginning
				if (pos == 0 || res[pos - 1] == '\r' || res[pos - 1] == '\n') {
					auto cur = pos + var.length();
					if (cur < resl) {
						// Skip whitespace before '='
						while (cur < resl && (res[cur] == '\t' || res[cur] == ' '))
							++cur;
						if (cur < resl && res[cur] == '=') {
							++cur;
							// Found! now get the rest of the line
							std::string tmp;
							while (cur < resl && res[cur] != '\r' && res[cur] != '\n') {
								tmp.push_back(res[cur]);
								++cur;
							}
							return trim(tmp);
						}
					}
				}
				pos = res.find(var, pos + 1);
			}
			return res;
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

#include "inisetting.h"
#include <sstream>

template <> short GetPrivateProfile(const char* clsnm, const char* rcrdnm, short def, const char* ini)
{
	const UINT value = GetPrivateProfileInt(clsnm, rcrdnm, def, ini);
	return static_cast<short>(value);
}

template <> unsigned GetPrivateProfile(const char* clsnm, const char* rcrdnm, unsigned def, const char* ini)
{
	return GetPrivateProfileInt(clsnm, rcrdnm, def, ini);
}

template <> int GetPrivateProfile(const char* clsnm, const char* rcrdnm, int def, const char* ini)
{
	return GetPrivateProfileInt(clsnm, rcrdnm, def, ini);
}

template <> double GetPrivateProfile(const char* clsnm, const char* rcrdnm, double def, const char* ini)
{
	std::ostringstream strs;
	strs << def;
	//std::string str = strs.str();
	const char* str = strs.str().c_str();
	char buf[20];
	GetPrivateProfileString(clsnm, rcrdnm, str, buf, 20, ini);
	return atof(buf);
}

template <> float GetPrivateProfile(const char* clsnm, const char* rcrdnm, float def, const char* ini)
{
	return static_cast<float>(GetPrivateProfile<double>(clsnm, rcrdnm, def, ini));
}

/*template <> bool GetPrivateProfile(const char* clsnm, const char* rcrdnm, bool def, const char* ini)
{
	char buf[20];
	GetPrivateProfileString(clsnm, rcrdnm, std::to_string(def).c_str(), buf, 20, ini);
	std::string str = buf;
	for(auto& i : str)
		i = tolower(i);

	return str=="y"||str=="Y"||str=="1"||str=="true"||str=="TRUE"||str=="True"||str=="Yes"||str=="yes"||str=="YES";
}*/

template <> std::string GetPrivateProfile(const char* clsnm, const char* rcrdnm, std::string def, const char* ini)
{
	char buf[500];
	GetPrivateProfileString(clsnm, rcrdnm, def.c_str(), buf, 500, ini);
	return buf;
}

template <> long long GetPrivateProfile(const char* clsnm, const char* rcrdnm, long long def, const char* ini)
{
	char buf[500];
	GetPrivateProfileString(clsnm, rcrdnm, std::to_string(def).c_str(), buf, 500, ini);
	return _atoi64(buf);
}

template<> void WritePrivateProfile(const char* clsnm, const char* rcrdnm, const char* const& val, const char* ini)
{
	WritePrivateProfileString(clsnm, rcrdnm, val, ini);
}

template<> void WritePrivateProfile(const char* clsnm, const char* rcrdnm, const std::string& val, const char* ini)
{
	WritePrivateProfileString(clsnm, rcrdnm, val.c_str(), ini);
}

template<> void WritePrivateProfile(const char* clsnm, const char* rcrdnm, const bool& val, const char* ini)
{
	WritePrivateProfileString(clsnm, rcrdnm, val ? "true" : "false", ini);
}

template<> void WritePrivateProfile(const char* clsnm, const char* rcrdnm, const std::int32_t& val, const char* ini) {
	char wert[8];
	//itoa(val, wert, 10); // Dezimal
	_itoa_s(val, wert, 16); // Hex
	WritePrivateProfileString(clsnm, rcrdnm, wert, ini);
}

template<> void WritePrivateProfile(const char* clsnm, const char* rcrdnm, const float& val, const char* ini) {
	char wert[_CVTBUFSIZE];
	//_gcvt(val, 4, wert);
	_gcvt_s(wert, _CVTBUFSIZE, val, 10);
	WritePrivateProfileString(clsnm, rcrdnm, wert, ini);
}

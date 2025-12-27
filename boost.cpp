#include "boost.h"

#include <algorithm>
#include <cctype>
#include <string>
#include <vector>
#include <sstream>

void to_lower(std::string& s) {
    std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c) { return std::tolower(c); });
}

void to_upper(std::string& s) {
    std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c) { return std::toupper(c); });
}

bool is_any_of(char c, const std::string& delimiters) {
    return std::find(delimiters.begin(), delimiters.end(), c) != delimiters.end();
}

std::vector<std::string> split(const std::string& s, const std::string& delimiters) {
    std::vector<std::string> tokens;
    std::string token;
    std::stringstream ss(s);

    // Проходим по каждому символу строки
    while (std::getline(ss, token, delimiters[0])) {
        tokens.push_back(token);
    }

    return tokens;
}
#include <string>
#include <vector>

void to_lower(std::string& s);
void to_upper(std::string& s);
bool is_any_of(char c, const std::string& delimiters);
std::vector<std::string> split(const std::string& s, const std::string& delimiters);
#include "Options.hxx"

using namespace srclang;

Options::Options(std::map<std::string, OptionType> const &options)
    : std::map<std::string, OptionType>(options) {
}

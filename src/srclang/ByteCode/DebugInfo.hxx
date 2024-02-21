#ifndef SRCLANG_DEBUGINFO_HXX
#define SRCLANG_DEBUGINFO_HXX

#include <iostream>
#include <string>
#include <vector>

namespace srclang {

    struct DebugInfo {
        std::string filename;
        std::vector<int> lines;
        int position{};
    };

}  // srclang

#endif  // SRCLANG_DEBUGINFO_HXX

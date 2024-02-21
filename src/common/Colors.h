#ifndef _PKGUPD_COLOR_HH_
#define _PKGUPD_COLOR_HH_

#include <iostream>

#define RESET "\033[0m"
#define COLOR(code, mesg) "\033[" #code ";1m" << mesg << RESET
#define RED(mesg) COLOR(31, mesg)
#define GREEN(mesg) COLOR(32, mesg)
#define YELLOW(mesg) COLOR(33, mesg)
#define BLUE(mesg) COLOR(34, mesg)
#define BOLD(mesg) COLOR(49, mesg)

#define MESSAGE(header, mesg)                                                  \
    if (getenv("PKGUPD_NO_MESSAGE") == nullptr)                                \
        std::cout << header << BOLD(" ") << BOLD(mesg) << std::endl;

#define ERROR(mesg) MESSAGE(RED("ERROR"), mesg)
#define PROCESS(mesg) MESSAGE(GREEN("::"), mesg << "...")
#define INFO(mesg) MESSAGE(BLUE("::"), mesg)

#define DEBUG(mesg)                                                            \
    if (getenv("PKGUPD_NO_MESSAGE") == nullptr)                                \
        std::cout << "\033[2m     " << mesg << RESET << std::endl;

#endif
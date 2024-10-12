add_executable(compositor
    main.c)

find_package(PkgConfig REQUIRED)

pkg_search_module(WLROOTS REQUIRED IMPORTED_TARGET wlroots-0.18)
pkg_search_module(WAYLAND_SERVER REQUIRED IMPORTED_TARGET wayland-server)
pkg_search_module(XKBCOMMON REQUIRED IMPORTED_TARGET xkbcommon)
pkg_search_module(LIBINPUT REQUIRED IMPORTED_TARGET libinput)

pkg_get_variable(WAYLAND_SCANNER wayland-scanner wayland_scanner)
pkg_get_variable(WAYLAND_PROTOCOLS wayland-protocols pkgdatadir)

set(PROTOCOL_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})

function(add_wayland_protocol target kind id)
    get_filename_component(FILENAME ${id} NAME_WE)
    add_custom_command(
        OUTPUT ${PROTOCOL_OUTPUT_PATH}/${FILENAME}-protocol.h
        COMMAND ${WAYLAND_SCANNER} ${kind} ${WAYLAND_PROTOCOLS}/${id}.xml ${PROTOCOL_OUTPUT_PATH}/${FILENAME}-protocol.h
    )
    target_sources(${target} PRIVATE
        ${PROTOCOL_OUTPUT_PATH}/${FILENAME}-protocol.h)
endfunction()
target_include_directories(compositor PRIVATE ${PROTOCOL_OUTPUT_PATH})

add_wayland_protocol(compositor server-header stable/xdg-shell/xdg-shell)

target_compile_definitions(compositor PRIVATE 
    -DWLR_USE_UNSTABLE)

target_link_libraries(compositor
    PkgConfig::WLROOTS
    PkgConfig::WAYLAND_SERVER
    PkgConfig::XKBCOMMON
    PkgConfig::LIBINPUT
)

install(TARGETS compositor
    RUNTIME DESTINATION bin)
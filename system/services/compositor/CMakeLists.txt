add_executable(compositor
    main.cpp)

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

function(add_wayland_local_protocol target kind id)
    get_filename_component(FILENAME ${id} NAME_WE)
    add_custom_command(
        OUTPUT ${PROTOCOL_OUTPUT_PATH}/${FILENAME}-protocol.h
        COMMAND ${WAYLAND_SCANNER} ${kind} ${CMAKE_CURRENT_SOURCE_DIR}/protocols/${id}.xml ${PROTOCOL_OUTPUT_PATH}/${FILENAME}-protocol.h
    )
    target_sources(${target} PRIVATE
        ${PROTOCOL_OUTPUT_PATH}/${FILENAME}-protocol.h)
endfunction()

target_include_directories(compositor PRIVATE ${PROTOCOL_OUTPUT_PATH})

add_wayland_protocol(compositor server-header stable/xdg-shell/xdg-shell)
add_wayland_protocol(compositor enum-header   staging/cursor-shape/cursor-shape-v1)
add_wayland_protocol(compositor enum-header   unstable/pointer-constraints/pointer-constraints-unstable-v1)

add_wayland_local_protocol(compositor enum-header   wlr-layer-shell-unstable-v1)
add_wayland_local_protocol(compositor server-header   wlr-output-power-management-unstable-v1)


target_compile_definitions(compositor PRIVATE 
    -DWLR_USE_UNSTABLE)

target_compile_options(compositor PRIVATE
    -fpermissive)

target_link_libraries(compositor
    PkgConfig::WLROOTS
    PkgConfig::WAYLAND_SERVER
    PkgConfig::XKBCOMMON
    PkgConfig::LIBINPUT
    -lm
)

install(TARGETS compositor
    RUNTIME DESTINATION bin)
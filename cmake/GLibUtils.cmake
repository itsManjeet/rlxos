macro(compile_resources GRESOURCE_FILE OUTPUT)
    find_program(GLIB_RESOURCE_COMPILER NAMES glib-compile-resources REQUIRED)
    get_filename_component(WORK_DIR ${GRESOURCE_FILE} DIRECTORY)

    if (${ARGC} GREATER 1)
        foreach (arg IN ITEMS ${ARGN})
            string(CONCAT RESOURCE ${WORK_DIR}/ ${arg})
            list(APPEND RESOURCES ${RESOURCE})
        endforeach ()
    endif ()

    add_custom_command(
            OUTPUT ${OUTPUT}
            WORKING_DIRECTORY ${WORK_DIR}
            COMMAND ${GLIB_RESOURCE_COMPILER} --target=${OUTPUT} --generate-source ${GRESOURCE_FILE}
            DEPENDS ${GRESOURCE_FILE} ${RESOURCES}
            COMMENT "Generating ${OUTPUT}..."
    )
endmacro()

macro(compile_schemas GSCHEMA_XML)
    find_program(GLIB_SCHEMA_COMPILER NAMES glib-compile-schemas REQUIRED)

    set(WORK_DIR ${PROJECT_SOURCE_DIR}/data)

    if (${ARGC} GREATER 1)
        foreach (arg IN ITEMS ${ARGN})
            string(CONCAT SCHEMA ${WORK_DIR} ${arg})
            list(APPEND SCHEMAS ${SCHEMA})
        endforeach ()
    endif ()

    set(OUTPUT_DIR ${PROJECT_BINARY_DIR}/generated/data)
    set(OUTPUT ${OUTPUT_DIR}/gschemas.compiled)
    add_custom_command(
            OUTPUT ${OUTPUT}
            WORKING_DIRECTORY ${WORK_DIR}
            COMMAND mkdir -p ${OUTPUT_DIR}
            COMMAND ${GLIB_SCHEMA_COMPILER} --strict --dry-run --schema-file=${GSCHEMA_XML}
            COMMAND ${GLIB_SCHEMA_COMPILER} --schema-file=${GSCHEMA_XML} --targetdir=${OUTPUT_DIR}
            DEPENDS ${GSCHEMA_XML} ${SCHEMAS}
            COMMENT "Generating ${OUTPUT}..."
    )
    add_custom_target(gschemas.compiled ALL DEPENDS ${OUTPUT})
endmacro()
#ifndef PKGUPD_ARCHIVE_MANAGER_HXX
#define PKGUPD_ARCHIVE_MANAGER_HXX

#include "MetaInfo.h"

/**
 * This class represent rlxos compressed Package,
 * @brief It provides various methods to handle, read, compress and extract
 * rlxos packages
 */
class ArchiveManager {
public:
    /**
     * @brief Provides the file data of specified file in the package
     * @param filepath path to the file in Package (must be started from ./)
     * @return content of file
     */
    static void get(const std::filesystem::path& filepath,
            const std::string& input_path, std::string& output);

    static void extract(const std::filesystem::path& filepath,
            const std::string& input_path,
            const std::filesystem::path& output_path);

    static MetaInfo info(const std::filesystem::path& filepath);

    /**
     * List all files in the archive
     */
    static void list(
            const std::filesystem::path& filepath, std::vector<std::string>&);

    static void extract(const std::filesystem::path& filepath,
            const std::string& input_path,
            std::vector<std::string>& files_list);

    static void compress(const std::filesystem::path& filepath,
            const std::string& input_path);

    static bool is_archive(const std::filesystem::path& filepath);
};

#endif

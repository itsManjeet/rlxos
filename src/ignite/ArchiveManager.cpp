#include "ArchiveManager.h"

#include "Executor.h"
#include <fstream>

void ArchiveManager::get(const std::filesystem::path& filepath,
        const std::string& input_path, std::string& output) {
    auto [status, out] = Executor("/bin/tar")
                                 .arg("--zstd")
                                 .arg("-O")
                                 .arg("-xPf")
                                 .arg(filepath)
                                 .arg(input_path)
                                 .output();
    if (status != 0) {
        throw std::runtime_error(
                "failed to get_available data from " + filepath.string());
    }
    output = std::move(out);
}

void ArchiveManager::extract(const std::filesystem::path& filepath,
        const std::string& input_path,
        const std::filesystem::path& output_path) {
    std::ofstream writer(output_path);
    int status = Executor("/bin/tar")
                         .arg("--zstd")
                         .arg("-O")
                         .arg("-xPf")
                         .arg(filepath)
                         .arg(input_path)
                         .start()
                         .wait(&writer);
    if (status != 0) {
        throw std::runtime_error(
                "failed to get_available data from " + filepath.string());
    }
}

MetaInfo ArchiveManager::info(const std::filesystem::path& input_path) {
    std::string content;
    get(input_path, "./info", content);

    return MetaInfo::from_data(content);
}

void ArchiveManager::list(const std::filesystem::path& filepath,
        std::vector<std::string>& files) {
    std::stringstream output;
    int status = Executor("/usr/bin/tar")
                         .arg("--zstd")
                         .arg("-tf")
                         .arg(filepath)
                         .start()
                         .wait(&output);
    if (status != 0) {
        throw std::runtime_error("failed to list file from archive " +
                                 filepath.string() + ": " + output.str());
    }

    std::stringstream ss(output.str());
    std::string file;

    while (std::getline(ss, file, '\n')) { files.push_back(file); }
}

void ArchiveManager::extract(const std::filesystem::path& filepath,
        const std::string& output_path, std::vector<std::string>& files_list) {
    std::stringstream output;
    if (!std::filesystem::exists(output_path)) {
        std::error_code code;
        std::filesystem::create_directories(output_path, code);
        if (code) {
            throw std::runtime_error("failed to create required directory '" +
                                     output_path + "': " + code.message());
        }
    }

    auto exe = "/bin/tar";
    if (filepath.has_extension() && filepath.extension() == ".zip") {
        exe = "/bin/bsdtar";
    }

    int status = Executor(exe)
                         .arg("-xvPf")
                         .arg(filepath)
                         .arg("-C")
                         .arg(output_path)
                         .start()
                         .wait(&output);

    std::stringstream ss(output.str());
    for (std::string f; std::getline(ss, f);) {
        if (f.starts_with("./")) f = f.substr(2);
        if (f.starts_with("x ")) f = f.substr(2);
        if (f.empty()) continue;
        files_list.emplace_back(f);
    }
    DEBUG("EXTRACTED: " << files_list.size() << " file(s)");

    if (status != 0) {
        throw std::runtime_error(
                "failed to extract " + filepath.string() + " :" + output.str());
    }
}

void ArchiveManager::compress(
        const std::filesystem::path& filepath, const std::string& input_path) {
    auto [status, output] = Executor("/bin/tar")
                                    .arg("--zstd")
                                    .arg("-cPf")
                                    .arg(filepath)
                                    .arg("-C")
                                    .arg(input_path)
                                    .arg(".")
                                    .output();
    if (status != 0) {
        throw std::runtime_error(
                "failed to execute command for compression: " + output);
    }
}

bool ArchiveManager::is_archive(const std::filesystem::path& filepath) {
    for (auto const& ext : {".tar", ".zip", ".gz", ".xz", ".bzip2", ".tgz",
                 ".txz", ".bz2", ".zst", ".zstd", ".lz"}) {
        if (filepath.has_extension() && filepath.extension() == ext) {
            return true;
        }
    }
    return false;
}

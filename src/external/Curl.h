#ifndef _DOWNLOADER_HH_
#define _DOWNLOADER_HH_

#include "json.h"
#include <curl/curl.h>
#include <format>
#include <fstream>
#include <utility>

struct Curl {
    CURL *backend{nullptr};

    Curl() {
        backend = curl_easy_init();
        if (!backend) throw std::runtime_error("failed to init curl");
        curl_easy_setopt(backend, CURLOPT_FOLLOWLOCATION, 1L);
    }

    ~Curl() {
        if (backend) curl_easy_cleanup(backend);
    }

    Curl &url(const std::string &u) {
        curl_easy_setopt(backend, CURLOPT_URL, u.c_str());
        return *this;
    }

    nlohmann::json get() {
        std::stringstream ss;
        perform(&ss);

        return nlohmann::json::parse(ss.str());
    }

    void download(const std::filesystem::path &filepath) {
        if (filepath.has_parent_path() && !std::filesystem::exists(filepath.parent_path())) {
            std::filesystem::create_directories(filepath.parent_path());
        }

        auto tempfile = filepath.string() + ".tmp";
        std::ofstream writer(tempfile, std::ios_base::binary);

        curl_easy_setopt(backend, CURLOPT_NOPROGRESS, 0L);
        curl_easy_setopt(backend, CURLOPT_XFERINFOFUNCTION, progress_func);
        perform(&writer);
        std::filesystem::rename(tempfile, filepath);
    }

private:

    static int progress_func(void *client, curl_off_t dltotal, curl_off_t dlnow, curl_off_t ultotal, curl_off_t ulnow) {
        if (dltotal <= 0) return 0;
        if (getenv("NO_PROGRESS")) return 0;
        printf("\rPROGRESS: %f%%", ((float) dlnow / (float) dltotal) * 100.0f);
        fflush(stdout);
        return 0;
    }

    void perform(std::ostream *os) {
        curl_easy_setopt(backend, CURLOPT_WRITEDATA, reinterpret_cast<void *>(os));
        curl_easy_setopt(backend, CURLOPT_WRITEFUNCTION,
                         +[](void *data, size_t size, size_t nmemb, void *user_data) -> size_t {
                             auto os = reinterpret_cast<std::ostream *>(user_data);
                             os->write(reinterpret_cast<const char *>(data), size * nmemb);
                             return size * nmemb;
                         });

        auto res = curl_easy_perform(backend);
        printf("\rSUCCESS\n");
        if (res != CURLE_OK) {
            throw std::runtime_error("curl::perform() failed: CURLE_OK != " + std::to_string(res));
        }
        long http_code = 0;
        curl_easy_getinfo(backend, CURLINFO_RESPONSE_CODE, &http_code);
        if (http_code != 200) {
            throw std::runtime_error("curl::perform() failed: 200 != " + std::to_string(http_code));
        }
    }
};

#endif

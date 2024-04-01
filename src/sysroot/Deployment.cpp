#include "Deployment.h"

#include "Error.h"
#include <filesystem>
#include <memory>
#include <optional>

std::string origin_get_string(GKeyFile* origin, const std::string& group,
        const std::string& key,
        const std::optional<std::string>& fallback = {}) {
    GError* error = nullptr;
    const char* value =
            g_key_file_get_string(origin, group.c_str(), key.c_str(), &error);
    if (value == nullptr) {
        if (fallback)
            return *fallback;
        else
            throw Error(error);
    }
    return value;
}

std::vector<std::string> origin_get_string_list(
        GKeyFile* origin, const std::string& group, const std::string& key) {
    GError* error = nullptr;
    gsize size;
    auto value = g_key_file_get_string_list(
            origin, group.c_str(), key.c_str(), &size, &error);
    if (value == nullptr) { throw Error(error); }
    std::vector<std::string> list;
    for (int i = 0; i < size; i++) { list.emplace_back(value[i]); }
    g_free(value);

    return list;
}

bool origin_get_boolean(GKeyFile* origin, const std::string& group,
        const std::string& key, std::optional<bool> fallback = {}) {
    GError* error = nullptr;
    auto value =
            g_key_file_get_boolean(origin, group.c_str(), key.c_str(), &error);
    if (error != nullptr) {
        if (fallback)
            return *fallback;
        else
            throw Error(error);
    }
    return value;
}

void Deployment::parse(OstreeRepo* repo) {
    revision = ostree_deployment_get_csum(backend);

    GKeyFile* origin = ostree_deployment_get_origin(backend);
    if (origin == nullptr) { throw Error("no origin file found"); }

    refspec = origin_get_string(origin, "origin", "refspec");
    if (auto idx = refspec.find(':'); std::string::npos != idx) {
        refspec = refspec.substr(idx + 1);
    }

    if (refspec.ends_with("/local")) {
        GError* error;
        // fallback to stable if error
        channel = origin_get_string(origin, "rlxos", "channel", "stable");
        auto ext_id = origin_get_string_list(origin, "rlxos", "extensions");

        std::unique_ptr<GVariant, decltype(&g_variant_unref)> commit(
                nullptr, g_variant_unref);

        GVariant* result;
        ostree_repo_load_variant(repo, OSTREE_OBJECT_TYPE_COMMIT,
                revision.c_str(), &result, &error);
        commit.reset(result);

        std::unique_ptr<GVariantDict, decltype(&g_variant_dict_unref)>
                commit_metadata(g_variant_dict_new(g_variant_get_child_value(
                                        commit.get(), 0)),
                        g_variant_dict_unref);
        base_revision = get_revision(commit_metadata.get(), "core");
        for (auto const& ext : ext_id) {
            auto rev = get_revision(commit_metadata.get(), ext);
            extensions.emplace_back(ext, rev);
        }
    } else {
        channel = std::filesystem::path(refspec).filename();
        base_revision = revision;
    }
}

std::string Deployment::get_revision(
        GVariantDict* dict, const std::string& id) {
    std::unique_ptr<GVariant, decltype(&g_variant_unref)> value(
            g_variant_dict_lookup_value(dict, ("rlxos.revision." + id).c_str(),
                    G_VARIANT_TYPE_STRING),
            g_variant_unref);
    gsize size;
    if (value == nullptr) return "";
    return g_variant_get_string(value.get(), &size);
}
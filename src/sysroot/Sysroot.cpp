/*
 * Copyright (c) 2024 Manjeet Singh <itsmanjeet1998@gmail.com>.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "Sysroot.h"

#include "../common/Colors.h"
#include "Error.h"
#include <algorithm>
#include <filesystem>
#include <memory>
#include <sstream>

void progress_callback(OstreeAsyncProgress* progress, gpointer user_data);

Sysroot::Sysroot(bool use_namespace) {
    GError* error = nullptr;
    backend = ostree_sysroot_new_default();
    if (use_namespace) { ostree_sysroot_set_mount_namespace_in_use(backend); }

    if (!ostree_sysroot_load(backend, nullptr, &error)) { throw Error(error); }

    if (!ostree_sysroot_get_repo(backend, &repo, nullptr, &error)) {
        throw Error(error);
    }

    load_deployments();
}

Sysroot::~Sysroot() {
    ostree_sysroot_unload(backend);

    if (repo) g_object_unref(repo);
    repo = nullptr;

    // if (sysroot) g_object_unref(sysroot);
    // sysroot = nullptr;
}

void Sysroot::load_deployments() {
    deployments.clear();

    std::unique_ptr<OstreeDeployment, decltype(&g_object_unref)>
            booted_deployment(ostree_sysroot_get_booted_deployment(backend),
                    g_object_unref);

    if (booted_deployment == nullptr) {
        throw std::runtime_error("no booted deployment found");
    }

    std::unique_ptr<GPtrArray, void (*)(GPtrArray*)> deployment_list(
            ostree_sysroot_get_deployments(backend),
            +[](GPtrArray* array) -> void { g_ptr_array_free(array, true); });
    for (auto i = 0; i < deployment_list->len; i++) {
        deployments.emplace_back(
                reinterpret_cast<OstreeDeployment*>(deployment_list->pdata[i]),
                repo);

        if (ostree_deployment_equal(
                    deployments.back().backend, booted_deployment.get())) {
            deployments.back().is_active = true;
        }
    }
}

void Sysroot::install(const std::vector<std::string>& refs) {
    auto deployment = get_active();
    for (auto const& ref : refs) {
        if (std::find_if(deployment.extensions.begin(),
                    deployment.extensions.end(),
                    [&ref](const std::pair<std::string, std::string>& p)
                            -> bool { return p.first == ref; }) ==
                deployment.extensions.end()) {
            deployment.extensions.emplace_back(ref, "");
        }
    }

    apply_changes(deployment);
}

void Sysroot::uninstall(const std::vector<std::string>& refs) {
    auto deployment = get_active();
    for (auto const& ref : refs) {
        std::erase_if(deployment.extensions,
                [&ref](const std::pair<std::string, std::string>& p) -> bool {
                    return p.first == ref;
                });
    }

    apply_changes(deployment, false, true);
}

void Sysroot::switch_(const std::string& channel) {
    auto deployment = get_active();
    deployment.channel = channel;
    apply_changes(deployment, false, true);
}

std::optional<UpdateInfo> Sysroot::upgrade(bool dry_run) {
    return apply_changes(get_active(), dry_run);
}

static bool ends_with(std::string_view str, std::string_view suffix) {
    return str.size() >= suffix.size() &&
           str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

std::optional<UpdateInfo> Sysroot::pull(const Deployment& deployment,
        std::vector<std::string>& updated_revisions, bool dry_run,
        bool forced) {
    GError* error = nullptr;
    std::unique_ptr<OstreeAsyncProgress, decltype(&g_object_unref)> progress(
            ostree_async_progress_new_and_connect(progress_callback, this),
            g_object_unref);

    std::vector<std::string> revisions;
    auto merged_deployment =
            ostree_sysroot_get_merge_deployment(backend, OSNAME);

    std::vector<std::string> refs;
    if (deployment.refspec.ends_with("/local")) {
        refs.emplace_back("x86_64/os/" + deployment.channel);
        revisions.emplace_back(deployment.base_revision);
    } else {
        refs.emplace_back(deployment.refspec.c_str());
        revisions.emplace_back(deployment.revision);
    }
    for (auto const& [id, revision] : deployment.extensions) {
        refs.emplace_back("x86_64/extension/" + id + "/" + deployment.channel);
        revisions.emplace_back(revision);
    }

    std::vector<const char*> crefs;
    crefs.reserve(refs.size());
    for (auto const& i : refs) crefs.emplace_back(i.data());

    crefs.push_back(nullptr);

    if (!ostree_repo_pull(repo, OSNAME, (char**)(crefs.data()),
                (dry_run ? OSTREE_REPO_PULL_FLAGS_COMMIT_ONLY
                         : OSTREE_REPO_PULL_FLAGS_NONE),
                progress.get(), nullptr, &error)) {
        throw Error(error);
    }
    if (progress) {
        ostree_async_progress_finish(progress.get());
        std::cout << "\r" << std::endl;
    }

    auto updateInfo = UpdateInfo{};
    bool changed = false;
    int i = 0;
    for (const auto& refspec : refs) {
        auto [ref_changed, ref_revision, ref_changelog] =
                get_changelog("rlxos:" + refspec, revisions[i++]);
        updated_revisions.emplace_back(ref_revision);
        if (ref_changed) {
            updateInfo.changelog += ref_changelog + "\n";
            changed = true;
        }
    }

    if (!changed && !forced) { return std::nullopt; }
    if (dry_run) return updateInfo;

    std::string revision;
    std::unique_ptr<GKeyFile, decltype(&g_key_file_unref)> origin(
            nullptr, g_key_file_unref);

    gboolean resume = false;
    if (!ostree_repo_prepare_transaction(repo, &resume, nullptr, &error))
        throw Error(error);

    std::unique_ptr<OstreeMutableTree, decltype(&g_object_unref)> mutableTree(
            ostree_mutable_tree_new_from_commit(
                    repo, ("rlxos:" + refs[0]).c_str(), &error),
            g_object_unref);
    if (mutableTree == nullptr) throw Error(error);

    for (int i = 1; i < refs.size(); i++) {
        std::unique_ptr<GFile, decltype(&g_object_unref)> commit(
                nullptr, g_object_unref);
        GFile* res;
        gchar* file;
        if (!ostree_repo_read_commit(repo, ("rlxos:" + refs[i]).c_str(), &res,
                    &file, nullptr, &error)) {
            throw Error(error);
        }
        commit.reset(res);
        g_free(file);

        if (!ostree_repo_write_directory_to_mtree(repo, commit.get(),
                    mutableTree.get(), nullptr, nullptr, &error))
            throw Error(error);
    }
    GFile* res;
    if (!ostree_repo_write_mtree(
                repo, mutableTree.get(), &res, nullptr, &error))
        throw Error(error);
    std::unique_ptr<GFile, decltype(&g_object_unref)> root(res, g_object_unref);
    gchar* commit_checksum;
    std::unique_ptr<GVariantDict, decltype(&g_variant_dict_unref)> options(
            g_variant_dict_new(nullptr), g_variant_dict_unref);
    g_variant_dict_insert_value(options.get(), "rlxos.revision.core",
            g_variant_new_string(updated_revisions[0].c_str()));
    for (int i = 0; i < deployment.extensions.size(); i++) {
        g_variant_dict_insert_value(options.get(),
                ("rlxos.revision." + deployment.extensions[i].first).c_str(),
                g_variant_new_string(updated_revisions[i + 1].c_str()));
    }

    if (!ostree_repo_write_commit(repo, nullptr, nullptr, nullptr,
                g_variant_dict_end(options.get()), OSTREE_REPO_FILE(res),
                &commit_checksum, nullptr, &error)) {
        throw Error(error);
    }
    ostree_repo_transaction_set_ref(
            repo, nullptr, "x86_64/os/local", commit_checksum);
    OstreeRepoTransactionStats stats;
    if (!ostree_repo_commit_transaction(repo, &stats, nullptr, &error)) {
        throw Error(error);
    }

    if (ends_with(deployment.refspec, "/local")) {
        char* out_rev;
        if (!ostree_repo_resolve_rev(
                    repo, "x86_64/os/local", false, &out_rev, &error)) {
            throw Error(error);
        }
        revision = out_rev;
    } else {
        revision = updated_revisions[0];
    }

    origin.reset(
            ostree_sysroot_origin_new_from_refspec(backend, "x86_64/os/local"));
    g_key_file_set_boolean(origin.get(), "rlxos", "merged", true);

    std::vector<gchar*> ext_id;
    for (auto const& [id, _] : deployment.extensions) {
        ext_id.push_back((gchar*)id.c_str());
    }
    g_key_file_set_string_list(
            origin.get(), "rlxos", "extensions", ext_id.data(), ext_id.size());
    g_key_file_set_string(
            origin.get(), "rlxos", "channel", deployment.channel.c_str());

    std::unique_ptr<OstreeDeployment, decltype(&g_object_unref)> new_deployment(
            nullptr, g_object_unref);

    {
        OstreeDeployment* res;
        if (!ostree_sysroot_deploy_tree_with_options(backend, OSNAME,
                    revision.c_str(), origin.get(), deployment.backend, nullptr,
                    &res, nullptr, &error)) {
            ostree_sysroot_cleanup(backend, nullptr, nullptr);
            throw Error(error);
        }
        new_deployment.reset(res);

        if (!ostree_sysroot_simple_write_deployment(backend, OSNAME, res,
                    merged_deployment,
                    OSTREE_SYSROOT_SIMPLE_WRITE_DEPLOYMENT_FLAGS_NO_CLEAN,
                    nullptr, &error)) {
            ostree_sysroot_cleanup(backend, nullptr, nullptr);
            throw Error(error);
        }
    }

    ostree_sysroot_cleanup(backend, nullptr, nullptr);

    if (WEXITSTATUS(system("grub-mkconfig -o /boot/grub/grub.cfg")) != 0) {
        std::cerr << "ERROR: failed to update grub configuration" << std::endl;
    }

    return updateInfo;
}

std::tuple<bool, std::string, std::string> Sysroot::get_changelog(
        const std::string& refspec, const std::string& revision) {
    gchar* updated_revision = nullptr;
    GError* error = nullptr;
    if (!ostree_repo_resolve_rev(
                repo, refspec.c_str(), false, &updated_revision, &error)) {
        throw Error(error);
    }
    if (revision == updated_revision) { return {false, revision, ""}; }
    std::unique_ptr<GVariant, decltype(&g_variant_unref)> commit(
            nullptr, g_variant_unref);
    GVariant* result;
    if (!ostree_repo_load_variant(repo, OSTREE_OBJECT_TYPE_COMMIT,
                updated_revision, &result, &error)) {
        throw Error(error);
    }
    commit.reset(result);

    const gchar* subject;
    const gchar* body;
    guint64 timestamp;
    g_variant_get(commit.get(), "(a{sv}aya(say)&s&stayay)", nullptr, nullptr,
            nullptr, &subject, &body, &timestamp, nullptr, nullptr);

    return {true, updated_revision,
            refspec + ":" + updated_revision + " " + std::to_string(timestamp) +
                    "\n" + subject + "\n" + body};
}

Deployment Sysroot::get_active() const {
    auto deployment = std::find_if(deployments.begin(), deployments.end(),
            [](const Deployment& deployment) -> bool {
                return deployment.is_active;
            });
    if (deployment == deployments.end()) {
        throw std::runtime_error("no active deployments found");
    }
    return *deployment;
}

std::optional<UpdateInfo> Sysroot::apply_changes(
        const Deployment& deployment, bool dry_run, bool force) {
    PROCESS("Pulling changes");
    DEBUG("REFSPEC     : " << deployment.refspec)
    DEBUG("CHANNEL     : " << deployment.channel)
    std::stringstream ss;
    for (auto const& [i, _] : deployment.extensions) ss << " " << i;
    DEBUG("EXTENSIONS  :" << ss.str());
    std::vector<std::string> updated_revisions;
    auto changelog = pull(deployment, updated_revisions, dry_run, force);
    return changelog;
}

std::string Sysroot::version() const {
    auto deployment = get_active();
    if (!deployment.refspec.ends_with("/local")) { return deployment.revision; }
    return deployment.base_revision;
}

struct IterUserData {
    std::vector<std::string> refs;
    std::string channel;
};

std::vector<std::string> Sysroot::get_available() const {
    IterUserData data{
            .refs = {},
            .channel = get_active().channel,
    };
    g_autoptr(GHashTable) refs;
    GError* error = nullptr;
    if (!ostree_repo_remote_list_refs(repo, OSNAME, &refs, nullptr, &error)) {
        throw Error(error);
    }
    g_hash_table_foreach(
            refs,
            +[](gpointer k, gpointer v, gpointer user_data) {
                std::string ref = reinterpret_cast<char*>(k);
                //                auto value = reinterpret_cast<char*>(v);
                auto data = reinterpret_cast<IterUserData*>(user_data);
                if (ref.contains("/extension/") &&
                        ref.ends_with("/" + data->channel)) {
                    ref = std::filesystem::path(ref).parent_path().filename();
                    data->refs.emplace_back(ref);
                }
            },
            &data);
    return data.refs;
}

static char* formatted_time_remaining_from_seconds(guint64 seconds_remaining) {
    guint64 minutes_remaining = seconds_remaining / 60;
    guint64 hours_remaining = minutes_remaining / 60;
    guint64 days_remaining = hours_remaining / 24;

    GString* description = g_string_new(nullptr);

    if (days_remaining)
        g_string_append_printf(
                description, "%" G_GUINT64_FORMAT " days ", days_remaining);

    if (hours_remaining)
        g_string_append_printf(description, "%" G_GUINT64_FORMAT " hours ",
                hours_remaining % 24);

    if (minutes_remaining)
        g_string_append_printf(description, "%" G_GUINT64_FORMAT " minutes ",
                minutes_remaining % 60);

    g_string_append_printf(description, "%" G_GUINT64_FORMAT " seconds ",
            seconds_remaining % 60);

    return g_string_free(description, FALSE);
}

void progress_callback(OstreeAsyncProgress* progress, gpointer user_data) {
    auto self = reinterpret_cast<Sysroot*>(user_data);
    g_autofree char* status = NULL;
    gboolean caught_error, scanning;
    guint outstanding_fetches;
    guint outstanding_metadata_fetches;
    guint outstanding_writes;
    guint n_scanned_metadata;
    guint fetched_delta_parts;
    guint total_delta_parts;
    guint fetched_delta_part_fallbacks;
    guint total_delta_part_fallbacks;

    g_autoptr(GString) buf = g_string_new("");

    ostree_async_progress_get(progress, "outstanding-fetches", "u",
            &outstanding_fetches, "outstanding-metadata-fetches", "u",
            &outstanding_metadata_fetches, "outstanding-writes", "u",
            &outstanding_writes, "caught-error", "b", &caught_error, "scanning",
            "u", &scanning, "scanned-metadata", "u", &n_scanned_metadata,
            "fetched-delta-parts", "u", &fetched_delta_parts,
            "total-delta-parts", "u", &total_delta_parts,
            "fetched-delta-fallbacks", "u", &fetched_delta_part_fallbacks,
            "total-delta-fallbacks", "u", &total_delta_part_fallbacks, "status",
            "s", &status, NULL);

    if (*status != '\0') {
        g_string_append(buf, status);
    } else if (caught_error) {
        g_string_append_printf(
                buf, "Caught error, waiting for outstanding tasks");
    } else if (outstanding_fetches) {
        guint64 bytes_transferred, start_time, total_delta_part_size;
        guint fetched, metadata_fetched, requested;
        guint64 current_time = g_get_monotonic_time();
        g_autofree char* formatted_bytes_transferred = NULL;
        g_autofree char* formatted_bytes_sec = NULL;
        guint64 bytes_sec;

        /* Note: This is not atomic wrt the above getter call. */
        ostree_async_progress_get(progress, "bytes-transferred", "t",
                &bytes_transferred, "fetched", "u", &fetched,
                "metadata-fetched", "u", &metadata_fetched, "requested", "u",
                &requested, "start-time", "t", &start_time,
                "total-delta-part-size", "t", &total_delta_part_size, NULL);

        formatted_bytes_transferred =
                g_format_size_full(bytes_transferred, G_FORMAT_SIZE_DEFAULT);

        /* Ignore the first second, or when we haven't transferred any
         * data, since those could cause divide by zero below.
         */
        if ((current_time - start_time) < G_USEC_PER_SEC ||
                bytes_transferred == 0) {
            bytes_sec = 0;
            formatted_bytes_sec = g_strdup("-");
        } else {
            bytes_sec = bytes_transferred /
                        ((current_time - start_time) / G_USEC_PER_SEC);
            formatted_bytes_sec = g_format_size(bytes_sec);
        }

        /* Are we doing deltas?  If so, we can be more accurate */
        if (total_delta_parts > 0) {
            guint64 fetched_delta_part_size = ostree_async_progress_get_uint64(
                    progress, "fetched-delta-part-size");
            g_autofree char* formatted_fetched = NULL;
            g_autofree char* formatted_total = NULL;

            /* Here we merge together deltaparts + fallbacks to avoid bloating
             * the text UI */
            fetched_delta_parts += fetched_delta_part_fallbacks;
            total_delta_parts += total_delta_part_fallbacks;

            formatted_fetched = g_format_size(fetched_delta_part_size);
            formatted_total = g_format_size(total_delta_part_size);

            if (bytes_sec > 0) {
                guint64 est_time_remaining = 0;
                if (total_delta_part_size > fetched_delta_part_size)
                    est_time_remaining =
                            (total_delta_part_size - fetched_delta_part_size) /
                            bytes_sec;
                g_autofree char* formatted_est_time_remaining =
                        formatted_time_remaining_from_seconds(
                                est_time_remaining);
                /* No space between %s and remaining, since
                 * formatted_est_time_remaining has a trailing space */
                g_string_append_printf(buf,
                        "Receiving delta parts: %u/%u %s/%s %s/s %sremaining",
                        fetched_delta_parts, total_delta_parts,
                        formatted_fetched, formatted_total, formatted_bytes_sec,
                        formatted_est_time_remaining);
            } else {
                g_string_append_printf(buf,
                        "Receiving delta parts: %u/%u %s/%s",
                        fetched_delta_parts, total_delta_parts,
                        formatted_fetched, formatted_total);
            }
        } else if (scanning || outstanding_metadata_fetches) {
            g_string_append_printf(buf,
                    "Receiving metadata objects: %u/(estimating) %s/s %s",
                    metadata_fetched, formatted_bytes_sec,
                    formatted_bytes_transferred);
        } else {
            g_string_append_printf(buf,
                    "Receiving objects: %u%% (%u/%u) %s/s %s",
                    (guint)((((double)fetched) / requested) * 100), fetched,
                    requested, formatted_bytes_sec,
                    formatted_bytes_transferred);
        }
    } else if (outstanding_writes) {
        g_string_append_printf(buf, "Writing objects: %u", outstanding_writes);
    } else {
        g_string_append_printf(
                buf, "Scanning metadata: %u", n_scanned_metadata);
    }

    std::cout << "\r" << buf->str << std::flush;
}
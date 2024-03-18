#ifndef PKGUPD_DEPLOYMENT_H
#define PKGUPD_DEPLOYMENT_H

#include <ostree.h>
#include <string>
#include <vector>

struct Deployment {
    OstreeDeployment* backend{nullptr};
    std::string revision, refspec;
    std::string channel;
    std::string base_revision;
    bool is_active{false};
    std::vector<std::pair<std::string, std::string>> extensions;

    Deployment(OstreeDeployment* d, OstreeRepo* repo) : backend{d} {
        parse(repo);
    }

private:
    void parse(OstreeRepo* repo);

    static std::string get_revision(GVariantDict* dict, const std::string& id);
};

#endif
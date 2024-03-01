#ifndef _LIBPKGUPD_RESOLVEDEPENDS_HH_
#define _LIBPKGUPD_RESOLVEDEPENDS_HH_

#include "../defines.hxx"
#include <functional>
#include <optional>

template <typename Information> class Resolver {
public:
    std::map<std::string, bool> visited{};
    using GetPackageFunctionType =
            std::function<std::optional<Information>(const std::string& id)>;
    using SkipPackageFunctionType = std::function<bool(Information pkg)>;
    using PackageDependsFunctionType =
            std::function<std::vector<std::string>(Information pkg)>;

private:
    GetPackageFunctionType mGetPackageFunction;
    SkipPackageFunctionType mSkipPackageFunction;
    PackageDependsFunctionType mPackageDependsFunction;

    std::stringstream error;

    bool resolve(const std::string& id, std::vector<Information>& list) {
        visited[id] = true;
        auto meta_info = mGetPackageFunction(id);
        if (!meta_info) {
            error << "MISSING " << id;
            return false;
        }
        if (mSkipPackageFunction(*meta_info)) { return true; }

        for (auto dep : mPackageDependsFunction(*meta_info)) {
            if (dep.ends_with(".yml")) {
                dep = dep.substr(0, dep.length() - 4);
            }
            if (auto iter = visited.find(dep);
                    iter != visited.end() && iter->second) {
                continue;
            }

            if (!resolve(dep, list)) {
                error << "\n  TRACEBACK " << id;
                return false;
            }
        }

        list.emplace_back(*meta_info);
        return true;
    }

public:
    Resolver(GetPackageFunctionType get_fun, SkipPackageFunctionType skip_fun,
            PackageDependsFunctionType depends_func)
            : mGetPackageFunction{get_fun}, mSkipPackageFunction{skip_fun},
              mPackageDependsFunction{depends_func} {}

    void depends(const std::vector<std::string>& ids,
            std::vector<Information>& list) {
        for (auto const& id : ids) {
            if (!resolve(id, list)) {
                throw std::runtime_error("failed to resolve dependency for '" +
                                         id + "'\n" + traceback());
            }
        }
    }

    std::string traceback() const { return error.str(); }
};

#endif

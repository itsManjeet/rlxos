kind: meson

sources:
- kind: tar
  url: gnome_downloads:gi-docgen/2023/gi-docgen-2023.1.tar.xz
  ref: a9a687c1b7c4a4139a214bd451e01ca86131a3161f68aa3e07325b06002bbfb6
build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- components/gobject-introspection.bst

depends:
- freedesktop-sdk.bst:components/python3-jinja2.bst
- freedesktop-sdk.bst:components/python3-markdown.bst
- freedesktop-sdk.bst:components/python3-pygments.bst
- freedesktop-sdk.bst:components/python3-toml.bst
- components/python-typogrify.bst

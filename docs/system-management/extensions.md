# Ostree System (Secure)

If you are utilizing the Ostree-based system of rlxos, your dedicated tool for managing system updates is `updatectl`.


Channels following the pattern `<arch>/extensions/<id>/<channel>` are extensions.

### Adding Extensions

To include extensions on the base channel:

`updatectl update --include <arch>/extensions/<id>/<channel>`

Multiple extensions can be included simultaneously using the syntax: `--include <ext1> --include <ext2>`

To list available extensions:

`updatectl list`

### Removing Extensions

To remove already installed extensions:

`updatectl update --exclude <arch>/extensions/<id>/<channel>`

**Please note that a system restart is required to implement transactions.**

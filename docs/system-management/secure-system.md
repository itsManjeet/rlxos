# Ostree System (Secure)

If you are utilizing the Ostree-based system of rlxos, your dedicated tool for managing system updates is `updatectl`.

### Checking for Updates

Before applying updates, it is advisable to review the changelog. To check for updates using `updatectl`, execute the following command:

`updatectl update --dry-run`

### Applying Updates

You have the option to directly update the system or review the changelog before applying updates.

`updatectl update`

### Switching Update Channels

By default, you are provided with the stable channel, which releases updates once a month after ensuring the stability of changes.

To switch update channels, use:

`updatectl update --channel <arch>/os/<channel>`

Execute the following command to view all available channels:

`updatectl list --all`

1. Channels following the pattern `<arch>/os/<channel>` are base channels.
2. Channels following the pattern `<arch>/extensions/<id>/<channel>` are extensions.

### Adding Extensions

To include extensions on the base channel:

`updatectl update --include <arch>/extensions/<id>/<channel>`

Multiple extensions can be included simultaneously using the syntax: `--include <ext1> --include <ext2>`

To list available extensions:

`updatectl list`

### Removing Extensions

To remove already installed extensions:

`updatectl update --exclude <ext1> --exclude <ext2>`

**Please note that a system restart is required to implement transactions.**

### Checking System Status

To view the system version, available rollback version, and installed extensions:

`updatectl status`

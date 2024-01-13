# Updates

Updating the system is a critical task, and it is imperative to ensure that the system always remains in a functional state. rlxos provides dedicated tools to manage system updates and fallbacks.

If you are using the secure (ostree-based) version of rlxos, you can enjoy the following benefits:

1. **Atomic Updates:** Updates either complete successfully or fail without making any alterations to your system.
2. **Rollback Option:** You can always revert to a previous version of your system in case of faulty updates.
3. **Delta Transactions:** You will receive only the changes instead of the complete updated file or packages, unlike in traditional packaging systems.


### Checking for Updates

Before applying updates, it is advisable to review the changelog. To check for updates using `updatectl`, execute the following command:

`updatectl update --dry-run`

### Applying Updates

You have the option to directly update the system or review the changelog before applying updates.

`updatectl update`


### Checking System Status

To view the system version, available rollback version, and installed extensions:

`updatectl status`

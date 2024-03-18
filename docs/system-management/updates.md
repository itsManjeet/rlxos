# Updates

Updating the system is a crucial task, ensuring the system remains functional is paramount. RLXOS provides dedicated
tools for managing system updates and fallbacks.

## Sysroot

Sysroot is a command-line utility designed for managing your system's roots, updates, and extensions, similar to other
package managers but with the following features:

1. **Atomic Updates:** Updates either complete successfully or fail without making any partial alterations to your
   system.
2. **Rollback Option:** You can revert to a previous version of your system in case updates are faulty.
3. **Delta Transactions:** Instead of receiving complete updated files or packages, you will only get the changes,
   unlike traditional packaging systems.

### Checking for Updates

Before applying updates, it's advisable to review the changelog. Execute the following command:

`$ sudo sysroot update`

### System Status

The `sysroot` utility maintains two deployments (or versions) for better understanding:

1. **Active**: This is the current deployment (or version) that you are currently using.
2. **Inactive**: This represents either the previous or future deployment after any changes have been made.

### Switching Update Channels

RLXOS offers three update channels based on stability:

| Channel Name | Description                                                                                      | Release Cycle        |
|--------------|--------------------------------------------------------------------------------------------------|----------------------|
| `stable`     | (Default) This channel provides point releases after verifying stability on the preview channel. | Monthly to Quarterly |
| `preview`    | This channel offers monthly to weekly changes for the next major release for stability testing.  | Weekly to Monthly    |
| `unstable`   | This channel is used by distro developers to test their changes.                                 | Daily to Weekly      |

While it's recommended to stay on the `stable` channel, you can switch channels via `$ sysroot switch <channel>` and
reboot.
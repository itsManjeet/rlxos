# Updates

Updating the system is a critical task, and it is imperative to ensure that the system always remains in a functional state. rlxos provides dedicated tools to manage system updates and fallbacks.

If you are using the secure (ostree-based) version of rlxos, you can enjoy the following benefits:

1. **Atomic Updates:** Updates either complete successfully or fail without making any alterations to your system.
2. **Rollback Option:** You can always revert to a previous version of your system in case of faulty updates.
3. **Delta Transactions:** You will receive only the changes instead of the complete updated file or packages, unlike in traditional packaging systems.

However, if you are using the unlocked (pkgupd-based) version of rlxos, you might miss out on these benefits in exchange for increased customizability.

Follow the appropriate guide below according to your system version for applying updates.

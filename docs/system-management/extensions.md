# Extensions

Extensions are collections of components that layer up on the system roots to extend specific functionality of rlxos.
For example, You want to host a webserver you may need LAMP or LEMP which are not provided in default installation and
can't be installed manually as rlxos is immutable in nature. Or you want a different window manager or Development
tools. RLXOS provides a solution to handle these types of requirement with preconfigured collections called extension
that can be managed via [sysroot](updates.md).

## Extensions vs Traditional Linux Packages.

`Traditional Linux Packages` mostly provide binary files for a specific software while expect dependencies to
available or installed separately.

While `Extensions` are self-contained preconfigured collections of multiple softwares with
its dependencies that are not available on the Standard rlxos runtime.

## Manage Extensions via sysroot

`$ sudo sysroot list` will print all available extensions compatible for current deployment.

`$ sudo sysroot install <extension-id> ....` You can specify multiple extensions to install.

`$ sudo sysroot remove <extensions-id> ....` To remove installed extensions

**Please note that you need to reboot your system for every transaction to deploy changes**
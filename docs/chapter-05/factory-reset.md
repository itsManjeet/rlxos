# Factory reset

> Factory reset, also known as hard reset or master reset, is a software restore of an electronic device to its original system state by erasing all the information stored on the device. A keyboard input button factory reset is used to restore the device to its original manufacturer settings.

Factory reset will delete the **cache** layer and system with boot into the initial setup stage.

It is recommended to create a new profile (or **cache** layer) instead of deleting the previous one (that might contain data you need)


To Factory reset rlxos:
- Reboot the system and enter in GRUB bootloader.

- Press **'e'** to enter `EDIT` mode.

- Navigate with **↓** *bottom arrow key* to `linux` command-line arguments and add `reset` and `secure=<your-security-key>` at the end of it.

- Press `ctrl-x` to factory reset rlxos
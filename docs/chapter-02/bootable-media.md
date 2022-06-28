# Bootable media
> Bootable media is a CD, DVD, USB flash drive, or other removable media that enables you to run the agent without the help of an operating system.

Bootable media is required to configure rlxos into the hardware, So our first step is to prepare it. Method to prepare the bootable media depends on your current existing operating system. But before that we need the stable rlxos ISO ([download-rlxos](https://rlxos.dev/apps?search=rlxos))

# From GNU/Linux 
### or any Unix like system with dd tool

Its pretty simple in linux, just plug you usb and execute a command and wait for the success message.

```shell
    sudo dd bs=4M if=/path/to/rlxos.iso of=/dev/sdX status=progress oflag=sync
```

**replace `/path/to/rlxos.iso` with rlxos ISO path and `/dev/sdX` with your USB device node**

# From Windows

It is preferred to use *rufus* a simple opensource GUI tool to create bootable usb [download from here](https://rufus.ie/en/)

![rufus](https://rufus.ie/pics/rufus_en.png)

### Configuration

| Boot Mode | Partition Scheme | Target System | Mode |
| --------- | ---------------- | ------------- | ---- |
| Legacy    | MBR              | BIOS or UEFI  | ISO  |
| UEFI      | GPT              | UEFI          | DD   |
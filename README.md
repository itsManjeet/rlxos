<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]

<br />
<div align="center">
  <a href="https://github.com/itsmanjeet/rlxos">
    <img src="assets/icons/rlxos-logo.svg" alt="RLXOS Logo" width="80" height="80">
  </a>

<h3 align="center">RLXOS</h3>

  <p align="center">
    A minimal Linux-based operating system with a pure Go userland.
    <br />
    <a href="https://github.com/itsmanjeet/rlxos"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/itsmanjeet/rlxos">View Demo</a>
    ·
    <a href="https://github.com/itsmanjeet/rlxos/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/itsmanjeet/rlxos/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

---

## About The Project

![Screenshot][product-screenshot]

**RLXOS** is an experimental operating system built from scratch with a userland entirely written in Go, using
`CGO_ENABLED=0`. This means all user space components are statically compiled and do not rely on the C runtime.

### Why Go instead of C/C++?

* **Simplicity:** Go is known for its simplicity and clean, unbloated syntax.
* **Self-contained:** Go produces statically linked binaries that don’t rely on external C libraries like `libc`.
* **Productivity:** Go makes development fast and efficient with excellent package management, a rich standard library,
  and cross-compilation support.
* **Low-level control:** While not as granular as C/C++, Go offers enough control for low-level operations required
  here.
* **Fun:** No one has done this quite like this—so why not?

---

## Getting Started

### Prerequisites

Make sure you have the following installed:

* Go 1.22+
* QEMU
* GCC
* Make

Install required packages:

```sh
sudo apt install qemu-system-x86 gcc make systemd-boot ovmf genimage dosfstools mtools qemu-system-x86 libelf-dev flex bison bc libssl-dev rsync
```

### Installation

1. Clone the repository:

```sh
git clone https://github.com/itsmanjeet/rlxos.git
cd rlxos
```

Select a device from devices/

1. Build the OS:

```sh
make DEVICE=<DEVICE>
```

3. Run it using QEMU:

```sh
make DEVICE=<DEVICE> run
```

4. Start the debug shell:

```sh
go run rlxos.dev/tools/debug shell
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Usage

You will prompt with a minimal desktop environment with a top status bar and workspace.

| Shortcuts | Description                  |
|-----------|------------------------------|
| Alt+Enter | Open new Window              |
| Alt+s     | Switch focus between windows |
| Alt+q     | Close active Window          |

---

## Boot Process

* `/cmd/init` starts as PID 1 from the initramfs and prepares the actual root filesystem, then re-invokes itself from
  the real root as `/cmd/init`.
* `/cmd/init` launches `/cmd/service`, which is the service manager.
* The service manager starts `/services/display` and `/services/udevd` for display and uevent listening.
* `/cmd/capsule` listens to the QEMU serial port via `/dev/ttyS0`.

---

## Roadmap

* [x] PID 1 `init` and `service` manager
* [ ] `cmd/capsule`: A Lisp-inspired interactive shell
* [ ] `service/udevd`: Linux kernel uevent listener
* [ ] `service/display`: `kmsdrm`-based display service with Wayland protocol support
* [ ] `service/audio`: ALSA-based audio support
* [ ] `service/network`: Network interface service
* [ ] `service/auth`: Authentication service

See the [open issues](https://github.com/itsmanjeet/rlxos/issues) for more.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Contributing

Contributions make open-source amazing! Fork the repo and open a pull request.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes
4. Push to your branch
5. Open a pull request

<a href="https://github.com/itsmanjeet/rlxos/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=itsmanjeet/rlxos" />
</a>

---

## License

Distributed under the **GPL-3.0**. See the `LICENSE` file for more details.

---

[contributors-shield]: https://img.shields.io/github/contributors/itsmanjeet/rlxos.svg?style=for-the-badge

[contributors-url]: https://github.com/itsmanjeet/rlxos/graphs/contributors

[forks-shield]: https://img.shields.io/github/forks/itsmanjeet/rlxos.svg?style=for-the-badge

[forks-url]: https://github.com/itsmanjeet/rlxos/network/members

[stars-shield]: https://img.shields.io/github/stars/itsmanjeet/rlxos.svg?style=for-the-badge

[stars-url]: https://github.com/itsmanjeet/rlxos/stargazers

[issues-shield]: https://img.shields.io/github/issues/itsmanjeet/rlxos.svg?style=for-the-badge

[issues-url]: https://github.com/itsmanjeet/rlxos/issues

[product-screenshot]: assets/screenshots/screenshot.png

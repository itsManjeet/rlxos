<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/rlxos/rlxos">
    <img src="files/logo/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">rlxos</h3>

  <p align="center">
    A semi mutable, independent general-purpose distribution with primarly focus on "one file for anything" means one single file per application
    <br />
    <a href="https://github.com/rlxos/rlxos"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/rlxos/rlxos">View Demo</a>
    ·
    <a href="https://github.com/rlxos/rlxos/issues">Report Bug</a>
    ·
    <a href="https://github.com/rlxos/rlxos/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#Usage">Usage</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<!-- GETTING STARTED -->
## Getting Started

[![rlxos][product-screenshot]](https://rlxos.dev)

Rlxos is a semi mutable, independent general-purpose distribution (slightly more focused on programming) with primarly focus on "one file for anything" means one single file per application (even for system image, rlxos boot directly from system image and save cache on hard disk) so users can have multiple version/variant of same applications (and even operating system) installed side by side.Rlxos also provides a customized gnome environment with support for flatpak, snap and appimages (drag and drop install support) along with home grown package manager appctl.

### Prerequisites
- docker-compose
- pkgupd (if building toolchain)
### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/rlxos/rlxos.git
   ```
2. Start container based toolchain
   ```sh
   docker-compose -f docker/docker-compose.yml up -d
   ```
3. Compile required packages
   ```sh
   ./scripts/exec.sh pkgupd install dev.rlxos.core --compile-all
   ```
4. Generate ISO
   ```sh
   ./scripts/exec.sh /var/cache/scripts/iso.sh
   ```

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/rlxos/rlxos/issues) for a list of proposed features (and known issues).



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the LGPL2 License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Admin - [@rlxos_dev](https://twitter.com/rlxos_dev) - admin@rlxos.dev

Project Link: [https://github.com/rlxos/rlxos](https://github.com/rlxos/rlxos)


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/rlxos/rlxos.svg?style=for-the-badge
[contributors-url]: https://github.com/rlxos/rlxos/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/rlxos/rlxos.svg?style=for-the-badge
[forks-url]: https://github.com/rlxos/rlxos/network/members
[stars-shield]: https://img.shields.io/github/stars/rlxos/rlxos.svg?style=for-the-badge
[stars-url]: https://github.com/rlxos/rlxos/stargazers
[issues-shield]: https://img.shields.io/github/issues/rlxos/rlxos.svg?style=for-the-badge
[issues-url]: https://github.com/rlxos/rlxos/issues
[license-shield]: https://img.shields.io/github/license/rlxos/rlxos.svg?style=for-the-badge
[license-url]: https://github.com/rlxos/rlxos/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: files/screenshot.png



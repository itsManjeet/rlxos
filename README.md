# rlxos GNU/Linux
> A truly modern implementation of GNU/Linux distribution

## Targets
- [x] A completely immutable system root for the best possible system stability.
- [x] Container-based package management for better control over permissions.
- [x] Stable delta update infrastructure in dragging release model as Atomic actions.
- [x] A flexible Virtual Assistant for system management and task automation.
- [x] A future-ready interface that is compatible with touch display and convertible systems.
- [ ] And a lot more.

## Join Us
Join our [Telegram](https://t.) and get involved in the development process.

## Source Code

### Organization

| **Directory**  | **Description**                                                                           |
|----------------|-------------------------------------------------------------------------------------------|
| **/elements/** | buildstream meta configurations for components                                            |
| **/files/**    | files and patches required by buildstream meta configuration to build specific components |
| **/include/**  | project configurations                                                                    |
| **/plugins/**  | buildstream elements and source plugins                                                   |
| **/utils/**    | release and commits utilities                                                             |


### Environment Setup

**Prerequisites**

1. Python3 (>= 3.8)
2. BuildStream (1.6.x) and its dependencies
3. OSTree
4. Golang
5. Cargo
6. (optional) `server.crt` to pull already built artifacts from our server to avoid rebuilds  

**Steps**

- Setup python virtual environment
  `$ python3 -m venv .venv`

- Load environment and Install requirements from `requirements.txt`
  `$ source .venv/bin/activate (.fish for fish shell)`
  `$ pip3 install -r requirements.txt`

- To build specific component
  `$ bst build <component-id>.bst`

- To Test that component
  `$ bst shell <component-id>.bst`


## Special Thanks

<img src="https://resources.jetbrains.com/storage/products/company/brand/logos/jb_beam.png" alt="Logo" width="80" height="80">

[JetBrains OpenSource Support](https://jb.gg/OpenSourceSupport)

## Acknowledgments

- [BuildStream](https://buildstream.build)
- [GNOME](https://gnome.org)
- [GNOME OS](https://os.gnome.org)
- [Freedesktop Sdk](https://freedesktop-sdk.io)
- [Linux From Scratch](https://linuxfromscratch.org)
- [Creative Commons](https://creativecommons.org/)
- [Flaticons](https://www.flaticon.com/)
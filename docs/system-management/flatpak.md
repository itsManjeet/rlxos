# Flatpak

Flatpak is a software deployment and package management system designed to make it easier to distribute and run applications on Linux. It provides a way to package applications and their dependencies in a self-contained container that can run on various Linux distributions without altering the host system.

## Installing Applications

To install an application using Flatpak, you need to know the application's ID or URL. For example, to install the application "ExampleApp":

```bash

flatpak install flathub com.example.ExampleApp

```

## Running Applications

Once an application is installed, you can run it using:

```bash

flatpak run com.example.ExampleApp

```

## Managing Flatpak Repositories

Listing Installed Applications:

```bash

flatpak list

```

## Updating Applications:

```bash

flatpak update

```

## Uninstalling Applications:

```bash

flatpak uninstall com.example.ExampleApp

```

## Listing Remotes:

```bash

flatpak remote-list

```

## Adding a Remote:

```bash

flatpak remote-add --if-not-exists <name> <remote-url>

```

## Removing a Remote:

```bash

flatpak remote-delete <name>

```

## Permissions and Sandboxing

Flatpak uses permissions to control an application's access to resources on the host system. Permissions are declared in the app's manifest file.

### Viewing Permissions:

```bash

flatpak info --show-permissions com.example.ExampleApp

```
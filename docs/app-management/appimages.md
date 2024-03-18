# AppImage

RLXOS utilizes the [AppImages](https://appimage.org/) to distribute user applications through the [Application Market](https://rlxos.dev/apps).

__"AppImage is a format for distributing portable software on Linux without requiring superuser permissions for application installation."__

RLXOS provides seamless integration for AppImages. Users can effortlessly install AppImages by dragging and dropping them into the `~/Applications` folder.

## Obtaining AppImages

While AppImages are available from sources like [AppImageHub](https://www.appimagehub.com/) or other application distributors, we strongly recommend users acquire AppImages directly from the [Application Market](https://rlxos.dev/apps).

Simply visit the website and download the `.app` or `.AppImage` file.

## Installing AppImage

Upon accessing the `File Manager`, you'll notice a designated directory named **Applications**. To install an AppImage, simply copy and paste the file into this directory.

## Removing AppImage

Removing an installed AppImage follows a similar process to installation. Delete the AppImage from the `Applications` directory.

## Troubleshooting

If AppImage integration fails after dropping them into `~/Applications`, first verify if `appimaged` is running:

Check its status using:

`systemctl status appimaged --user`

If the status isn't `running` in `green`, attempt to start it manually:

`systemctl start appimaged --user`

If the service fails to start and troubleshooting via logs proves inconclusive, please report the issue via [Bug](https://github.com/itsManjeet/rlxos/issues/new).

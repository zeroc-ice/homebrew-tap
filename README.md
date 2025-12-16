# ZeroC Ice Homebrew Tap

This repository is a [Homebrew tap](https://github.com/Homebrew/brew/blob/master/docs/brew-tap.md) which contains formulae for [ZeroC](https://zeroc.com/) software.

## Install

To add this tap to Homebrew:

```shell
brew tap zeroc-ice/tap
```

## Usage

To install a formula:

```shell
brew install zeroc-ice/tap/<formula>
```

To install a cask:

```shell
brew cask install zeroc-ice/tap/<cask>
```

## Formulae

| Name                                             | Aliases         | Description                                     | Bottled | License                                     |
| ------------------------------------------------ | --------------- | ----------------------------------------------- | ------- | ------------------------------------------- |
| [`ice`][ice-formula]                             | `ice@3.8`       | Ice 3.8                                         | Y       | [GPLv2 and Commercial][ice-license]         |
| [`ice@3.7`][ice-37-formula]                      |                 | [Ice 3.7][ice-37-doc]                           | Y       | [GPLv2 and Commercial][ice-license]         |
| [`php-ice@3.7`][php-ice37-formula]               |                 | [Ice 3.7 for PHP][ice-37-doc]                   | N       | [GPLv2 and Commercial][ice-license]         |
| [`ice-builder-xcode`][ice-builder-xcode-formula] |                 | [Ice Builder for Xcode][ice-builder-xcode-repo] | N       | [BSD 3][ice-builder-xcode-license]          |
| [`freeze`][freeze-formula]                       | `freeze@3.7`    | [Freeze 3.7][freeze-docs]                       | Y       | [GPLv2 and Commercial][freeze-license]      |
| [`ice@3.6`][ice-36-formula]                      | `ice36`         | [Ice 3.6][ice-36-doc]                           | Y       | [GPLv2 and Commercial][ice-36-license]      |
| [`icetouch@3.6`][icetouch-36-formula]            | `icetouch36`    | [Ice Touch 3.6][icetouch-36-doc]                | Y       | [GPLv2 and Commercial][icetouch-36-license] |
| [`berkeley-db@5.3`][db-formula]                  | `berkeley-db53` | Berkeley DB 5.3, keg-only                       | Y       | [Custom Open Source][db-license]            |

## Casks

| Name                            | Description                   | License                             |
| ------------------------------- | ----------------------------- | ----------------------------------- |
| [`icegridgui`][gui-cask]        | IceGrid GUI 3.8               | [GPLv2 and Commercial][ice-license] |
| [`icegridgui@3.7`][gui-37-cask] | [IceGrid GUI 3.7][gui-37-doc] | [GPLv2 and Commercial][ice-license] |
| [`icegridgui36`][gui-36-cask]   | [IceGrid GUI 3.6][gui-36-doc] | [GPLv2 and Commercial][ice-license] |

[ice-license]: https://github.com/zeroc-ice/ice#copyright-and-license
[ice-formula]: Formula/ice.rb

[ice-37-doc]: https://doc.zeroc.com/display/Ice37/Using+the+macOS+Binary+Distribution
[ice-37-formula]: Formula/ice@3.7.rb

[php-ice37-formula]: Formula/php-ice@3.7.rb

[ice-builder-xcode-formula]: Formula/ice-builder-xcode.rb
[ice-builder-xcode-repo]: https://github.com/zeroc-ice/ice-builder-xcode/
[ice-builder-xcode-license]: https://github.com/zeroc-ice/ice-builder-xcode/blob/master/LICENSE

[freeze-formula]: Formula/freeze.rb
[freeze-docs]: https://doc.zeroc.com/display/Freeze37/Using+the+macOS+Binary+Distribution
[freeze-license]: https://github.com/zeroc-ice/freeze#copyright-and-license

[ice-36-formula]: Formula/ice@3.6.rb
[ice-36-doc]: https://doc.zeroc.com/display/Ice36/Using+the+macOS+Binary+Distribution
[ice-36-license]: https://github.com/zeroc-ice/ice/tree/3.6#copyright-and-license

[icetouch-36-formula]: Formula/icetouch@3.6.rb
[icetouch-36-doc]: https://doc.zeroc.com/display/Ice36/Using+the+macOS+Binary+Distribution
[icetouch-36-license]: https://github.com/zeroc-ice/icetouch#copyright-and-license

[db-formula]: FFormula/berkeley-db@5.3.rb
[db-license]: https://download.zeroc.com/berkeley-db/LICENSE

[gui-cask]: Casks/icegridgui.rb

[gui-37-cask]: Casks/icegridgui@3.7.rb
[gui-37-doc]: https://doc.zeroc.com/ice/3.7/ice-services/icegrid/icegrid-gui-tool

[gui-36-cask]: Casks/icegridgui36.rb
[gui-36-doc]: https://doc.zeroc.com/ice/3.6/ice-services/icegrid/icegrid-admin-graphical-tool

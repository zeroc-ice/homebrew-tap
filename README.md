# ZeroC Ice Homebrew Tap

This repository is a [Homebrew tap](https://docs.brew.sh/Taps) which contains formulae for [ZeroC](https://zeroc.com/) software.

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

| Name                        | Aliases   | Description           | Bottled | License                             |
| --------------------------- | --------- | --------------------- | ------- | ----------------------------------- |
| [`ice`][ice-formula]        | `ice@3.8` | Ice 3.8               | Y       | [GPLv2 and Commercial][ice-license] |
| [`ice@3.7`][ice-37-formula] |           | [Ice 3.7][ice-37-doc] | Y       | [GPLv2 and Commercial][ice-license] |

## Casks

| Name                            | Description                   | License                             |
| ------------------------------- | ----------------------------- | ----------------------------------- |
| [`icegridgui`][gui-cask]        | [IceGrid GUI 3.8][gui-doc]    | [GPLv2 and Commercial][ice-license] |
| [`icegridgui@3.7`][gui-37-cask] | [IceGrid GUI 3.7][gui-37-doc] | [GPLv2 and Commercial][ice-license] |
| [`icegridgui36`][gui-36-cask]   | [IceGrid GUI 3.6][gui-36-doc] | [GPLv2 and Commercial][ice-license] |

[ice-license]: https://github.com/zeroc-ice/ice#copyright-and-license
[ice-formula]: Formula/ice.rb

[ice-37-doc]: https://archive.zeroc.com/ice/3.7/release-notes/using-the-macos-binary-distribution
[ice-37-formula]: Formula/ice@3.7.rb

[gui-cask]: Casks/icegridgui.rb
[gui-doc]: https://docs.zeroc.com/ice/3.8/cpp/icegrid-gui-tool

[gui-37-cask]: Casks/icegridgui@3.7.rb
[gui-37-doc]: https://archive.zeroc.com/ice/3.7/ice-services/icegrid/icegrid-gui-tool

[gui-36-cask]: Casks/icegridgui36.rb
[gui-36-doc]: https://archive.zeroc.com/ice/3.6/ice-services/icegrid/icegrid-admin-graphical-tool

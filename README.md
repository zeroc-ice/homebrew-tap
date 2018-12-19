# ZeroC Ice Homebrew Tap

This repository is a [Homebrew tap](https://github.com/Homebrew/brew/blob/master/docs/brew-tap.md) which contains formulae for [ZeroC](https://zeroc.com/) software.

## Install

To add this tap to Homebrew:
```
brew tap zeroc-ice/tap
```

## Usage

To install a formula:
```
brew install zeroc-ice/tap/<formula>
```

## Formulae

| Name                   | Aliases           | Description                | Bottled | License                    |
| ------------------------ | --------------- | -------------------------- | ------- | ---------------------------|
| [`ice`][1]               | `ice@3.7`       | [Ice 3.7][2]               | Y       | [GPLv2 and Commercial][3]  |
| [`php-ice`][4]           | `php-ice@3.7`   | [Ice 3.7 for PHP][5]       | N       | [GPLv2 and Commercial][3]  |
| [`ice-builder-xcode`][6] |                 | [Ice Builder for Xcode][7] | N       | [BSD 3][8]                 |
| [`freeze`][9]            | `freeze@3.7`    | [Freeze 3.7][10]           | Y       | [GPLv2 and Commercial][11] |
| [`ice@3.6`][12]          | `ice36`         | [Ice 3.6][13]              | Y       | [GPLv2 and Commercial][14] |
| [`icetouch@3.6`][15]     | `icetouch36`    | [Ice Touch 3.6][16]        | Y       | [GPLv2 and Commercial][17] |
| [`berkeley-db@5.3`][18]  | `berkeley-db53` | Berkeley DB 5.3, keg-only  | Y       | [Custom Open Source][19]   |

## Casks

| Name               | Description           | License                    |
| ------------------ | ----------------------| -------------------------- |
| [`icegridgui`][20] | [IceGrid GUI 3.7][21] | [GPLv2 and Commercial][3]  |


[1]: Formula/ice.rb
[2]: https://doc.zeroc.com/display/Ice37/Using+the+macOS+Binary+Distribution
[3]: https://github.com/zeroc-ice/ice#copyright-and-license

[4]: Formula/php-ice.rb
[5]: https://doc.zeroc.com/display/Ice37/Using+the+macOS+Binary+Distribution

[6]: Formula/ice-builder-xcode.rb
[7]: https://github.com/zeroc-ice/ice-builder-xcode/
[8]: https://github.com/zeroc-ice/ice-builder-xcode/blob/master/LICENSE

[9]: Formula/freeze.rb
[10]: https://doc.zeroc.com/display/Freeze37/Using+the+macOS+Binary+Distribution
[11]: https://github.com/zeroc-ice/freeze#copyright-and-license

[12]: Formula/ice@3.6.rb
[13]: https://doc.zeroc.com/display/Ice36/Using+the+macOS+Binary+Distribution
[14]: https://github.com/zeroc-ice/ice/tree/3.6#copyright-and-license

[15]: Formula/icetouch@3.6.rb
[16]: https://doc.zeroc.com/display/Ice36/Using+the+macOS+Binary+Distribution
[17]: https://github.com/zeroc-ice/icetouch#copyright-and-license

[18]: Formula/berkeley-db@5.3.rb
[19]: https://download.zeroc.com/berkeley-db/LICENSE

[20]: Casks/icegridgui.rb
[21]: https://doc.zeroc.com/ice/3.7/ice-services/icegrid/icegrid-gui-tool

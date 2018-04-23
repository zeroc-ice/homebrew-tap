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

| Name                                                | Aliases         | Description                                                                                    | Bottled |
| --------------------------------------------------- | --------------- | ---------------------------------------------------------------------------------------------- | ------- |
| [`ice`](Formula/ice.rb)                             | `ice@3.7`       | [Ice 3.7](https://doc.zeroc.com/display/Ice37/Using+the+macOS+Binary+Distribution)             | Y       |
| [`php-ice`](Formula/php-ice.rb)                     | `php-ice@3.7`   | [Ice 3.7 for PHP](https://doc.zeroc.com/display/Ice37/Using+the+macOS+Binary+Distribution)     | N       |
| [`ice-builder-xcode`](Formula/ice-builder-xcode.rb) |                 | [Ice Builder for Xcode](https://github.com/zeroc-ice/ice-builder-xcode/)                       | N       |
| [`freeze`](Formula/freeze.rb)                       | `freeze@3.7`    | [Freeze 3.7](https://doc.zeroc.com/display/Freeze37/Using+the+macOS+Binary+Distribution)       | Y       |
| [`ice@3.6`](Formula/ice@3.6.rb)                     | `ice36`         | [Ice 3.6](https://doc.zeroc.com/display/Ice36/Using+the+macOS+Binary+Distribution)             | Y       |
| [`icetouch@3.6`](Formula/icetouch@3.6.rb)           | `icetouch36`    | [Ice Touch 3.6](https://doc.zeroc.com/display/Ice36/Using+the+Ice+Touch+Binary+Distribution)   | Y       |
| [`berkeley-db@5.3`](Formula/berkeley-db@5.3.rb)     | `berkeley-db53` | Berkeley DB 5.3, keg-only                                                                      | Y       |

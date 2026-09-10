cask "icegridgui" do
  version "3.8.3"
  sha256 "ce9ec38a94c390e511dcddac0b6255492287596e022463f2dd98948244c058e3"

  url "https://download.zeroc.com/ice/3.8/IceGridGUI-#{version}.dmg"
  name "IceGrid GUI"
  desc "Graphical administration tool for IceGrid"
  homepage "https://zeroc.com/"

  livecheck do
    skip "Versions are managed manually"
  end

  depends_on :macos

  app "IceGrid GUI.app"
end

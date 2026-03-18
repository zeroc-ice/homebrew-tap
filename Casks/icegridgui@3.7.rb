cask "icegridgui@3.7" do
  version "3.7.11"
  sha256 "4a4528be2c60becadea1ce6377cf7a3191ad50dfbc7ca7aaf2799a8f8f03db70"

  url "https://download.zeroc.com/ice/3.7/IceGridGUI-#{version}.dmg"
  name "IceGrid GUI"
  desc "Graphical administration tool for IceGrid"
  homepage "https://zeroc.com/"

  livecheck do
    skip "Versions are managed manually"
  end

  app "IceGrid GUI.app"
end

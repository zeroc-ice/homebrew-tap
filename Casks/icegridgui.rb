cask "icegridgui" do
  version "3.8.2"
  sha256 "6394eb40c0a17ef3e78ba7c6d42813fc3aef61c9a39f081bfa7b248cd407e716"

  url "https://download.zeroc.com/ice/3.8/IceGridGUI-#{version}.dmg"
  name "IceGrid GUI"
  desc "Graphical administration tool for IceGrid"
  homepage "https://zeroc.com/"

  livecheck do
    skip "Versions are managed manually"
  end

  app "IceGrid GUI.app"
end

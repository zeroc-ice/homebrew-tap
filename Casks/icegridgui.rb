cask "icegridgui" do
  version "3.8.1"
  sha256 "10c6386a4d67a4d5a5c34297159bad97fff7adaa5f50a0977a988d7164614927"

  url "https://download.zeroc.com/ice/3.8/IceGridGUI-#{version}.dmg"
  name "IceGrid GUI"
  desc "Graphical administration tool for IceGrid"
  homepage "https://zeroc.com/"

  livecheck do
    skip "Versions are managed manually"
  end

  app "IceGrid GUI.app"
end

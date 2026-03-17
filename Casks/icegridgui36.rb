cask "icegridgui36" do
  version "3.6.5"
  sha256 "aecffd7cab6ae5474ac1e2e5ceb057e064a13105e45d17340508e5ccfd3108cb"

  url "https://zeroc.com/download/ice/3.6/IceGridAdmin-#{version}.dmg"
  name "IceGrid Admin"
  desc "Graphical administration tool for IceGrid"
  homepage "https://zeroc.com/"

  livecheck do
    skip "Versions are managed manually"
  end

  caveats do
    requires_rosetta
  end

  app "IceGrid Admin.app"
end

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "AFOPlaylist"
  s.version      = "0.0.17"
  s.summary      = "play list."

  # This description is used to generate tags and improve search results.
  s.description  = 'Main features of player, player playlist.'
  s.homepage     = "https://github.com/PangDuTechnology/AFOPlaylist.git"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "PangDu" => "xian312117@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = '8.0'

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/PangDuTechnology/AFOPlaylist.git", :tag => s.version.to_s }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "AFOPlaylist/**/*.{h,m}"
  s.public_header_files = "AFOPlaylist/**/*.h"
  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true
  s.dependency "AFOFoundation"
  s.dependency "AFOSchedulerCore"
  s.dependency "AFORouter"
  s.dependency "AFOUIKIT"
  s.dependency "AFOFFMpeg"
  s.dependency "AFOSQLite"
  s.dependency "AFOGitHub"
end

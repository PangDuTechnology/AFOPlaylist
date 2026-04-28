Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "AFOPlaylist"
  s.version      = "0.1.0"
  s.summary      = "play list."

  # This description is used to generate tags and improve search results.
  s.description  = 'Main features of player, player playlist.'
  s.homepage     = "https://github.com/PangDuTechnology/AFOPlaylist.git"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "PangDu" => "xian312117@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "13.0"
  s.ios.deployment_target = '13.0'

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/PangDuTechnology/AFOPlaylist.git", :tag => s.version.to_s }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "AFOPlaylist/**/*.{h,m}"
  s.exclude_files = "AFOPlaylist/Tests/**/*"
  s.public_header_files = "AFOPlaylist/**/*.h"
  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true
  s.static_framework = true
  s.dependency "AFOFoundation"
  s.dependency "AFOSchedulerCore"
  s.dependency "AFORouter"
  s.dependency "AFOUIKIT"
  s.dependency "AFOFFMpeg"
  s.dependency "AFOLANUpload"
  s.dependency "AFOSQLite"
  s.dependency "FMDB", "~> 2.7"
  s.dependency "AFOGitHub"

  s.test_spec 'Tests' do |test_spec|
    test_spec.platform = :ios, '13.0'
    test_spec.source_files = 'AFOPlaylist/Tests/**/*.{h,m}'
    test_spec.frameworks = 'XCTest'
  end
end

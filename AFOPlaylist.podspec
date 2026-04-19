Pod::Spec.new do |s|
  s.name             = 'AFOPlaylist'
  s.version          = '0.0.18'
  s.summary          = 'AFO 播放列表模块'
  s.description      = '播放列表 UI、SQLite 与 TabBar 子模块集成，依赖团队基础 Pod。'
  s.homepage         = 'https://github.com/PangDuTechnology/AFOPlaylist'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'PangDu' => 'xian312117@gmail.com' }
  s.source           = { :git => 'https://github.com/PangDuTechnology/AFOPlaylist.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.requires_arc = true

  s.source_files = 'AFOPlaylist/**/*.{h,m}'
  s.public_header_files = 'AFOPlaylist/**/*.h'

  s.dependency 'AFOFFMpeg'
  s.dependency 'AFOFoundation'
  s.dependency 'AFOGitHub'
  s.dependency 'AFORouter'
  s.dependency 'AFOSchedulerCore'
  s.dependency 'AFOSQLite'
  s.dependency 'AFOUIKIT'
end

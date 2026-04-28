platform :ios, '13.0'
inhibit_all_warnings!
target 'AFOPlaylist' do
  pod 'AFOFFMpeg'
  pod 'AFOUIKIT'
  pod 'AFOFoundation'
  pod 'AFOSchedulerCore'
  pod 'AFORouter'
  pod 'AFOLANUpload'
  pod 'AFOSQLite'
  pod 'FMDB'
  pod 'AFOGitHub'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 13.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end

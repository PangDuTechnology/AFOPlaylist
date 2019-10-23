Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "AFOPlaylist"
  s.version      = "0.0.18"
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
  s.source_files  = "AFOPlaylist/AFOPlaylist.h"
  s.public_header_files = "AFOPlaylist/AFOPlaylist.h"

  s.subspec 'foreign' do |foreign|
      foreign.source_files = 'AFOPlaylist/foreign/*.{h,m}' 
      foreign.public_header_files = 'AFOPlaylist/foreign/*.h' 
    end

  s.subspec 'controller' do |controller|
      controller.subspec 'main' do |main|
          main.source_files = 'AFOPlaylist/controller/main/*.{h,m}' 
          main.public_header_files = 'AFOPlaylist/controller/main/*.h' 
        end
      controller.subspec 'viewModel' do |viewModel|
          viewModel.source_files = 'AFOPlaylist/controller/viewModel/*.{h,m}' 
          viewModel.public_header_files = 'AFOPlaylist/controller/viewModel/*.h' 
        end
      controller.subspec 'category' do |category|
          category.source_files = 'AFOPlaylist/controller/category/*.{h,m}' 
          category.public_header_files = 'AFOPlaylist/controller/category/*.h' 
        end
    end

  s.subspec 'viewModels' do |viewModels|
      viewModels.subspec 'folder' do |folder|
          folder.source_files = 'AFOPlaylist/viewModels/folder/*.{h,m}' 
          folder.public_header_files = 'AFOPlaylist/viewModels/folder/*.h' 
        end
      viewModels.subspec 'sql' do |sql|
          sql.source_files = 'AFOPlaylist/viewModels/sql/*.{h,m}' 
          sql.public_header_files = 'AFOPlaylist/viewModels/sql/*.h' 
        end
      viewModels.subspec 'shareFolders' do |shareFolders|
          shareFolders.source_files = 'AFOPlaylist/viewModels/shareFolders/*.{h,m}' 
          shareFolders.public_header_files = 'AFOPlaylist/viewModels/shareFolders/*.h' 
        end
    end

  

  

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

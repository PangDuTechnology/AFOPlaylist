# frozen_string_literal: true

# Injects post_install / post_integrate into the temporary Podfile used by
# `pod spec lint` / `pod trunk push`, bumping every Pod target's
# IPHONEOS_DEPLOYMENT_TARGET so Xcode 15+ does not fail on missing libarclite.
# https://github.com/CocoaPods/CocoaPods/issues/12033
#
# Must load the full CocoaPods stack first (not cocoapods/validator alone), or
# Pod::Config is missing and you get: uninitialized constant Pod::Validator::Config
#
# Usage (repo root):
#   RUBYOPT="-r#{File.expand_path(__dir__)}/cocoapods_validator_deployment_target.rb" pod trunk push AFOPlaylist.podspec --allow-warnings

require 'rubygems'
require 'cocoapods'

Pod::Validator.class_eval do
  def podfile_from_spec(platform_name, deployment_target, use_frameworks = true, test_spec_names = [], use_modular_headers = false, use_static_frameworks = false)
    name     = subspec_name || spec.name
    podspec  = file.realpath
    local    = local?
    urls     = source_urls

    additional_podspec_pods = external_podspecs ? Dir.glob(external_podspecs) : []
    additional_path_pods = (include_podspecs ? Dir.glob(include_podspecs) : []) .select { |path| spec.name != Specification.from_file(path).name } - additional_podspec_pods

    floor_ver = 12.0
    want_ver = deployment_target.to_s.to_f
    bump_to = [floor_ver, want_ver].max.to_s

    apply_ios_deployment_floor = lambda do |installer|
      next unless platform_name == :ios

      projects = []
      projects << installer.pods_project if installer.pods_project
      if installer.respond_to?(:generated_projects)
        Array(installer.generated_projects).each { |p| projects << p }
      end
      projects.compact.uniq.each do |project|
        project.targets.each do |target|
          target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = bump_to
          end
        end
      end
    end

    Pod::Podfile.new do
      install! 'cocoapods', :deterministic_uuids => false, :warn_for_unused_master_specs_repo => false
      inhibit_all_warnings!
      urls.each { |u| source(u) }
      target 'App' do
        if use_static_frameworks
          use_frameworks!(:linkage => :static)
        else
          use_frameworks!(use_frameworks)
        end
        use_modular_headers! if use_modular_headers
        platform(platform_name, deployment_target)
        if local
          pod name, :path => podspec.dirname.to_s, :inhibit_warnings => false
        else
          pod name, :podspec => podspec.to_s, :inhibit_warnings => false
        end

        additional_path_pods.each do |podspec_path|
          podspec_name = File.basename(podspec_path, '.*')
          pod podspec_name, :path => File.dirname(podspec_path)
        end

        additional_podspec_pods.each do |podspec_path|
          podspec_name = File.basename(podspec_path, '.*')
          pod podspec_name, :podspec => podspec_path
        end

        test_spec_names.each do |test_spec_name|
          if local
            pod test_spec_name, :path => podspec.dirname.to_s, :inhibit_warnings => false
          else
            pod test_spec_name, :podspec => podspec.to_s, :inhibit_warnings => false
          end
        end
      end

      post_install(&apply_ios_deployment_floor)
      post_integrate(&apply_ios_deployment_floor)
    end
  end
end

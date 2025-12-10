#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint video_snapshot_generator.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'video_snapshot_generator'
  s.version          = '0.1.0'
  s.summary          = 'Generate video snapshots and thumbnails with custom dimensions and quality settings.'
  s.description      = <<-DESC
A Flutter package for generating video snapshots and thumbnails with custom dimensions and quality settings.
                       DESC
  s.homepage         = 'https://github.com/Dhia-Bechattaoui/video_snapshot_generator'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dhia-Bechattaoui' => 'your-email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end


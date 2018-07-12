#
# Be sure to run `pod lib lint SuperResolutionKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SuperResolutionKit'
  s.version          = '0.1.0'
  s.summary          = 'Super resolution implementation with Keras/CoreML'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is a super resolution implementation with Keras/CoreML
                       DESC

  s.homepage         = 'https://github.com/kenmaz/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kenmaz' => 'kentaro.matsumae@gmail.com' }
  s.source           = { :git => 'https://github.com/kenmaz/SuperResolutionKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.1'

  s.source_files = [
    'SuperResolutionKit/Classes/*',
    'SuperResolutionKit/Classes/CoreMLHelpers/*'
  ]
  s.resource_bundles = {
    'SuperResolutionKit' => [
      'SuperResolutionKit/Assets/*'
    ]
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

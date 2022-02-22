#
# Be sure to run `pod lib lint CLPhotoCrop.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CLPhotoCrop'
  s.version          = '0.1.2'
  s.summary          = '高仿微信编辑图片'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  高仿微信编辑图片
                       DESC

  s.homepage         = 'https://github.com/SilmeLyy/CLPhotoCrop'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'leiyuyu' => 'leiyuyu@chelun.com' }
  s.source           = { :git => 'https://github.com/SilmeLyy/CLPhotoCrop.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'CLPhotoCrop/Classes/*'
  s.resources = 'CLPhotoCrop/Assets/*.bundle'
  s.public_header_files = 'CLPhotoCrop/Classes/CLPhotoCrop.h'

  s.frameworks = 'UIKit'
end

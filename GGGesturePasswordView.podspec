#
# Be sure to run `pod lib lint GGGesturePasswordView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GGGesturePasswordView'
  s.version          = '0.1.6'
  s.summary          = '这是一个9宫格手势解锁View'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/github6022244/GGGesturePasswordView.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Wgh' => '1563084860@qq.com' }
  s.source           = { :git => 'https://github.com/github6022244/GGGesturePasswordView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  
  s.exclude_files = "Classes/Exclude"  # 仅排除无关文件

  s.source_files = 'GGGesturePasswordView/Classes/**/*.{h,m}'
  
  s.resource_bundles = {
    # 资源束名称，建议与组件名一致
    'GGGesturePasswordView' => [
      # 匹配普通图片（递归匹配 Assets 下所有子目录的 .png/.jpg）
      'GGGesturePasswordView/Assets/**/*.{png,jpg,jpeg}',
      # 匹配 Asset Catalog 资源（.xcassets 目录及其子目录）
      'GGGesturePasswordView/Assets/**/*.xcassets'
    ]
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

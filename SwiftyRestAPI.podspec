#
# Be sure to run `pod lib lint SwiftyRestAPI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftyRestAPI'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SwiftyRestAPI.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/danlozano/SwiftyRestAPI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'danlozano' => 'danlozano@gmail.com' }
  s.source           = { :git => 'https://github.com/danlozano/SwiftyRestAPI.git', :tag => s.version.to_s }

  s.platform = :osx
  s.osx.deployment_target  = '10.10'

  s.source_files = 'Sources/SwiftyRestAPICore/**/*'
  s.dependency 'Files', '~> 2.0'
  s.dependency 'Swiftline', '0.5.0'

end

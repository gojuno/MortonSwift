#
#  Be sure to run `pod spec lint MortonSwift.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "Morton"
  s.version      = "2.0.3"
  s.summary      = "MortonSwift"
  s.homepage     = "https://github.com/gtforge/MortonSwift"
  s.platform     = :ios, "10.0"
  s.license      = "BSD"
  s.author             = { "Gil Polak" => "gilp@gett.com" }
  s.source       = { :git => "https://github.com/gtforge/MortonSwift.git", :tag => "#{s.version}" }
  s.source_files  = "Morton/*"

end

require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'CapgoLlm'
  s.version = package['version']
  s.summary = package['description']
  s.license = package['license']
  s.homepage = package['repository']['url']
  s.author = package['author']
  s.source = { :git => package['repository']['url'], :tag => s.version.to_s }
  s.source_files = 'ios/Sources/**/*.{swift,h,m,c,cc,mm,cpp}'
  s.ios.deployment_target = '14.0'
  s.dependency 'Capacitor'
  # Note: LLM.swift is not available as a published CocoaPod
  # Users need to add it via Swift Package Manager or directly to their project
  # For SPM: .package(url: "https://github.com/eastriverlee/LLM.swift", from: "1.0.0")
  s.swift_version = '5.1'
end

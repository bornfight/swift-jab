
Pod::Spec.new do |s|
  s.name             = 'jab'
  s.version          = '0.1.0'
  s.summary          = 'JSON:API response transformer.'

  s.description      = <<-DESC
Parses JSON:API responses into predefined codable objects, reducing relationships and metadata into a single JSON response.
                       DESC

  s.homepage         = 'https://github.com/degordian/swift-jab'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bornfight' => 'mobile@bornfight.com', 'Dino Srdoc' => 'dino.srdoc@bornfight.com' }
  s.source           = { :git => 'https://github.com/degordian/swift-jab.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'

end

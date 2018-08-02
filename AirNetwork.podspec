Pod::Spec.new do |s|

  s.name         = "AirNetwork"
  s.version      = "1.0"
  s.summary      = "Better way to deal with API and JSON"

  s.homepage     = "https://github.com/YuriFox/AirNetwork"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "YuriFox" => "yuri17fox@gmail.com" }
  
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/YuriFox/AirNetwork.git", :tag => s.version.to_s }

  s.source_files = "Source/*.swift"
  
end
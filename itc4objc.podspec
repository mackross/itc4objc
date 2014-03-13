
Pod::Spec.new do |s|
  s.name         = "itc4objc"
  s.version      = "0.1.0"
  s.summary      = "Port of itc4j implementation of interval tree clocks to objective-c"
  s.homepage     = "https://github.com/mackross/itc4objc"
  s.license      = 'Copyright 2014 Andrew Mackenzie-Ross'
  s.authors      = { "mackross" => "andrew@happyinspector.com" }
  s.source       = { :git => "https://github.com/mackross/itc4objc.git", :tag => "v#{s.version}" }
  
  s.platform     = :ios, '6.0'
  s.requires_arc = true
  
  s.source_files = 'IntervalTreeClock/Classes/**/*.{h,m}'

end

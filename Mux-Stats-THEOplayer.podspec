Pod::Spec.new do |s|
  s.name             = 'Mux-Stats-THEOplayer'

  s.version          = '0.7.0'
  s.source           = { :git => 'https://github.com/muxinc/mux-stats-sdk-theoplayer-ios.git',
                         :tag => "v#{s.version}" }

  s.summary          = 'The Mux Stats SDK for THEOplayer'
  s.description      = 'The Mux stats SDK connect with THEOplayer to perform analytics and QoS monitoring for video.'

  s.homepage         = 'https://mux.com'
  s.social_media_url = 'https://twitter.com/muxhq'

  s.license          = 'Apache 2.0'
  s.author           = { 'Mux' => 'ios-sdk@mux.com' }

  s.ios.deployment_target   = '11.0'
  s.dependency 'Mux-Stats-Core', '~>3.10'
  s.vendored_frameworks = 'XCFramework/MUXSDKStatsTHEOplayer.xcframework'

end

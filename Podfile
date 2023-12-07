# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# Resolve react_native_pods.rb with node to allow for hoisting
require Pod::Executable.execute_command('node', ['-p',
  'require.resolve(
    "react-native/scripts/react_native_pods.rb",
    {paths: [process.argv[1]]},
  )', __dir__]).strip

platform :ios, min_ios_version_supported
prepare_react_native_project!

linkage = ENV['USE_FRAMEWORKS']
if linkage != nil
  Pod::UI.puts "Configuring Pod with #{linkage}ally linked Frameworks".green
  use_frameworks! :linkage => linkage.to_sym
end


def react_commpact 
  # Pods for RNTest
  pod 'React', :path => '../node_modules/react-native/'
  
  # React-Core 依赖有问题，修改路径
  pod 'React-Core', :path => '../node_modules/react-native/'
  
  pod 'React-Core/DevSupport', :path => '../node_modules/react-native/'
  
  # React-fishhook 不需要，先删掉
  # pod 'React-fishhook', :path => '../node_modules/react-native/Libraries/fishhook'
  
  pod 'React-RCTActionSheet', :path => '../node_modules/react-native/Libraries/ActionSheetIOS'
  pod 'React-RCTAnimation', :path => '../node_modules/react-native/Libraries/NativeAnimation'
  pod 'React-RCTBlob', :path => '../node_modules/react-native/Libraries/Blob'
  pod 'React-RCTImage', :path => '../node_modules/react-native/Libraries/Image'
  pod 'React-RCTLinking', :path => '../node_modules/react-native/Libraries/LinkingIOS'
  pod 'React-RCTNetwork', :path => '../node_modules/react-native/Libraries/Network'
  pod 'React-RCTSettings', :path => '../node_modules/react-native/Libraries/Settings'
  pod 'React-RCTText', :path => '../node_modules/react-native/Libraries/Text'
  pod 'React-RCTVibration', :path => '../node_modules/react-native/Libraries/Vibration'
  
  # RCTWebSocket 依赖有问题，修改路径
  pod 'React-Core/RCTWebSocket', :path => '../node_modules/react-native/'
  # pod 'React-RCTWebSocket', :path => '../node_modules/react-native/Libraries/WebSocket'
  

  pod 'React-cxxreact', :path => '../node_modules/react-native/ReactCommon/cxxreact'
  pod 'React-jsi', :path => '../node_modules/react-native/ReactCommon/jsi'
  pod 'React-jsiexecutor', :path => '../node_modules/react-native/ReactCommon/jsiexecutor'
  pod 'React-jsinspector', :path => '../node_modules/react-native/ReactCommon/jsinspector'
end

config = use_native_modules!

target 'FRW' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  

  use_react_native!(
    :path => config[:reactNativePath],
    # An absolute path to your application root.
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )
  react_commpact
  
  # Pods for FRW

  target 'FRWTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'FRW-dev' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  use_react_native!(
    :path => config[:reactNativePath],
    # An absolute path to your application root.
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )
  react_commpact
  # Pods for FRW-dev

end

target 'FRWDevNotificationServiceExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  config = use_native_modules!

  use_react_native!(
    :path => config[:reactNativePath],
    # An absolute path to your application root.
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )

  # Pods for FRWDevNotificationServiceExtension

end

target 'FRWDevWidgetsExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FRWDevWidgetsExtension

end

target 'FRWNotificationServiceExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FRWNotificationServiceExtension

end

target 'FRWWidgetsExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FRWWidgetsExtension

end

post_install do |installer|
  # https://github.com/facebook/react-native/blob/main/packages/react-native/scripts/react_native_pods.rb#L197-L202
  react_native_post_install(
    installer,
    config[:reactNativePath],
    :mac_catalyst_enabled => false
  )
end


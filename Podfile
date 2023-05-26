platform :ios, '12.0'

target 'SUPLA' do
  use_frameworks!

  # Pods for SUPLA
  pod 'Charts', '~> 4.0'
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'RxDataSources'
  pod 'RxCocoa'
  pod 'QueryKit'
  pod 'PaddingLabel', '1.2'
  pod 'FMMoveTableView', '~> 1.1'

  target 'SUPLATests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxTest'
  end
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
               end
          end
   end
end

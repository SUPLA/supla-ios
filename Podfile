platform :ios, '13.0'

target 'SUPLA' do
  use_frameworks!

  # Pods for SUPLA
  pod 'DGCharts', '5.1.0'
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'RxDataSources'
  pod 'RxCocoa'
  pod 'RxBlocking'
  pod 'QueryKit'
  pod 'PaddingLabel', '1.2'
  pod 'FMMoveTableView', '~> 1.1'
  pod 'SwiftyBeaver'
  pod 'SwiftSoup'
  pod 'Alamofire'

  target 'SUPLATests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxTest'
  end
  
  target 'SUPLAWidgetsExtension' do
    inherit! :search_paths
    # Pods for widgets
    pod 'SwiftyBeaver'
  end
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end

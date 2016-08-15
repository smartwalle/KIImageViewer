Pod::Spec.new do |s|
  s.name         = "KIImageViewer"
  s.version      = "0.0.1"
  s.summary      = "KIImageViewer"

  s.description  = <<-DESC
                   KIImageViewer.
                   DESC

  s.homepage     = "https://github.com/smartwalle/KIImageViewer"
  s.license      = "MIT"
  s.author             = { "SmartWalle" => "smartwalle@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/smartwalle/KIImageViewer.git", :tag => "#{s.version}" }
  s.source_files = "KIImageViewer/KIImageViewer/**/*.{h,m}"
  s.requires_arc = true
  s.dependency "SDWebImage"
end

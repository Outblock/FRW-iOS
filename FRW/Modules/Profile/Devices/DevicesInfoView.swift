//
//  DevicesInfoView.swift
//  FRW
//
//  Created by cat on 2023/10/30.
//

import SwiftUI
import MapKit


extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}

struct DevicesInfoView: RouteableView {
    var info: DeviceInfoModel
    

    
    
    var title: String {
        return "device_info".localized
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .center,spacing: 0) {
                    Map(coordinateRegion: .constant(region()), annotationItems: annotations()) {
                                
                        MapAnnotation(coordinate: $0) {
                            Image("map_pin_1")
                                .frame(width: 40, height: 51)
                        }
                            }
                        .frame(maxWidth: .infinity)
                        .frame(height: 136)
                        .cornerRadius(16)
                    Color.clear
                        .frame(height: 8)
                    Text(info.showName())
                        .font( .inter(size: 16,weight: .bold))
                        .foregroundColor(Color.Theme.Text.black8)
                        .frame(height: 24)
                    Color.clear
                        .frame(height: 24)
                    
                    HStack(spacing: 0) {
                        Text("device_info".localized)
                          .font(.inter(size: 14,weight: .bold))
                          .foregroundColor(Color.Theme.Text.black3)
                        Spacer()
                    }
                    
                    Color.clear
                        .frame(height: 8)
                    
                    VStack {
                        InfoItem(title: "Application", detail: info.showApp())
                        Divider()
                            .background(Color.Theme.Line.line)
                            .padding(.vertical, 16)
                        InfoItem(title: "IP Address", detail: info.showIP())
                        Divider()
                            .background(Color.Theme.Line.line)
                            .padding(.vertical, 16)
                        InfoItem(title: "Location", detail: info.showLocation())
                        Divider()
                            .background(Color.Theme.Line.line)
                            .padding(.vertical, 16)
                        InfoItem(title: "Entry Date", detail: info.showDate())
                    }
                    .padding(.all, 16)
                    .background(.Theme.Background.grey)
                    .cornerRadius(16)
                    
                    

                }
                .padding(.horizontal, 18)
                .frame(maxHeight: .infinity)
            }
            
            Spacer()
            
//            VStack {
//                Button {
//                    
//                } label: {
//                    Text("revoke_device".localized)
//                        .font(.inter(size: 16,weight: .semibold))
//                        .foregroundStyle(Color.Theme.Text.white9)
//                }
//                .frame(height: 54)
//                .frame(maxWidth: .infinity)
//                .background(Color.Theme.Accent.red)
//                .cornerRadius(16)
//            }
//            .padding(.horizontal, 18)
            
        }
        
        
        .applyRouteable(self)
    }
    
    func region() -> MKCoordinateRegion {
        var region = MKCoordinateRegion(center: info.coordinate(), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        return region
    }
    
    func annotations() -> [CLLocationCoordinate2D] {
        return [
            info.coordinate()
        ]
    }
    
    
}

extension DevicesInfoView {
    struct InfoItem: View {
        var title: String
        var detail: String
        var body: some View {
            HStack {
                // Body1
                Text(title)
                  .font(Font.inter(size: 16))
                  .foregroundColor(.black.opacity(0.8))
                Spacer()
                // Body1
                Text(detail)
                  .font(Font.inter(size: 16))
                  .multilineTextAlignment(.trailing)
                  .foregroundColor(.black.opacity(0.3))
            }
        }
    }
}

#Preview {
    DevicesInfoView(info: DeviceInfoModel.empty())
}

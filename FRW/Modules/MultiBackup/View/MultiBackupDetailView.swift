//
//  MultiBackupDetailView.swift
//  FRW
//
//  Created by cat on 2024/1/7.
//

import MapKit
import SwiftUI

struct MultiBackupDetailView: RouteableView {
    var item: KeyDeviceModel
    
    var title: String {
        return "backup_detail".localized
    }
    
    var body: some View {
        HStack {
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    Map(coordinateRegion: .constant(region()), annotationItems: annotations()) {
                        MapAnnotation(coordinate: $0) {
                            Image("map_pin_1")
                                .frame(width: 40, height: 51)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 136)
                    .cornerRadius(16)
                    Text(item.multiBackupType()!.title + "backup".localized)
                        .font(.inter(size: 16, weight: .bold))
                        .foregroundColor(Color.Theme.Text.black8)
                        .frame(height: 24)
                        .padding(.top, 8)
                    
                    keyView
                        .padding(.top, 16)
                    backupInfo
                        .padding(.top, 24)
                }
                .padding(.horizontal, 18)
                .frame(maxHeight: .infinity)
            }
            
            Spacer()
        }
        .applyRouteable(self)
    }
    
    var keyView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                Text("key_location".localized)
                    .font(.inter(size: 14, weight: .bold))
                    .foregroundColor(Color.Theme.Text.black3)
                Spacer()
            }
            
            HStack(spacing: 8) {
                HStack(alignment: .center, spacing: 8) {
                    Text("Key \(item.backupInfo?.keyIndex ?? 0)")
                        .padding(.trailing, 8)
                    
                    Text("backup".localized + " - " + item.multiBackupType()!.title)
                        .padding(.horizontal, 8)
                        .frame(height: 20)
                        .font(.inter(size: 10, weight: .bold))
                        .foregroundStyle(Color.Theme.Text.black3)
                        .background(Color.Theme.Text.black3.fixedOpacity())
                        .cornerRadius(4)
                    
                    Spacer()
                    Image("key.lock")
                        .frame(width: 16, height: 16)
                    
                    ZStack(alignment: .leading) {
                        Color.Theme.Text.black3
                            .frame(width: 36)
                            .cornerRadius(2)
                        Text("500/1000")
                            .font(.inter(size: 9, weight: .bold))
                            .frame(width: 72, height: 16)
                            .foregroundStyle(Color.Theme.Text.white9)
                    }
                    .frame(width: 72, height: 16)
                    .background(.Theme.Text.black3)
                    .cornerRadius(2)
                    
                    Image("icon-account-arrow-right")
                        .renderingMode(.template)
                        .foregroundColor(.LL.Neutrals.text)
                        .frame(width: 16, height: 16)
                        .padding(.leading, 16)
                }
                .frame(height: 52)
                .padding(.horizontal, 16)
                .background(.Theme.Background.grey)
                .cornerRadius(16)
            }
        }
    }
    
    var backupInfo: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("backup_info".localized)
                    .font(.inter(size: 14, weight: .bold))
                    .foregroundColor(Color.Theme.Text.black3)
                Spacer()
            }
            
            Color.clear
                .frame(height: 8)
            
            VStack {
                DeviceInfoItem(title: "application_tag".localized, detail: item.device.showApp())
                Divider()
                    .background(Color.Theme.Line.line)
                    .padding(.vertical, 16)
                DeviceInfoItem(title: "ip_address_tag".localized, detail: item.device.showIP())
                Divider()
                    .background(Color.Theme.Line.line)
                    .padding(.vertical, 16)
                DeviceInfoItem(title: "location".localized, detail: item.device.showLocation())
                Divider()
                    .background(Color.Theme.Line.line)
                    .padding(.vertical, 16)
                DeviceInfoItem(title: "entry_date_tag".localized, detail: item.device.showDate())
            }
            .padding(.all, 16)
            .background(.Theme.Background.grey)
            .cornerRadius(16)
        }
    }
    
    func region() -> MKCoordinateRegion {
        let region = MKCoordinateRegion(center: item.device.coordinate(), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        return region
    }
    
    func annotations() -> [CLLocationCoordinate2D] {
        return [
            item.device.coordinate()
        ]
    }
}

//
//  AddSyncDeviceView.swift
//  FRW
//
//  Created by cat on 2023/11/29.
//

import SwiftUI
import SwiftUIX
import MapKit
import Flow

struct SyncAddDeviceView: View {
    
    let viewModel = SyncAddDeviceViewModel()
    
    let model: RegisterRequest
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Color.clear
                    .frame(width: 24, height: 24)
                Spacer()
                Text("wallet_confirmation".localized)
                    .font(.inter(size: 18, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black3)
                Spacer()
                Button {
                    Router.dismiss()
                } label: {
                    Image("icon-btn-close")
                        .renderingMode(.template)
                        .foregroundColor(.LL.Neutrals.note)
                }
                .frame(width: 24, height: 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 64)
            
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
                .frame(height: 6)
            
            VStack {
                DeviceInfoItem(title: "application_tag".localized, detail: model.deviceInfo.userAgent)
                DeviceInfoItem(title: "ip_address_tag".localized, detail: model.deviceInfo.ip)
                DeviceInfoItem(title: "location".localized, detail: location)
            }
            .padding(.horizontal, 4)
            
            
            Spacer()
            
            WalletSendButtonView(allowEnable: .constant(true), buttonText: "hold_to_sync".localized) {
                viewModel.addDevice(with: model)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color(hex: "#282828", alpha: 1))
    }
    
    var location: String {
        var res = ""
        if model.deviceInfo.city != nil {
            res += model.deviceInfo.city!
        }
        if model.deviceInfo.country != nil {
            res += ",\(model.deviceInfo.country!)"
        }
        return res
    }
    
    func region() -> MKCoordinateRegion {
        let region = MKCoordinateRegion(center: coordinate(), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        return region
    }
    
    func annotations() -> [CLLocationCoordinate2D] {
        return [
            coordinate()
        ]
    }
    
    func coordinate() -> CLLocationCoordinate2D {
        guard let latitude = model.deviceInfo.lat, let longitude = model.deviceInfo.lon else {
            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}



#Preview {
    SyncAddDeviceView(model: RegisterRequest(username: "", accountKey: AccountKey(hashAlgo: 0, publicKey: "", signAlgo: 0), deviceInfo: DeviceInfoRequest(deviceId: "", ip: "192.168.0.1", name: "Flow Reference MacOS 8.4.1", type: "", userAgent: "Flow Reference MacOS 8.4.1", continent: "", continentCode: "", country: "US", countryCode: "", regionName: "", city: "New York ", district: "", zip: "", lat: 0, lon: 0, timezone: "", currency: "", isp: "", org: "")))
}

//
//  SyncAddDeviceView.swift
//  FRW
//
//  Created by cat on 2023/11/29.
//

import Flow
import MapKit
import SwiftUI
import SwiftUIX

struct SyncAddDeviceView: View {
    // MARK: Lifecycle

    init(viewModel: SyncAddDeviceViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: Internal

    @StateObject
    var viewModel: SyncAddDeviceViewModel

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Color.clear
                    .frame(width: 24, height: 24)
                Spacer()
                Text("wallet_confirmation".localized)
                    .font(.inter(size: 18, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black8)
                Spacer()
                Button {
                    Router.dismiss()
                } label: {
                    Image("icon_close_circle_gray")
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

            VStack(spacing: 8) {
                DeviceInfoItem(
                    title: "application_tag".localized,
                    detail: viewModel.model.deviceInfo.userAgent ?? ""
                )
                .frame(height: 24)
                DeviceInfoItem(
                    title: "ip_address_tag".localized,
                    detail: viewModel.model.deviceInfo.ip ?? ""
                )
                .frame(height: 24)
                DeviceInfoItem(title: "location".localized, detail: location)
                    .frame(height: 24)
            }
            .padding(.horizontal, 4)

            Spacer()

            WalletSendButtonView(
                allowEnable: .constant(true),
                buttonText: "hold_to_sync".localized
            ) {
                viewModel.addDevice()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color(hex: "#282828", alpha: 1))
    }

    var location: String {
        var res = ""
        if viewModel.model.deviceInfo.city != nil && !viewModel.model.deviceInfo.city!.isEmpty {
            res += viewModel.model.deviceInfo.city!
        }
        if viewModel.model.deviceInfo.country != nil && !viewModel.model.deviceInfo.country!
            .isEmpty {
            res += ",\(viewModel.model.deviceInfo.country!)"
        }
        return res
    }

    func region() -> MKCoordinateRegion {
        let region = MKCoordinateRegion(
            center: coordinate(),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        return region
    }

    func annotations() -> [CLLocationCoordinate2D] {
        [
            coordinate(),
        ]
    }

    func coordinate() -> CLLocationCoordinate2D {
        guard let latitude = viewModel.model.deviceInfo.lat,
              let longitude = viewModel.model.deviceInfo.lon
        else {
            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// #Preview {
//    SyncAddDeviceView(model: RegisterRequest(username: "", accountKey: AccountKey(hashAlgo: 0, publicKey: "", signAlgo: 0), deviceInfo: DeviceInfoRequest(deviceId: "", ip: "192.168.0.1", name: "Flow Wallet MacOS 8.4.1", type: "", userAgent: "Flow Wallet MacOS 8.4.1", continent: "", continentCode: "", country: "US", countryCode: "", regionName: "", city: "New York ", district: "", zip: "", lat: 0, lon: 0, timezone: "", currency: "", isp: "", org: "")))
// }

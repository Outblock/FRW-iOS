//
//  DevicesViewModel.swift
//  FRW
//
//  Created by cat on 2023/10/30.
//

import Foundation
import MapKit

class DevicesViewModel: ObservableObject {
    @Published var devices: [DeviceInfoModel] = []
    @Published var status: PageStatus = .loading
    @Published var showCurrent: Bool = false
    @Published var showOther: Bool = false

    @Published var current: DeviceInfoModel?

    init() {
        devices = [DeviceInfoModel.empty()]
        fetch()
    }

    func fetch() {
        Task {
            do {
                DispatchQueue.main.async {
                    self.status = .loading
                }
                let result = try await DeviceManager.shared.fetch()
                DispatchQueue.main.async {
                    self.devices = result.1
                    self.current = result.0
                    self.showCurrent = (self.current != nil)
                    self.showOther = self.devices.count > 0
                    self.status = .finished
                }
            } catch {
                DispatchQueue.main.async {
                    self.devices = []
                    self.current = nil
                    self.showCurrent = false
                    self.status = .finished
                }
                log.error("Fetch Devices \(error)")
            }
        }
    }
}

struct DeviceInfoModel: Codable, Identifiable {
    let city: String?
    let continent: String?
    let continentCode: String?
    let createdAt: String?
    let currency: String?
    let deviceName: String?
    let deviceType: Int?
    let district: String?
    let id: String?
    let ip: String?
    let isp: String?
    let lat: Double?
    let lon: Double?
    let org: String?
    let regionName: String?
    let updatedAt: String?
    let userAgent: String?
    let userId: String?
    let walletId: Int?
    let walletsandId: Int?
    let wallettestId: Int?
    let zip: String?
    let country: String?

    static func empty() -> DeviceInfoModel {
        DeviceInfoModel(city: "", continent: "", continentCode: "", createdAt: "", currency: "", deviceName: "", deviceType: nil, district: "", id: "", ip: "", isp: "", lat: 0.0, lon: 0.0, org: "", regionName: "", updatedAt: "", userAgent: "", userId: "", walletId: nil, walletsandId: nil, wallettestId: nil, zip: "", country: "")
    }

    // like iPhone 15 Pro Max
    func showName() -> String {
        return deviceName ?? ""
    }

    // like Flow Wallet macOS 8.4.1
    func showApp() -> String {
        return userAgent ?? ""
    }

    func showIP() -> String {
        return ip ?? ""
    }

    func showLocation() -> String {
        var res = ""
        if city != nil, !city!.isEmpty {
            res += city!
        }
        if country != nil, !country!.isEmpty {
            res += ",\(country!)"
        }
        return res
    }

    func showLocationAndDate() -> String {
        var res = ""
        if !showLocation().isEmpty {
            res = showLocation()
        }
        let date = showDate()
        if !date.isEmpty, !res.isEmpty {
            res += " · "
        }

        if !date.isEmpty {
            res += date
        }
        return res
    }

    func showDate() -> String {
        guard let created = updatedAt else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
        let date = dateFormatter.date(from: created)
        guard let date = date else { return "" }
        dateFormatter.dateFormat = "MMMM dd,yyyy"
        let res = dateFormatter.string(from: date)
        return res
    }

    func coordinate() -> CLLocationCoordinate2D {
        guard let latitude = lat, let longitude = lon else {
            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

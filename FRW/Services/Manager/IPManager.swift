//
//  IPManager.swift
//  FRW
//
//  Created by cat on 2023/10/30.
//

import Alamofire
import DeviceGuru
import Foundation
import UIKit

// MARK: - DeviceType

enum DeviceType: String {
    case other = ""
    case iOS = "1"
    case chrome = "2"

    // MARK: Lifecycle

    init(value: Int?) {
        switch value {
        case 1:
            self = .iOS
        case 2:
            self = .chrome
        default:
            self = .other
        }
    }

    // MARK: Internal

    var smallIcon: String {
        switch self {
        case .other:
            return "icon_key_manual"
        case .iOS:
            return "icon_key_phone"
        case .chrome:
            return "device_1"
        }
    }
}

// MARK: - IPManager

class IPManager {
    // MARK: Internal

    static let shared = IPManager()

    var info: IPResponse?

    func fetch() async {
        do {
            info = try await Network.request(FRWAPI.IP.info)
        } catch {
            log.error("Fetch IP \(error)")
        }
    }

    func toParams() -> DeviceInfoRequest {
        let info = DeviceInfoRequest(
            deviceId: UUIDManager.appUUID(),
            ip: ip,
            name: name,
            type: deviceType,
            userAgent: userAgent,
            continent: info?.continent,
            continentCode: info?.continentCode,
            country: info?.country,
            countryCode: info?.countryCode,
            regionName: info?.regionName,
            city: info?.city,
            district: info?.district,
            zip: info?.zip,
            lat: info?.lat,
            lon: info?.lon,
            timezone: info?.timezone,
            currency: info?.currency,
            isp: info?.isp,
            org: info?.org
        )

        return info
    }

    // MARK: Private

    private let osNameVersion: String = {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString =
            "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        let osName: String = {
            #if os(iOS)
                #if targetEnvironment(macCatalyst)
                    return "macOS(Catalyst)"
                #else
                    return "iOS"
                #endif
            #elseif os(watchOS)
                return "watchOS"
            #elseif os(tvOS)
                return "tvOS"
            #elseif os(macOS)
                return "macOS"
            #elseif os(Linux)
                return "Linux"
            #elseif os(Windows)
                return "Windows"
            #elseif os(Android)
                return "Android"
            #else
                return "Unknown"
            #endif
        }()

        return "\(osName) \(versionString)"
    }()

    private var ip: String {
        guard let str = info?.query else {
            return ""
        }
        return str
    }

    private var ipLocation: String {
        guard let city = info?.city, let country = info?.country else {
            return ""
        }
        return "\(city),\(country)"
    }

    private var name: String {
        guard let des = try? DeviceGuruImplementation().hardwareDescription() else { return "" }
        return des
    }

    private var userAgent: String {
        "Flow Wallet \(osNameVersion)"
    }

    private var deviceType: String {
        DeviceType.iOS.rawValue
    }
}

//
//  IPManager.swift
//  FRW
//
//  Created by cat on 2023/10/30.
//

import Foundation
import UIKit
import Alamofire
import DeviceGuru

class IPManager {
    static let shared = IPManager()
    var info: IPResponse?
    
    func fetch() async  {
        do {
            self.info = try await Network.request(FRWAPI.IP.info)
        }catch {
            log.error("Fetch IP \(error)")
        }
    }
    
    func toParams() -> DeviceInfoRequest {
        
        let info = DeviceInfoRequest(deviceId: UUIDManager.appUUID(),
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
                                     org: info?.org)
        
        return info
    }
    
    
    
    
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
        return "Flow Reference \(osNameVersion)"
    }
    
    private var deviceType: String {
        return "1"
    }
    
    private let osNameVersion: String = {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
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
}

//
//  String.swift
//  Flow Wallet
//
//  Created by Hao Fu on 8/1/22.
//

import Foundation
import UIKit
import CryptoKit
import Web3Core

extension String {
    var localized: String {
        let value = NSLocalizedString(self, comment: "")
        if value != self || NSLocale.preferredLanguages.first == "en" {
            return value
        }
        
        guard let path = Bundle.main.path(forResource: "en", ofType: "lproj"), let bundle = Bundle(path: path) else {
            return value
        }
        
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        return String.localizedStringWithFormat(localized, args)
    }

    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func matchRegex(_ regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, count))
            return matches.count > 0
        } catch {
            return false
        }
    }

    func removePrefix(_ prefix: String) -> String {
        if starts(with: prefix) {
            if let range = range(of: prefix) {
                let startIndex = range.upperBound
                return String(self[startIndex...])
            }
        }

        return self
    }
    
    func removeSuffix(_ suffix: String) -> String {
        if hasSuffix(suffix) {
            return String(self.dropLast(suffix.count))
        }
        
        return self
    }
    
    func replaceBeforeLast(_ delimiter: Character, replacement: String) -> String {
        if let index = self.lastIndex(of: delimiter) {
            return self.replacingOccurrences(of: String(delimiter), with: replacement, options: [], range: self.startIndex..<index)
        } else {
            return self
        }
    }
    
    var isNumber: Bool {
        return !isEmpty && Double.currencyFormatter.number(from: self) != nil
    }
    
    var isAddress: Bool {
        return !isEmpty && self.hasPrefix("0x") && self.count == 18
    }
    
    var isEVMAddress: Bool {
        return EthereumAddress.toChecksumAddress(self) != nil
    }
    
    var isFlowOrEVMAddress: Bool {
        return self.isEVMAddress || self.isAddress
    }
    
    var hexValue: [UInt8] {
        var startIndex = self.startIndex
        return (0 ..< count / 2).compactMap { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            return UInt8(self[startIndex ... endIndex], radix: 16)
        }
    }
    
    func width(withFont font: UIFont, maxWidth: CGFloat? = nil) -> CGFloat {
        let string = self as NSString
        let attr = [NSAttributedString.Key.font: font]
        let rect = string.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attr, context: nil)
        let width = ceil(rect.size.width)
        
        if let maxWidth = maxWidth {
            return min(width, maxWidth)
        } else {
            return width
        }
    }
    
    var md5: String {
        return Insecure.MD5.hash(data: self.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
    }
    
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
}

// MARK: - Firebase

extension String {
    func convertedAvatarString() -> String {
        if var comp = URLComponents(string: self) {
            if comp.host == "source.boringavatars.com" {
                comp.host = "lilico.app"
                comp.path = "/api/avatar\(comp.path)"
                return comp.url!.absoluteString
            }
        }

        if !starts(with: "https://firebasestorage.googleapis.com") {
            return self
        }

        if contains("alt=media") {
            return self
        }

        return "\(self)?alt=media"
    }
    
    func convertedSVGURL() -> URL? {
        guard let encodedString = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: "https://lilico.app/api/svg2png?url=\(encodedString)")
    }
}

// MARK: - Debug

extension String {
    /// print object memory address
    static func pointer(_ object: AnyObject?) -> String {
        guard let object = object else { return "nil" }
        let opaque: UnsafeMutableRawPointer = Unmanaged.passUnretained(object).toOpaque()
        return String(describing: opaque)
    }
}

// MARK: - Browser

extension String {
    var canOpenUrl: Bool {
        guard let url = URL(string: self), UIApplication.shared.canOpenURL(url) else { return false }
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: self)
    }
    
    var toSearchURL: URL? {
        var asURL = self
        if self.hasPrefix("http://") || self.hasPrefix("https://") {
            
        } else {
            asURL = "https://\(self)"
        }
        
        if let url = URL(string: asURL), asURL.canOpenUrl {
            return url
        }
        
        guard let encodedString = self.trim().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: "https://www.google.com/search?q=\(encodedString)")
    }
    
    func toFavIcon(size: Int = 256) -> URL? {
        guard let url = URL(string: self) else {
            return nil
        }
        
        let urlString = "https://double-indigo-crab.b-cdn.net/\(url.host ?? "")/\(size)"
        return URL(string: urlString)
    }
}


extension String {
    /// Determine string has hexadecimal prefix.
    /// - returns: `Bool` type.
    func hasHexPrefix() -> Bool {
        return hasPrefix("0x")
    }

    /// If string has hexadecimal prefix, remove it
    /// - returns: A string without hexadecimal prefix
    func stripHexPrefix() -> String {
        if hasPrefix("0x") {
            let indexStart = index(startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }

    /// Add hexadecimal prefix to a string.
    /// If it already has it, do nothing
    /// - returns: A string with hexadecimal prefix
    func addHexPrefix() -> String {
        if !hasPrefix("0x") {
            return "0x" + self
        }
        return self
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == utf16.count
        } else {
            return false
        }
    }

    func validateUrl() -> Bool {
        guard !contains("..") else { return false }

        let head = "((http|https)://)?([(w|W)]{3}+\\.)?"
        let tail = "\\.+[A-Za-z]{1,10}+(\\.)?+(/(.)*)?"
        let urlRegEx = head + "+(.)+" + tail

        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: trimmingCharacters(in: .whitespaces))
        //        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
    }

    //    func validateUrl() -> Bool {
    //        guard let url = URL(string: self) else {
    //            return false
    //        }
    //
    //        return UIApplication.shared.canOpenURL(url)
    //    }
    

    func addHttpsPrefix() -> String {
        if !hasPrefix("https://") {
            return "https://" + self
        }
        return self
    }

    func addHttpPrefix() -> String {
        if !hasPrefix("http://") {
            return "http://" + self
        }
        return self
    }
    
    func removeHTTPPrefix() -> String {
        if hasPrefix("http://") {
            return self.removePrefix("http://")
        }
        
        if hasPrefix("https://") {
            return self.removePrefix("https://")
        }
        
        return self
    }
}

// MARK: - FlowScan

extension String {
    var toFlowScanAccountDetailURL: URL? {
        var string = "https://flowscan.org/account/\(self)"
        if LocalUserDefaults.shared.flowNetwork == .testnet {
            string = "https://testnet.flowscan.org/account/\(self)"
        } else if LocalUserDefaults.shared.flowNetwork == .crescendo {
            string = "https://crescendo.flowscan.org/account/\(self)"
        } else if LocalUserDefaults.shared.flowNetwork == .previewnet {
            string = "https://previewnet.flowscan.org/account/\(self)"
        }
        
        return URL(string: string)
    }
    
    var toFlowScanTransactionDetailURL: URL? {
        var string = "https://flowdiver.io/tx/\(self)"
        if LocalUserDefaults.shared.flowNetwork == .testnet {
            string = "https://testnet.flowdiver.io/tx/\(self)"
        } else if LocalUserDefaults.shared.flowNetwork == .crescendo {
            string = "https://crescendo.flowscan.org/transaction/\(self)"
        } else if LocalUserDefaults.shared.flowNetwork == .previewnet {
            string = "https://previewnet.flowdiver.io/tx/\(self)"
        }
        
        return URL(string: string)
    }
}

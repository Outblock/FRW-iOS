//
//  SVGWebUIView.swift
//  Flow Wallet
//
//  Created by Hao Fu on 22/8/2022.
//

import Foundation
import UIKit
import WebKit

class SVGWebUIView: UIView {
    // MARK: Lifecycle

    required init(urlString: String) {
        self.urlString = urlString
        // Setting up the view can be done here
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    var urlString: String
    var container = UIView()

    func setupView() {
        // Can do the setup of the view, including adding subviews

        guard let url = URL(string: urlString),
              let svg = try? String(contentsOf: url)
        else {
            return
        }

        let prefs = WKPreferences()

        prefs.javaScriptCanOpenWindowsAutomatically = false

        let config = WKWebViewConfiguration()
        config.preferences = prefs
        config.allowsAirPlayForMediaPlayback = false

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false

        let html = "<div style=\"width: 100%; height: 100%;\">\(rewriteSVGSize(svg))</div>"
        webView.loadHTMLString(html, baseURL: nil)

        // Sometimes necessary to make things show up initially. No idea why.
        DispatchQueue.main.async {
            let old = webView.frame
            webView.frame = .zero
            webView.frame = old
        }

        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(webView)
    }

    // MARK: Private

    /// A hacky way to patch the size in the SVG root tag.
    private func rewriteSVGSize(_ string: String) -> String {
        guard let startRange = string.range(of: "<svg") else { return string }
        let remainder = startRange.upperBound..<string.endIndex
        guard let endRange = string.range(of: ">", range: remainder) else {
            return string
        }

        let tagRange = startRange.lowerBound..<endRange.upperBound
        let oldTag = string[tagRange]

        var attrs: [String: String] = {
            final class Handler: NSObject, XMLParserDelegate {
                var attrs: [String: String]?

                func parser(
                    _: XMLParser,
                    didStartElement _: String,
                    namespaceURI _: String?,
                    qualifiedName _: String?,
                    attributes: [String: String]
                ) {
                    self.attrs = attributes
                }
            }
            let parser = XMLParser(data: Data((string[tagRange] + "</svg>").utf8))
            let handler = Handler()
            parser.delegate = handler

            guard parser.parse() else { return [:] }
            return handler.attrs ?? [:]
        }()

        if attrs["viewBox"] == nil,
           attrs["width"] != nil || attrs["height"] != nil { // convert to viewBox
            let w = attrs.removeValue(forKey: "width") ?? "100%"
            let h = attrs.removeValue(forKey: "height") ?? "100%"
            let x = attrs.removeValue(forKey: "x") ?? "0"
            let y = attrs.removeValue(forKey: "y") ?? "0"
            attrs["viewBox"] = "\(x) \(y) \(w) \(h)"
        }
        attrs.removeValue(forKey: "x")
        attrs.removeValue(forKey: "y")
        attrs["width"] = "100%"
        attrs["height"] = "100%"

        func renderTag(_ tag: String, attributes: [String: String]) -> String {
            var ms = "<\(tag)"
            for (key, value) in attributes {
                ms += " \(key)=\""
                ms += value
                    .replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;")
                    .replacingOccurrences(of: "'", with: "&apos;")
                    .replacingOccurrences(of: "\"", with: "&quot;")
                ms += "\""
            }
            ms += ">"
            return ms
        }

        let newTag = renderTag("svg", attributes: attrs)
        return newTag == oldTag
            ? string
            : string.replacingCharacters(in: tagRange, with: newTag)
    }
}

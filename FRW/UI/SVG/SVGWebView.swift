//
//  SVGWebV.swift
//  Flow Wallet
//
//  Created by Hao Fu on 22/8/2022.
//

import SwiftUI
import WebKit

// MARK: - SVGWebView

/**
 * Display an SVG using a `WKWebView`.
 *
 * Used by [SVG Shaper for SwiftUI](https://zeezide.de/en/products/svgshaper/)
 * to display the SVG preview in the sidebar.
 *
 * This patches the XML of the SVG to fit the WebView contents.
 *
 * IMPORTANT: On macOS `WKWebView` requires the "outgoing internet connection"
 *            entitlement to operate, otherwise it'll show up blank.
 * Xcode Previews do not work quite right with the iOS variant, best to test in
 * a real simulator.
 */
public struct SVGWebView: View {
    // MARK: Lifecycle

    public init(svg: String) { self.svg = svg }

    // MARK: Public

    public var body: some View {
        WebView(
            html:
            "<div style=\"width: 100%; height: 100%;\">\(rewriteSVGSize(svg))</div>"
        )
    }

    // MARK: Internal

    #if os(macOS)
    typealias UXViewRepresentable = NSViewRepresentable
    #else
    typealias UXViewRepresentable = UIViewRepresentable
    #endif

    // MARK: Private

    private struct WebView: UXViewRepresentable {
        // MARK: Internal

        let html: String

        #if os(macOS)
        func makeNSView(context _: Context) -> WKWebView {
            makeWebView()
        }

        func updateNSView(_ webView: WKWebView, context: Context) {
            updateWebView(webView, context: context)
        }
        #else // iOS etc
        func makeUIView(context _: Context) -> WKWebView {
            makeWebView()
        }

        func updateUIView(_ webView: WKWebView, context: Context) {
            updateWebView(webView, context: context)
        }
        #endif

        // MARK: Private

        private func makeWebView() -> WKWebView {
            let prefs = WKPreferences()
            #if os(macOS)
            if #available(macOS 10.5, *) {} else { prefs.javaEnabled = false }
            #endif
            if #available(macOS 11, *) {} else { prefs.javaScriptEnabled = false }
            prefs.javaScriptCanOpenWindowsAutomatically = false

            let config = WKWebViewConfiguration()
            config.preferences = prefs
            config.allowsAirPlayForMediaPlayback = false

            let bodyStyle = "body { margin:0; }"
            let source =
                "var node = document.createElement(\"style\"); node.innerHTML = \"\(bodyStyle)\";document.body.appendChild(node);"

            let script = WKUserScript(
                source: source,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            )

            config.userContentController.addUserScript(script)

            if #available(macOS 10.5, *) {
                let pagePrefs: WKWebpagePreferences = {
                    let prefs = WKWebpagePreferences()
                    prefs.preferredContentMode = .desktop
                    if #available(macOS 11, *) {
                        prefs.allowsContentJavaScript = false
                    }
                    return prefs
                }()
                config.defaultWebpagePreferences = pagePrefs
            }

            let webView = WKWebView(frame: .zero, configuration: config)
            #if !os(macOS)
            webView.scrollView.isScrollEnabled = false
            #endif

            webView.loadHTMLString(html, baseURL: nil)

            // Sometimes necessary to make things show up initially. No idea why.
            DispatchQueue.main.async {
                let old = webView.frame
                webView.frame = .zero
                webView.frame = old
            }

            webView.backgroundColor = .clear
            webView.isOpaque = false
            webView.scrollView.backgroundColor = UIColor.clear
            webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

            return webView
        }

        private func updateWebView(_ webView: WKWebView, context _: Context) {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    private let svg: String

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

        if attrs["viewBox"] == nil &&
            (attrs["width"] != nil || attrs["height"] != nil) { // convert to viewBox
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

// MARK: - SVGWebView_Previews

struct SVGWebView_Previews: PreviewProvider {
    static var previews: some View {
        SVGWebView(
            svg:
            """
            <svg viewBox="0 0 100 100">
              <rect x="10" y="10" width="80" height="80"
                    fill="gold" stroke="blue" stroke-width="4" />
            </svg>
            """
        )
        .frame(width: 300, height: 200)

        SVGWebView(
            svg:
            """
            <svg width="120" height="120" version="1.1" xmlns="http://www.w3.org/2000/svg">
              <defs>
                  <linearGradient id="Gradient1">
                    <stop offset="0%"   stop-color="red"/>
                    <stop offset="50%"  stop-color="black" stop-opacity="0"/>
                    <stop offset="100%" stop-color="blue"/>
                  </linearGradient>
              </defs>
              <rect x="10" y="10" rx="15" ry="15" width="100" height="100"
                    fill="url(#Gradient1)" />
            </svg>
            """
        )
        .frame(width: 200, height: 200)
    }
}

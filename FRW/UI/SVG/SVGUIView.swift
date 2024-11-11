//
//  Untitled.swift
//  FRW
//
//  Created by cat on 2024/9/23.
//

import WebKit

class SVGUIView: UIView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildView()
    }

    // MARK: Internal

    var svg: String?
    lazy var webView: WKWebView = {
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
        webView.isUserInteractionEnabled = false
        return webView
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = bounds
    }

    func loadSVG(svg: String) {
        let html = "<div style=\"width: 100%; height: 100%;\">\(rewriteSVGSize(svg))</div>"
        webView.loadHTMLString(html, baseURL: nil)
    }

    // MARK: Private

    private var html: String = ""

    private func buildView() {
        addSubviews(webView)
    }

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

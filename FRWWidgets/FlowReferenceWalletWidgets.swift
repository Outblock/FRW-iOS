//
//  Flow WalletWidgets.swift
//  Flow WalletWidgets
//
//  Created by Selina on 20/12/2022.
//

import Kingfisher
import SwiftUI
import WidgetKit

extension String {
    var localized: String {
        let value = NSLocalizedString(self, comment: "")
        if value != self || NSLocale.preferredLanguages.first == "en" {
            return value
        }

        guard let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
              let bundle = Bundle(path: path)
        else {
            return value
        }

        return NSLocalizedString(self, bundle: bundle, comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        String.localizedStringWithFormat(localized, args)
    }
}

// MARK: - Provider

struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), image: nil)
    }

    func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), image: nil)
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        guard let userDefaults = groupUserDefaults(),
              let url = userDefaults.url(forKey: FirstFavNFTImageURL)
        else {
            let entry = SimpleEntry(date: Date(), image: nil)
            completion(Timeline(entries: [entry], policy: .never))
            return
        }

        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case let .success(value):
                let entry = SimpleEntry(date: Date(), image: value.image)
                completion(Timeline(entries: [entry], policy: .never))
            case let .failure(error):
                debugPrint("getTimeline fetch image failed: \(error) ")
                let entry = SimpleEntry(date: Date(), image: nil)
                completion(Timeline(entries: [entry], policy: .never))
            }
        }
    }
}

// MARK: - SimpleEntry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
}

// MARK: - LilicoWidgetsEntryView

struct LilicoWidgetsEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        if let image = entry.image {
            SmallView(image: image)
        } else {
            PlaceholderView()
        }
    }
}

// MARK: - PlaceholderView

struct PlaceholderView: View {
    var body: some View {
        Image("logo-new")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - SmallView

struct SmallView: View {
    let image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - FlowReferenceWalletWidgets

struct FlowReferenceWalletWidgets: Widget {
    let kind: String = "FlowReferenceWallet"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LilicoWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("widget_name".localized)
        .description("widget_desc".localized)
    }
}

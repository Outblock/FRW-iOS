//
//  Flow Reference WalletWidgets.swift
//  Flow Reference WalletWidgets
//
//  Created by Selina on 20/12/2022.
//

import WidgetKit
import SwiftUI
import Kingfisher

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
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), image: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), image: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let userDefaults = groupUserDefaults(), let url = userDefaults.url(forKey: FirstFavNFTImageURL) else {
            let entry = SimpleEntry(date: Date(), image: nil)
            completion(Timeline(entries: [entry], policy: .never))
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                let entry = SimpleEntry(date: Date(), image: value.image)
                completion(Timeline(entries: [entry], policy: .never))
            case .failure(let error):
                debugPrint("getTimeline fetch image failed: \(error) ")
                let entry = SimpleEntry(date: Date(), image: nil)
                completion(Timeline(entries: [entry], policy: .never))
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
}

struct LilicoWidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if let image = entry.image {
            SmallView(image: image)
        } else {
            PlaceholderView()
        }
    }
}

struct PlaceholderView: View {
    var body: some View {
        Image("logo-new")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SmallView: View {
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LilicoWidgets: Widget {
    let kind: String = "LilicoWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LilicoWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("widget_name".localized)
        .description("widget_desc".localized)
    }
}

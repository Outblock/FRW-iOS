//
//  BrowserSearchInputViewController.swift
//  Flow Wallet
//
//  Created by Selina on 1/9/2022.
//

import SnapKit
import UIKit

private let RecommendCellHeight: CGFloat = 50
private let DAppCellHeight: CGFloat = 60

// MARK: - Section

private enum Section: Int {
    case dapp
    case recommend
}

// MARK: - BrowserSearchInputViewController

class BrowserSearchInputViewController: UIViewController {
    // MARK: Public

    public func setSearchText(text: String? = "") {
        searchingText = text ?? ""
        inputBar.textField.text = text
        inputBar.reloadView()
        if let str = text, !str.isEmpty {
            inputBar.textField.becomeFirstResponder()
            inputBar.textField.selectAll(self)
        }
    }

    // MARK: Internal

    var selectTextCallback: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadBgPaths()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !inputBar.textField.isFirstResponder {
            inputBar.textField.becomeFirstResponder()
        }
    }

    // MARK: Private

    private var recommendArray: [RecommendItemModel] = []
    private var remoteDAppList: [DAppModel] = []
    private var dappArray: [DAppModel] = []
    private var searchingText: String = ""

    private var timer: Timer?

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "DeepBackground")
        return view
    }()

    private lazy var inputBar: BrowserSearchInputBar = {
        let view = BrowserSearchInputBar()
        view.cancelBtn.addTarget(self, action: #selector(onCancelBtnClick), for: .touchUpInside)
        view.textDidChangedCallback = { [weak self] text in
            self?.searchTextDidChanged(text)
        }
        view.textDidReturnCallback = { [weak self] text in
            self?.selectTextCallback?(text)
        }

        return view
    }()

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = UIColor(named: "Background")
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.delegate = self
        view.dataSource = self

        view.register(
            BrowserSearchItemCell.self,
            forCellWithReuseIdentifier: "BrowserSearchItemCell"
        )
        view.register(
            BrowserSearchDAppItemCell.self,
            forCellWithReuseIdentifier: "BrowserSearchDAppItemCell"
        )
        return view
    }()

    private lazy var contentViewBgMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()

    private func setup() {
        view.backgroundColor = .black

        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalToSuperview()
        }

        contentView.addSubview(inputBar)
        inputBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(contentView.keyboardLayoutGuide.snp.top)
        }

        contentView.layer.mask = contentViewBgMaskLayer

        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(inputBar.snp.top)
        }

        collectionView.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi))

        hero.isEnabled = true
    }

    private func reloadBgPaths() {
        contentViewBgMaskLayer.frame = contentView.bounds
        let cPath = UIBezierPath(
            roundedRect: contentView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 24.0, height: 24.0)
        )
        contentViewBgMaskLayer.path = cPath.cgPath
    }
}

extension BrowserSearchInputViewController {
    @objc
    private func onCancelBtnClick() {
        close()
    }

    private func close() {
//        if self.parent != nil {
//            self.removeFromParentViewController()
//        }

        if let navi = navigationController {
            navi.popViewController(animated: false)
        } else {
            dismiss(animated: false)
        }
    }
}

extension BrowserSearchInputViewController {
    private func searchTextDidChanged(_ text: String) {
        clearCurrentRecommend()

        let trimString = text.trim()
        if trimString.isEmpty {
            return
        }

        searchingText = trimString
        startTimer()
    }

    static func makeUrlIfNeeded(urlString: String) -> String {
        var urlString = urlString

        if !urlString.hasPrefix("http://"), !urlString.hasPrefix("https://") {
            urlString = urlString.addHttpsPrefix()
        }

        if urlString.validateUrl() {
            return urlString
        }

        if urlString.hasPrefix("http://") {
            urlString = String(urlString.dropFirst(7))
        }

        if urlString.hasPrefix("https://") {
            urlString = String(urlString.dropFirst(8))
        }

        let engine = "https://www.google.com/search?q="

        urlString = urlString
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        urlString = "\(engine)\(urlString)"

        return urlString
    }

    private func doSearch() {
        let currentText = searchingText

        Task {
            do {
                let result: [RecommendItemModel] = try await Network
                    .requestWithRawModel(FRWAPI.Browser.recommend(currentText))

                if self.searchingText != currentText {
                    // outdate result
                    return
                }

                DispatchQueue.main.async {
                    self.recommendArray = result
                    self.collectionView.reloadData()
                }
            } catch {
                if self.searchingText != currentText {
                    // outdate result
                    return
                }

                HUD.error(title: "browser_search_failed".localized)
            }
        }
    }

    private func doSearchDApp() {
        let currentText = searchingText

        Task {
            do {
                var list = self.remoteDAppList
                if list.isEmpty {
                    list = try await FirebaseConfig.dapp.fetch(decoder: JSONDecoder())
                    self.remoteDAppList = list
                }

                if self.searchingText != currentText {
                    // outdate result
                    return
                }

                var result = list
                    .filter {
                        $0.name.lowercased().contains(currentText.lowercased()) || $0.url
                            .absoluteString
                            .lowercased().contains(currentText.lowercased())
                    }

                if result.count > 5 {
                    // max 5
                    result = result.dropLast(result.count - 5)
                }

                DispatchQueue.main.async {
                    self.dappArray = result
                    self.collectionView.reloadData()
                }
            } catch {
                if self.searchingText != currentText {
                    // outdate result
                    return
                }
            }
        }
    }

    private func startTimer() {
        stopTimer()

        let t = Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self,
            selector: #selector(onTimer),
            userInfo: nil,
            repeats: false
        )
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }

    @objc
    private func onTimer() {
        doSearch()
        doSearchDApp()
    }

    private func clearCurrentRecommend() {
        searchingText = ""
        recommendArray.removeAll()
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension BrowserSearchInputViewController: UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        2
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .recommend:
            return recommendArray.count
        case .dapp:
            return dappArray.count
        default:
            return 0
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .recommend:
            let model = recommendArray[indexPath.item]
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "BrowserSearchItemCell",
                for: indexPath
            ) as! BrowserSearchItemCell
            cell.config(model, inputText: searchingText)
            cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            return cell
        case .dapp:
            let model = dappArray[indexPath.item]
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "BrowserSearchDAppItemCell",
                for: indexPath
            ) as! BrowserSearchDAppItemCell
            cell.config(model)
            cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .recommend:
            let model = recommendArray[indexPath.item]
            selectTextCallback?(model.phrase)
        case .dapp:
            let model = dappArray[indexPath.item]
            selectTextCallback?(model.url.absoluteString)
        default:
            break
        }
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        switch Section(rawValue: indexPath.section) {
        case .recommend:
            return CGSize(
                width: Router.coordinator.window.bounds.size.width,
                height: RecommendCellHeight
            )
        case .dapp:
            return CGSize(
                width: Router.coordinator.window.bounds.size.width,
                height: DAppCellHeight
            )
        default:
            return .zero
        }
    }
}

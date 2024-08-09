//
//  ResizableView.swift
//
//
//  Created by Jin Kim on 6/13/22.
//

import Foundation
import UIKit
import SnapKit

public class DebugViewer: ResizableView {
    public static let shared = DebugViewer()
    public var theme: Theme = .dark {
        didSet {
            updateTheme()
        }
    }
    
    private var data: [String: CappedCollection<DebugViewModel>] = [:]
    private var selectedCategory: String?
    
    private var latestSize = CGSize(width: 300, height: 300)
    private let buttonSize = CGSize(width: 28, height: 28)

    private let collapseButton = UIButton(frame: .zero)
    private let squareButton = UIView()
    private let draggablePoint = UIView(frame: .zero)
    private let shapeLayer = CAShapeLayer()
    private let tableView = UITableView()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(DebugViewCategoryCell.self, forCellWithReuseIdentifier: DebugViewCategoryCell.description())
        return collectionView
    }()
    
    private lazy var clearAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.font = UIFont(name: "CourierNewPS-BoldMT", size: 12.0)
        button.addTarget(self, action: #selector(clearAll), for: .touchUpInside)
        return button
    }()

    public enum Theme {
        case dark
        case light
        
        var baseColor: UIColor {
            switch self {
            case .dark:
                return .black
            case .light:
                return .white
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .dark:
                return UIColor.black.withAlphaComponent(0.7)
            case .light:
                return UIColor.white.withAlphaComponent(0.8)
            }
        }
        
        var fontColor: UIColor {
            switch self {
            case .dark:
                return .white
            case .light:
                return .black
            }
        }
    }
    
    private lazy var viewerFrameKey: String = {
        return "com.dapperlabs.mobile.debug-viewer.frame.\(String(describing: type(of: self)))"
    }()

    private var items: CappedCollection<DebugViewModel> {
        guard let category = selectedCategory else { return data.first?.value ?? [] }
        return data[category] ?? []
    }
    
    override public var frame: CGRect {
        didSet {
            guard frame != .zero else { return }
            UserDefaults.standard.setValue(NSCoder.string(for: frame), forKey: viewerFrameKey)
        }
    }

    override public var center: CGPoint {
        didSet {
            guard frame != .zero else { return }
            UserDefaults.standard.setValue(NSCoder.string(for: frame), forKey: viewerFrameKey)
        }
    }

    private func updateTheme() {
        layer.borderColor = theme.baseColor.cgColor
        layer.borderWidth = 2.0
        backgroundColor = theme.backgroundColor
        
        collapseButton.backgroundColor = theme.baseColor
        squareButton.backgroundColor = theme.fontColor
        
        shapeLayer.strokeColor = layer.borderColor
        shapeLayer.fillColor = theme.fontColor.withAlphaComponent(0.7).cgColor
        
        clearAllButton.setTitleColor(theme.fontColor, for: .normal)
        clearAllButton.backgroundColor = theme.baseColor

        collectionView.reloadData()
        tableView.reloadData()
    }
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        isUserInteractionEnabled = true
        clipsToBounds = true
        
        minSubviewSize = buttonSize
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.indicatorStyle = .white
        tableView.register(DebugViewCell.self, forCellReuseIdentifier: DebugViewCell.description())
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(buttonSize.height)
            make.left.right.bottom.equalToSuperview()
        }

        draggablePoint.frame = CGRect(origin: .zero, size: buttonSize)
        draggablePoint.backgroundColor = .clear
        addSubview(draggablePoint)
        draggablePoint.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.size.equalTo(buttonSize)
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 8, y: buttonSize.height))
        path.addLine(to: CGPoint(x: buttonSize.width, y: buttonSize.height))
        path.addLine(to: CGPoint(x: buttonSize.width, y: 8))
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 0
        draggablePoint.layer.addSublayer(shapeLayer)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.alignment = .center
        
        addSubview(stackView)
        stackView.addArrangedSubview(collapseButton)
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(clearAllButton)
        
        stackView.snp.makeConstraints { make in
            make.height.equalTo(buttonSize.height)
            make.left.right.top.equalToSuperview()
        }
        
        collapseButton.addTarget(self, action: #selector(didPressCollapseButton), for: .touchUpInside)

        collapseButton.snp.makeConstraints { make in
            make.size.equalTo(buttonSize)
        }

        squareButton.isUserInteractionEnabled = false
        collapseButton.addSubview(squareButton)
        squareButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(collapseButton).multipliedBy(0.4)
        }

        clearAllButton.sizeToFit()
        clearAllButton.layer.cornerRadius = (buttonSize.height - 4) / 2
        clearAllButton.snp.makeConstraints { make in
            make.height.equalTo(buttonSize.height - 4)
            make.width.equalTo(clearAllButton.frame.width + 20)
            make.centerY.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }

        addPanGestureRecoginizer(collapseButton)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyWindowChanged),
            name: UIWindow.didResignKeyNotification,
            object: nil
        )
        
        updateTheme()
    }

    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addPanGestureRecoginizer(_ view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(_:)))
        view.addGestureRecognizer(panGesture)
    }

    @objc private func viewDidPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self)
    }

    private var isCollapsed: Bool = false {
        didSet {
            collectionView.isHidden = isCollapsed
            clearAllButton.isHidden = isCollapsed
            tableView.isHidden = isCollapsed
        }
    }
    
    @objc private func didPressCollapseButton() {
        if !isCollapsed {
            latestSize = frame.size
        }
        let targetSize = isCollapsed ? latestSize : collapseButton.frame.size
        isCollapsed = !isCollapsed
        UIView.animate(withDuration: 0.1) {
            self.frame.size = targetSize
        } completion: { (true) in
        }
    }

    private var keyWindow: UIWindow? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
    
    @objc private func keyWindowChanged() {
        guard superview != keyWindow else { return }
        removeFromSuperview()
        keyWindow?.addSubview(self)
    }

    public func show(theme: Theme = .dark) {
        self.theme = theme
        if superview == nil {
            keyWindow?.addSubview(self)
        }
        if let storedFrame = UserDefaults.standard.string(forKey: viewerFrameKey),
            NSCoder.cgRect(for: storedFrame) != CGRect.zero
        {
            frame = NSCoder.cgRect(for: storedFrame)
        } else {
            frame.size = latestSize
            center = superview!.center
        }
        isCollapsed = frame.size == buttonSize
        isHidden = false
        alwaysShowOnTop()
    }

    @objc public func close() {
        isHidden = true
        UserDefaults.standard.removeObject(forKey: viewerFrameKey)
    }

    public func alwaysShowOnTop() {
        guard !isHidden else { return }
        keyWindow?.bringSubviewToFront(self)
    }
    
    public func addViewModel(category: String, viewModel: DebugViewModel) {
        var dataSource: CappedCollection<DebugViewModel> = data[category] ?? CappedCollection(elements: [], maxCount: 100)
        dataSource.append(viewModel)
        data[category] = dataSource
        if selectedCategory == nil {
            selectedCategory = category
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            if let count = self?.items.count, count > 1 {
                self?.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    @objc private func clearAll() {
        for ( category , collection) in data {
            var mutableCollection = collection
            mutableCollection.removeAllElements()
            data[category] = mutableCollection
        }
        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension DebugViewer: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count > section {
            let item = items[section]
            return item.showDetails ? 2 : 1
        }
        return 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        let cell: DebugViewCell = tableView.dequeueReusableCell(withIdentifier: DebugViewCell.description(), for: indexPath) as! DebugViewCell
        cell.backgroundColor = (indexPath.section % 2) == 0 ? theme.baseColor.withAlphaComponent(0.6) : theme.baseColor.withAlphaComponent(0.3)
        let showDetails = indexPath.row == 1
        cell.configure(event: item, showDetails: showDetails, theme: theme)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section]
        if !item.detail.isEmpty {
            item.showDetails = !item.showDetails
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = items[indexPath.section]
        let contextItem = UIContextualAction(style: .normal, title: "Copy") {  (contextualAction, view, boolValue) in
            if indexPath.row == 0 {
                UIPasteboard.general.string = item.name
            } else {
                UIPasteboard.general.string = item.detail
            }
            boolValue(true)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        return swipeActions
    }
}

class DebugViewCell: UITableViewCell {
    static var font = UIFont(name: "CourierNewPS-BoldMT", size: 10)!
    static var detailFont = UIFont(name: "CourierNewPS-BoldMT", size: 8)!

    override init(
        style: UITableViewCell.CellStyle, reuseIdentifier: String?
    ) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        textLabel?.numberOfLines = 0

        textLabel?.snp.remakeConstraints({ (make) in
            make.top.equalToSuperview().offset(7)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-7)
        })
    }

    required init?(
        coder aDecoder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(event: DebugViewModel, showDetails: Bool = false, theme: DebugViewer.Theme) {
        textLabel?.textColor = theme.fontColor
        if showDetails {
            textLabel?.font = DebugViewCell.detailFont
            textLabel?.text = event.detail
            textLabel?.snp.updateConstraints({ make in
                make.top.equalToSuperview().offset(0)
            })
        } else {
            textLabel?.font = DebugViewCell.font
            textLabel?.text = event.name
            textLabel?.snp.updateConstraints({ make in
                make.top.equalToSuperview().offset(7)
            })
        }
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate

extension DebugViewer: UICollectionViewDataSource {
    private func category(_ indexPath: IndexPath) -> String {
        let list = Array(data.keys).sorted()
        if list.count <= indexPath.item {
            return "default"
        }
        return list[indexPath.item]
    }
    
    private func isCurrent(_ indexPath: IndexPath) -> Bool {
        guard let selectedCategory = selectedCategory else { return indexPath.item == 0 }
        return selectedCategory == category(indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.keys.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DebugViewCategoryCell.description(), for: indexPath) as! DebugViewCategoryCell
        cell.theme = theme
        cell.category = category(indexPath)
        cell.current = isCurrent(indexPath)
        return cell
    }
}

extension DebugViewer: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = category(indexPath)
        tableView.reloadData()
        collectionView.reloadSections(IndexSet(integer: 0))
    }
}

extension DebugViewer: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = category(indexPath)
        let boundingRect = category.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: buttonSize.height),
                              options: [.usesLineFragmentOrigin, .usesFontLeading],
                              context: nil)
        return CGSize(width: boundingRect.width + 40, height: buttonSize.height)
    }
}

class DebugViewCategoryCell: UICollectionViewCell {
    private let label = UILabel(frame: .zero)
    var category: String? {
        didSet {
            label.text = category
        }
    }
    var current: Bool = false {
        didSet {
            contentView.backgroundColor = current ? theme.baseColor : .clear
        }
    }
    var theme: DebugViewer.Theme = .dark {
        didSet {
            label.textColor = theme.fontColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .black
        
        label.font = UIFont(name: "CourierNewPS-BoldMT", size: 12.0)
        label.textAlignment = .center
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

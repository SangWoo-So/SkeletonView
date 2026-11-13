//
//  SkeletonDiffableOverlay.swift
//  SkeletonView-iOS
//
//  Copyright © 2017 SkeletonView. All rights reserved.
//

import UIKit

// A diffable data source refuses to `apply` when its view's `dataSource` has been replaced,
// so for diffable data sources the dummy data source can't be used. Instead, the skeleton is
// drawn on an overlay view placed above the original one, which is hidden but left untouched.

struct SkeletonCellRegistration {
    enum Source {
        case cellClass(AnyClass?)
        case nib(UINib?)
        /// Table views only: several cell classes, picked per row
        case cellClasses([(type: AnyClass, identifier: ReusableCellIdentifier)])
    }

    let source: Source
    let identifier: ReusableCellIdentifier
    let numberOfSections: Int
    /// `automaticNumberOfSkeletonRows` / `automaticNumberOfSkeletonItems` fills the view
    let numberOfItems: Int
    /// Table views only: height of the skeleton rows. `nil` uses the table view's heights
    var rowHeight: CGFloat?
    /// Table views only: section headers of the overlay (skeletonized like the cells)
    var viewForHeaderInSection: ((Int) -> UIView?)?
    var heightForHeaderInSection: ((Int) -> CGFloat)?
    /// Table views only, with `cellClasses`: identifier of each row. `nil`: section N uses the Nth class (the last one beyond)
    var cellIdentifierForRowAt: ((IndexPath) -> ReusableCellIdentifier)?
    /// Table views only: called on each skeleton cell before it's skeletonized
    var prepareCellForSkeleton: ((UITableViewCell, IndexPath) -> Void)?
}

enum DiffableOverlayAssociatedKeys {
    static var cellRegistration = "skeletonCellRegistration"
    static var overlay = "skeletonOverlay"
    static var overlayDataSource = "skeletonOverlayDataSource"
    static var overlayDelegate = "skeletonOverlayDelegate"
    static var wasHidden = "skeletonOverlayWasHidden"
}

/// `UITableViewDiffableDataSource` and `UICollectionViewDiffableDataSource` are generic classes,
/// so they can't be checked with `is`. We look for them in the class hierarchy instead.
func isDiffableDataSource(_ object: AnyObject?, className: String) -> Bool {
    guard let object = object else { return false }
    var currentClass: AnyClass? = type(of: object)
    while let cls = currentClass {
        if NSStringFromClass(cls).contains(className) { return true }
        currentClass = class_getSuperclass(cls)
    }
    return false
}

// MARK: - Overlay management

extension UIScrollView {

    /// Created once and reused: it's only removed from the view hierarchy when the skeleton is hidden.
    var skeletonOverlay: UIScrollView? {
        get { return ao_get(pkey: &DiffableOverlayAssociatedKeys.overlay) as? UIScrollView }
        set { objc_setAssociatedObject(self, &DiffableOverlayAssociatedKeys.overlay, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var wasHiddenBeforeSkeletonOverlay: Bool {
        get { return ao_get(pkey: &DiffableOverlayAssociatedKeys.wasHidden) as? Bool ?? false }
        set { ao_set(newValue, pkey: &DiffableOverlayAssociatedKeys.wasHidden) }
    }

    func installSkeletonOverlay(_ overlay: UIScrollView) -> Bool {
        guard let superview = superview,
              let config = _currentSkeletonConfig else {
            return false
        }

        overlay.frame = frame
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isSkeletonable = true
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = backgroundColor
        overlay.contentInset = contentInset
        if #available(iOS 11.0, tvOS 11.0, *) {
            overlay.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
        }

        superview.insertSubview(overlay, aboveSubview: self)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // `isHiddenWhenSkeletonIsActive` has already hidden the view, and will show it again on hide
        wasHiddenBeforeSkeletonOverlay = isHidden && !isHiddenWhenSkeletonIsActive
        isHidden = true
        skeletonOverlay = overlay

        overlay.showSkeleton(skeletonConfig: config, notifyDelegate: false)
        return true
    }

    var isSkeletonOverlayInstalled: Bool {
        return skeletonOverlay?.superview != nil
    }

    func updateSkeletonOverlay() -> Bool {
        guard isSkeletonOverlayInstalled, let overlay = skeletonOverlay else { return false }
        if let config = _currentSkeletonConfig {
            overlay.updateSkeleton(skeletonConfig: config, notifyDelegate: false)
        }
        return true
    }

    func removeSkeletonOverlay() -> Bool {
        guard isSkeletonOverlayInstalled, let overlay = skeletonOverlay else { return false }
        overlay.recursiveHideSkeleton(reloadDataAfter: false, transition: .none)
        overlay.removeFromSuperview()
        isHidden = wasHiddenBeforeSkeletonOverlay
        return true
    }
}

// MARK: - Overlay views

// The skeleton is added to a cell as soon as it's dequeued, when its subviews still have a zero size.
// Resizing the skeleton layers afterwards relies on the global `layoutSubviews` swizzle, which is applied
// asynchronously and removed app wide as soon as any view hides its skeleton. So the overlays resize
// the skeletons of their cells themselves, once the cells are laid out.

final class SkeletonOverlayTableView: UITableView {
    private var isLayingOutSkeleton = false

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews() // cells are created and skeletonized here
        guard sk.isSkeletonActive, !isLayingOutSkeleton else { return }
        isLayingOutSkeleton = true
        defer { isLayingOutSkeleton = false }
        let headers = (delegate as? SkeletonOverlayTableViewHeaderDelegate)?.headerViews.values.map { $0 } ?? []
        (visibleCells + headers).forEach {
            $0.layoutIfNeeded()
            $0.layoutSkeletonIfNeeded()
        }
    }
}

final class SkeletonOverlayCollectionView: UICollectionView {
    private var isLayingOutSkeleton = false

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews() // cells are created and skeletonized here
        guard sk.isSkeletonActive, !isLayingOutSkeleton else { return }
        isLayingOutSkeleton = true
        defer { isLayingOutSkeleton = false }
        visibleCells.forEach {
            $0.layoutIfNeeded()
            $0.layoutSkeletonIfNeeded()
        }
    }
}

// MARK: - UITableView

extension UITableView {

    var skeletonCellRegistration: SkeletonCellRegistration? {
        get { return ao_get(pkey: &DiffableOverlayAssociatedKeys.cellRegistration) as? SkeletonCellRegistration }
        set { ao_setOptional(newValue, pkey: &DiffableOverlayAssociatedKeys.cellRegistration) }
    }

    func addSkeletonOverlayIfNeeded() -> Bool {
        guard !isSkeletonOverlayInstalled,
              isDiffableDataSource(dataSource, className: "UITableViewDiffableDataSource"),
              let registration = skeletonCellRegistration else {
            return false
        }

        let overlay = skeletonOverlay as? SkeletonOverlayTableView ?? SkeletonOverlayTableView(frame: frame, style: style)
        switch registration.source {
        case .cellClass(let cellClass):
            overlay.register(cellClass, forCellReuseIdentifier: registration.identifier)
        case .nib(let nib):
            overlay.register(nib, forCellReuseIdentifier: registration.identifier)
        case .cellClasses(let cells):
            cells.forEach { overlay.register($0.type, forCellReuseIdentifier: $0.identifier) }
        }

        // the overlay needs a positive height: with `automaticDimension` the number of rows can't be estimated
        let skeletonRowHeight: CGFloat
        if let registeredRowHeight = registration.rowHeight, registeredRowHeight > 0 {
            skeletonRowHeight = registeredRowHeight
        } else if rowHeight > 0 {
            skeletonRowHeight = rowHeight
        } else if estimatedRowHeight > 0 {
            skeletonRowHeight = estimatedRowHeight
        } else {
            skeletonRowHeight = 44
        }
        overlay.rowHeight = skeletonRowHeight
        overlay.estimatedRowHeight = skeletonRowHeight
        #if os(iOS)
        overlay.separatorStyle = separatorStyle
        #endif
        overlay.separatorInset = separatorInset

        let overlayDataSource = SkeletonOverlayTableViewDataSource(registration: registration)
        overlay.ao_set(overlayDataSource, pkey: &DiffableOverlayAssociatedKeys.overlayDataSource)
        overlay.dataSource = overlayDataSource

        if let viewForHeaderInSection = registration.viewForHeaderInSection {
            let overlayDelegate = SkeletonOverlayTableViewHeaderDelegate(viewForHeaderInSection: viewForHeaderInSection,
                                                                         heightForHeaderInSection: registration.heightForHeaderInSection)
            overlay.ao_set(overlayDelegate, pkey: &DiffableOverlayAssociatedKeys.overlayDelegate)
            overlay.delegate = overlayDelegate
            if #available(iOS 15.0, tvOS 15.0, *) {
                overlay.sectionHeaderTopPadding = sectionHeaderTopPadding
            }
        } else {
            overlay.delegate = nil
        }

        return installSkeletonOverlay(overlay)
    }
}

/// Section headers of the overlay. Each header view is asked once per overlay install and kept,
/// so its height can be computed from the view and its skeleton resized after layout.
final class SkeletonOverlayTableViewHeaderDelegate: NSObject, UITableViewDelegate {
    private let viewForHeaderInSection: (Int) -> UIView?
    private let heightForHeaderInSection: ((Int) -> CGFloat)?
    private var requestedSections = Set<Int>()
    private(set) var headerViews: [Int: UIView] = [:]

    init(viewForHeaderInSection: @escaping (Int) -> UIView?, heightForHeaderInSection: ((Int) -> CGFloat)?) {
        self.viewForHeaderInSection = viewForHeaderInSection
        self.heightForHeaderInSection = heightForHeaderInSection
    }

    private func headerView(in section: Int) -> UIView? {
        if !requestedSections.contains(section) {
            requestedSections.insert(section)
            headerViews[section] = viewForHeaderInSection(section)
        }
        return headerViews[section]
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = headerView(in: section) else { return nil }
        if tableView.sk.isSkeletonActive, let config = tableView._currentSkeletonConfig, !view.sk.isSkeletonActive {
            view.showSkeleton(skeletonConfig: config, notifyDelegate: false)
        }
        return view
    }

    // without this, UIKit estimates the header heights and adds `sectionHeaderTopPadding` even to empty headers
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        self.tableView(tableView, heightForHeaderInSection: section)
    }

    /// The closure if given, else the view's frame height, else its Auto Layout height for the table width.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = heightForHeaderInSection?(section) {
            return height
        }
        // no header: 0 hides it in plain tables (a tiny height would still add `sectionHeaderTopPadding`),
        // grouped tables need a tiny height instead (0 means the default height there)
        let noHeaderHeight: CGFloat = tableView.style == .plain ? 0 : .leastNonzeroMagnitude
        guard let view = headerView(in: section) else { return noHeaderHeight }
        if view.frame.height > 0 {
            return view.frame.height
        }
        let fittingSize = CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let height = view.systemLayoutSizeFitting(fittingSize,
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel).height
        return height > 0 ? height : noHeaderHeight
    }
}

final class SkeletonOverlayTableViewDataSource: NSObject, SkeletonTableViewDataSource {
    let registration: SkeletonCellRegistration

    init(registration: SkeletonCellRegistration) {
        self.registration = registration
    }

    // The overlay only ever shows skeleton cells, which come from `SkeletonCollectionDataSource`
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 0 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { UITableViewCell() }

    func numSections(in collectionSkeletonView: UITableView) -> Int {
        registration.numberOfSections
    }

    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        registration.numberOfItems
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        if let cellIdentifierForRowAt = registration.cellIdentifierForRowAt {
            return cellIdentifierForRowAt(indexPath)
        }
        if case .cellClasses(let cells) = registration.source, !cells.isEmpty {
            return cells[min(indexPath.section, cells.count - 1)].identifier
        }
        return registration.identifier
    }

    func collectionSkeletonView(_ skeletonView: UITableView, prepareCellForSkeleton cell: UITableViewCell, at indexPath: IndexPath) {
        registration.prepareCellForSkeleton?(cell, indexPath)
    }
}

// MARK: - UICollectionView

extension UICollectionView {

    var skeletonCellRegistration: SkeletonCellRegistration? {
        get { return ao_get(pkey: &DiffableOverlayAssociatedKeys.cellRegistration) as? SkeletonCellRegistration }
        set { ao_setOptional(newValue, pkey: &DiffableOverlayAssociatedKeys.cellRegistration) }
    }

    func addSkeletonOverlayIfNeeded() -> Bool {
        guard !isSkeletonOverlayInstalled,
              isDiffableDataSource(dataSource, className: "UICollectionViewDiffableDataSource"),
              let registration = skeletonCellRegistration,
              let layout = makeSkeletonOverlayLayout() else {
            return false
        }

        let overlay: SkeletonOverlayCollectionView
        if let existingOverlay = skeletonOverlay as? SkeletonOverlayCollectionView {
            overlay = existingOverlay
            overlay.collectionViewLayout = layout
        } else {
            overlay = SkeletonOverlayCollectionView(frame: frame, collectionViewLayout: layout)
        }
        switch registration.source {
        case .cellClass(let cellClass):
            overlay.register(cellClass, forCellWithReuseIdentifier: registration.identifier)
        case .nib(let nib):
            overlay.register(nib, forCellWithReuseIdentifier: registration.identifier)
        case .cellClasses:
            break // only registered on table views
        }

        let overlayDataSource = SkeletonOverlayCollectionViewDataSource(registration: registration)
        overlay.ao_set(overlayDataSource, pkey: &DiffableOverlayAssociatedKeys.overlayDataSource)
        overlay.dataSource = overlayDataSource

        if let originalDelegate = delegate as? UICollectionViewDelegateFlowLayout {
            let overlayDelegate = SkeletonOverlayFlowLayoutDelegate(originalDelegate: originalDelegate)
            overlay.ao_set(overlayDelegate, pkey: &DiffableOverlayAssociatedKeys.overlayDelegate)
            overlay.delegate = overlayDelegate
        } else {
            overlay.delegate = nil
        }

        return installSkeletonOverlay(overlay)
    }

    /// A layout object can't be shared between two collection views, so the overlay gets
    /// a new instance of the same class with the same settings.
    private func makeSkeletonOverlayLayout() -> UICollectionViewFlowLayout? {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
              let layout = (type(of: flowLayout) as NSObject.Type).init() as? UICollectionViewFlowLayout else {
            return nil
        }
        layout.scrollDirection = flowLayout.scrollDirection
        layout.itemSize = flowLayout.itemSize
        layout.estimatedItemSize = flowLayout.estimatedItemSize
        layout.minimumLineSpacing = flowLayout.minimumLineSpacing
        layout.minimumInteritemSpacing = flowLayout.minimumInteritemSpacing
        layout.sectionInset = flowLayout.sectionInset
        return layout
    }
}

final class SkeletonOverlayCollectionViewDataSource: NSObject, SkeletonCollectionViewDataSource {
    let registration: SkeletonCellRegistration

    init(registration: SkeletonCellRegistration) {
        self.registration = registration
    }

    // The overlay only ever shows skeleton cells, which come from `SkeletonCollectionDataSource`
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 0 }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { UICollectionViewCell() }

    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        registration.numberOfSections
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard registration.numberOfItems == UICollectionView.automaticNumberOfSkeletonItems else {
            return registration.numberOfItems
        }
        return skeletonView.numberOfItemsFillingView(inSection: section)
    }

    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        registration.identifier
    }
}

extension UICollectionView {

    /// `estimatedNumberOfRows` counts lines, which is only right with one item per line.
    /// Here we count lines × items per line, using the sizes the delegate gives (like the layout does).
    func numberOfItemsFillingView(inSection section: Int) -> Int {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return estimatedNumberOfRows
        }

        let delegate = self.delegate as? UICollectionViewDelegateFlowLayout
        let firstItem = IndexPath(item: 0, section: section)
        let estimatedItemSize = flowLayout.estimatedItemSize
        var hasEstimatedItemSize = estimatedItemSize != .zero
        if #available(iOS 10.0, tvOS 10.0, *), estimatedItemSize == UICollectionViewFlowLayout.automaticSize {
            hasEstimatedItemSize = false
        }
        let itemSize = delegate?.collectionView?(self, layout: flowLayout, sizeForItemAt: firstItem)
            ?? (hasEstimatedItemSize ? estimatedItemSize : flowLayout.itemSize)
        let inset = delegate?.collectionView?(self, layout: flowLayout, insetForSectionAt: section) ?? flowLayout.sectionInset
        let lineSpacing = delegate?.collectionView?(self, layout: flowLayout, minimumLineSpacingForSectionAt: section) ?? flowLayout.minimumLineSpacing
        let interitemSpacing = delegate?.collectionView?(self, layout: flowLayout, minimumInteritemSpacingForSectionAt: section) ?? flowLayout.minimumInteritemSpacing

        let isVertical = flowLayout.scrollDirection == .vertical
        // along a line (across the scroll direction) and along the scroll direction
        let lineLength = isVertical ? bounds.width - inset.left - inset.right : bounds.height - inset.top - inset.bottom
        let scrollLength = isVertical ? bounds.height - inset.top : bounds.width - inset.left
        let itemLength = isVertical ? itemSize.width : itemSize.height
        let itemDepth = isVertical ? itemSize.height : itemSize.width

        guard itemLength > 0, itemDepth > 0 else { return estimatedNumberOfRows }

        let itemsPerLine = max(1, Int((lineLength + interitemSpacing) / (itemLength + interitemSpacing)))
        let lines = max(1, Int(ceil((scrollLength + lineSpacing) / (itemDepth + lineSpacing))))
        return itemsPerLine * lines
    }
}

/// Forwards the flow layout sizing questions to the original delegate, so the skeleton cells
/// get the same sizes as the real ones. Nothing else is forwarded: the overlay isn't interactive.
final class SkeletonOverlayFlowLayoutDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    weak var originalDelegate: UICollectionViewDelegateFlowLayout?

    init(originalDelegate: UICollectionViewDelegateFlowLayout) {
        self.originalDelegate = originalDelegate
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        originalDelegate?.collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize
            ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        originalDelegate?.collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAt: section)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset
            ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        originalDelegate?.collectionView?(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing
            ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        originalDelegate?.collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section)
            ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing
            ?? 0
    }
}

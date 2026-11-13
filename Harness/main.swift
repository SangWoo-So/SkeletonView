// Verification app for the diffable data source support.
// Built by build.sh with the library sources compiled in (no Xcode project needed).
// Each scenario logs "RESULT[<scenario>]: ..." lines; run_all.sh runs every check in one launch.

import UIKit

enum Section { case main }

final class TCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isSkeletonable = true; contentView.isSkeletonable = true
        let l = UILabel(); l.isSkeletonable = true; l.text = "x"; l.frame = CGRect(x: 8, y: 8, width: 200, height: 20)
        contentView.addSubview(l)
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class CCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isSkeletonable = true; contentView.isSkeletonable = true
        let l = UILabel(); l.isSkeletonable = true; l.text = "x"; l.frame = CGRect(x: 4, y: 4, width: 40, height: 20)
        contentView.addSubview(l)
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class DemoTCell: UITableViewCell {
    let title = UILabel(); let sub = UILabel(); let icon = UIView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isSkeletonable = true; contentView.isSkeletonable = true
        icon.backgroundColor = .systemBlue; icon.layer.cornerRadius = 22; icon.frame = CGRect(x: 16, y: 10, width: 44, height: 44)
        title.frame = CGRect(x: 72, y: 12, width: 220, height: 20); sub.frame = CGRect(x: 72, y: 36, width: 160, height: 16)
        sub.text = "subtitle"; sub.textColor = .secondaryLabel; sub.font = .systemFont(ofSize: 13); title.text = "title"
        [icon, title, sub].forEach { $0.isSkeletonable = true; contentView.addSubview($0) }
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class DemoCCell: UICollectionViewCell {
    let title = UILabel(); let box = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        isSkeletonable = true; contentView.isSkeletonable = true
        box.backgroundColor = .systemOrange; box.layer.cornerRadius = 8; box.frame = CGRect(x: 0, y: 0, width: 110, height: 60)
        title.frame = CGRect(x: 4, y: 66, width: 100, height: 18); title.text = "title"
        [box, title].forEach { $0.isSkeletonable = true; contentView.addSubview($0) }
    }
    required init?(coder: NSCoder) { fatalError() }
}

/// label laid out with Auto Layout: its frame is (0,0,0,0) until the cell is laid out
final class AutoLayoutTCell: UITableViewCell {
    let name = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isSkeletonable = true; contentView.isSkeletonable = true
        name.text = "name"; name.isSkeletonable = true; name.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(name)
        NSLayoutConstraint.activate([name.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
                                     name.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                                     name.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)])
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class AutoLayoutCCell: UICollectionViewCell {
    let name = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        isSkeletonable = true; contentView.isSkeletonable = true
        name.text = "name"; name.isSkeletonable = true; name.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(name)
        NSLayoutConstraint.activate([name.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                                     name.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                                     name.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)])
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class LeftAlignedFlowLayout: UICollectionViewFlowLayout {}

final class SizingDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    func collectionView(_ c: UICollectionView, layout l: UICollectionViewLayout, sizeForItemAt i: IndexPath) -> CGSize {
        CGSize(width: 120, height: 60)
    }
}

final class ClassicDS: NSObject, SkeletonTableViewDataSource {
    func tableView(_ t: UITableView, numberOfRowsInSection s: Int) -> Int { 2 }
    func tableView(_ t: UITableView, cellForRowAt i: IndexPath) -> UITableViewCell { t.dequeueReusableCell(withIdentifier: "C", for: i) }
    func collectionSkeletonView(_ v: UITableView, cellIdentifierForRowAt i: IndexPath) -> ReusableCellIdentifier { "C" }
}

var currentScenario = ProcessInfo.processInfo.environment["SCENARIO"] ?? "-"
func log(_ s: String) { NSLog("RESULT[%@]: %@", currentScenario, s) }

func snapshot(_ items: [Int]) -> NSDiffableDataSourceSnapshot<Section, Int> {
    var s = NSDiffableDataSourceSnapshot<Section, Int>(); s.appendSections([.main]); s.appendItems(items); return s
}

/// the overlay currently installed above `v`, if any
func overlayOf(_ v: UIView) -> UIScrollView? {
    guard let overlay = (v as? UIScrollView)?.skeletonOverlay, overlay.superview != nil else { return nil }
    return overlay
}

let allScenarios = ["table", "table-animated", "table-hide-first", "cv", "cv-animated", "cv-custom-layout",
                    "table-update", "table-autolayout", "table-unregistered", "classic",
                    "table-repeat", "cv-repeat", "table-content", "cv-content", "count-custom", "cv-fill", "table-auto-height", "overlay-cell-layout", "table-header", "table-multi-cell", "register-twice"]

final class AppDelegate: UIResponder, UIApplicationDelegate {}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let sizing = SizingDelegate()
    var keep: [AnyObject] = []

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        let scenario = ProcessInfo.processInfo.environment["SCENARIO"] ?? "all"
        let w = UIWindow(windowScene: ws)
        let vc = UIViewController(); w.rootViewController = vc; w.makeKeyAndVisible(); window = w
        DispatchQueue.main.async {
            if scenario == "all" {
                // one launch for every check: much faster than relaunching the app per scenario
                for name in allScenarios {
                    vc.view.subviews.forEach { $0.removeFromSuperview() }
                    currentScenario = name
                    self.run(name, vc)
                }
                currentScenario = "all"; log("ALL DONE")
            } else {
                self.run(scenario, vc)
            }
            if scenario != "demo" { exit(0) }
        }
    }

    func run(_ scenario: String, _ vc: UIViewController) {
        switch scenario {
        case "table", "table-animated", "table-hide-first": table(scenario, vc)
        case "cv", "cv-animated": cv(scenario, vc, layout: UICollectionViewFlowLayout())
        case "cv-custom-layout": cv(scenario, vc, layout: LeftAlignedFlowLayout())
        case "table-update": tableUpdate(vc)
        case "table-autolayout": tableAutoLayout(vc)
        case "table-unregistered": tableUnregistered(vc)
        case "classic": classic(vc)
        case "table-repeat", "cv-repeat": repeatShowHide(scenario, vc)
        case "table-content", "cv-content": content(scenario, vc)
        case "count-custom": countCustom(vc)
        case "cv-fill": cvFill(vc)
        case "table-auto-height": tableAutoHeight(vc)
        case "overlay-cell-layout": overlayCellLayout(vc)
        case "table-header": tableHeader(vc)
        case "table-multi-cell": tableMultiCell(vc)
        case "register-twice": registerTwice(vc)
        case "leak-table", "leak-cv": leak(scenario, vc)
        case "leak-plain", "leak-plain-noshow": leakPlain(scenario, vc)
        case "demo": demo(vc)
        default: log("unknown scenario")
        }
    }
}

// MARK: - Basic flows

extension SceneDelegate {

    func makeTable(_ vc: UIViewController, register: Bool = true) -> (UITableView, UITableViewDiffableDataSource<Section, Int>) {
        let tv = UITableView(frame: vc.view.bounds); vc.view.addSubview(tv)
        tv.register(TCell.self, forCellReuseIdentifier: "C"); tv.rowHeight = 80; tv.isSkeletonable = true
        if register { tv.registerSkeletonCell(TCell.self, forCellReuseIdentifier: "C") }
        let ds = UITableViewDiffableDataSource<Section, Int>(tableView: tv) { t, i, _ in t.dequeueReusableCell(withIdentifier: "C", for: i) }
        keep.append(ds)  // the table view only keeps a weak reference to its data source
        ds.apply(snapshot([1, 2]), animatingDifferences: false)
        tv.layoutIfNeeded()
        return (tv, ds)
    }

    func table(_ scenario: String, _ vc: UIViewController) {
        let (tv, ds) = makeTable(vc)
        let realFrame = tv.cellForRow(at: IndexPath(row: 0, section: 0))!.frame
        tv.showSkeleton(); vc.view.layoutIfNeeded()
        guard let o = overlayOf(tv) as? UITableView else { log("FAIL no overlay"); return }
        o.layoutIfNeeded()
        log("showing: realHidden=\(tv.isHidden) realDSUntouched=\(tv.dataSource === ds) overlayRows=\(o.numberOfRows(inSection: 0)) overlayCellsSkeleton=\(!o.visibleCells.isEmpty && o.visibleCells.allSatisfy { $0.sk.isSkeletonActive }) frameMatch=\(o.visibleCells.first?.frame == realFrame)")
        if scenario == "table-hide-first" {
            tv.hideSkeleton(); ds.apply(snapshot([1, 2, 3]), animatingDifferences: true)
        } else {
            ds.apply(snapshot([1, 2, 3]), animatingDifferences: scenario == "table-animated")
            tv.layoutIfNeeded()
            log("apply during skeleton: NO CRASH realRows=\(tv.numberOfRows(inSection: 0))")
            tv.hideSkeleton()
        }
        vc.view.layoutIfNeeded()
        log("after: overlayRemoved=\(o.superview == nil) realVisible=\(!tv.isHidden) realRows=\(tv.numberOfRows(inSection: 0)) active=\(tv.sk.isSkeletonActive)")
    }

    func cv(_ scenario: String, _ vc: UIViewController, layout: UICollectionViewFlowLayout) {
        layout.minimumLineSpacing = 7
        let cv = UICollectionView(frame: vc.view.bounds, collectionViewLayout: layout); vc.view.addSubview(cv)
        cv.register(CCell.self, forCellWithReuseIdentifier: "C"); cv.isSkeletonable = true
        cv.delegate = sizing
        cv.registerSkeletonCell(CCell.self, forCellWithReuseIdentifier: "C")
        let ds = UICollectionViewDiffableDataSource<Section, Int>(collectionView: cv) { c, i, _ in c.dequeueReusableCell(withReuseIdentifier: "C", for: i) }
        keep.append(ds)
        ds.apply(snapshot([1, 2]), animatingDifferences: false)
        cv.layoutIfNeeded()
        let realFrame = cv.cellForItem(at: IndexPath(item: 0, section: 0))!.frame
        cv.showSkeleton(); vc.view.layoutIfNeeded()
        guard let o = overlayOf(cv) as? UICollectionView else { log("FAIL no overlay"); return }
        o.layoutIfNeeded()
        let first = o.cellForItem(at: IndexPath(item: 0, section: 0))?.frame
        log("showing: realHidden=\(cv.isHidden) realDSUntouched=\(cv.dataSource === ds) overlayItems=\(o.numberOfItems(inSection: 0)) overlayCellsSkeleton=\(!o.visibleCells.isEmpty && o.visibleCells.allSatisfy { $0.sk.isSkeletonActive }) layoutClass=\(type(of: o.collectionViewLayout)) lineSpacing=\((o.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing) frameMatch=\(first == realFrame) size=\(first?.size ?? .zero)")
        ds.apply(snapshot([1, 2, 3]), animatingDifferences: scenario == "cv-animated")
        cv.layoutIfNeeded()
        log("apply during skeleton: NO CRASH realItems=\(cv.numberOfItems(inSection: 0))")
        cv.hideSkeleton(); vc.view.layoutIfNeeded()
        log("after: overlayRemoved=\(o.superview == nil) realVisible=\(!cv.isHidden) realItems=\(cv.numberOfItems(inSection: 0)) active=\(cv.sk.isSkeletonActive)")
    }

    func tableUpdate(_ vc: UIViewController) {
        let (tv, ds) = makeTable(vc)
        tv.showSkeleton(); vc.view.layoutIfNeeded()
        tv.updateAnimatedSkeleton(); tv.showAnimatedGradientSkeleton(); vc.view.layoutIfNeeded()
        let overlays = vc.view.subviews.filter { $0 is UITableView && $0 !== tv }.count
        ds.apply(snapshot([1, 2, 3]), animatingDifferences: false)
        tv.hideSkeleton(); vc.view.layoutIfNeeded()
        log("update: overlaysWhileShowing=\(overlays) overlaysAfter=\(vc.view.subviews.filter { $0 is UITableView && $0 !== tv }.count) realRows=\(tv.numberOfRows(inSection: 0))")
    }

    func tableAutoLayout(_ vc: UIViewController) {
        let (tv, _) = makeTable(vc)
        tv.translatesAutoresizingMaskIntoConstraints = false
        let height = tv.heightAnchor.constraint(equalToConstant: 300)
        NSLayoutConstraint.activate([tv.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 50),
                                     tv.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
                                     tv.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor), height])
        vc.view.layoutIfNeeded()
        tv.showSkeleton(); vc.view.layoutIfNeeded()
        guard let o = overlayOf(tv) else { log("FAIL no overlay"); return }
        let before = o.frame == tv.frame
        height.constant = 500; vc.view.layoutIfNeeded()
        log("autolayout: matchBefore=\(before) matchAfterResize=\(o.frame == tv.frame)")
        tv.hideSkeleton()
    }

    func tableUnregistered(_ vc: UIViewController) {
        let (tv, ds) = makeTable(vc, register: false)
        tv.showSkeleton(); vc.view.layoutIfNeeded()
        log("unregistered: overlay=\(overlayOf(tv) != nil) realHidden=\(tv.isHidden) dsUntouched=\(tv.dataSource === ds)")
        ds.apply(snapshot([1, 2, 3]), animatingDifferences: false)
        tv.hideSkeleton()
        log("unregistered: NO CRASH realRows=\(tv.numberOfRows(inSection: 0))")
    }

    /// the protocol based flow must behave as before
    func classic(_ vc: UIViewController) {
        let tv = UITableView(frame: vc.view.bounds); vc.view.addSubview(tv)
        tv.register(TCell.self, forCellReuseIdentifier: "C"); tv.rowHeight = 80; tv.isSkeletonable = true
        let ds = ClassicDS(); keep.append(ds); tv.dataSource = ds; tv.reloadData(); tv.layoutIfNeeded()
        tv.showSkeleton(); tv.layoutIfNeeded()
        log("classic showing: ds=\(type(of: tv.dataSource!)) rows=\(tv.numberOfRows(inSection: 0)) overlay=\(overlayOf(tv) != nil)")
        tv.hideSkeleton()
        log("classic after: restored=\(tv.dataSource === ds) rows=\(tv.numberOfRows(inSection: 0))")
    }
}

// MARK: - Overlay reuse, content and counts

extension SceneDelegate {

    func repeatShowHide(_ scenario: String, _ vc: UIViewController) {
        var ids = Set<ObjectIdentifier>()
        var maxInstalled = 0
        let view: UIScrollView
        let apply: ([Int]) -> Void
        if scenario == "cv-repeat" {
            let cv = UICollectionView(frame: vc.view.bounds, collectionViewLayout: UICollectionViewFlowLayout()); vc.view.addSubview(cv)
            cv.register(CCell.self, forCellWithReuseIdentifier: "C"); cv.isSkeletonable = true
            cv.registerSkeletonCell(CCell.self, forCellWithReuseIdentifier: "C")
            let ds = UICollectionViewDiffableDataSource<Section, Int>(collectionView: cv) { c, i, _ in c.dequeueReusableCell(withReuseIdentifier: "C", for: i) }
            keep.append(ds); view = cv; apply = { ds.apply(snapshot($0), animatingDifferences: true) }
        } else {
            let (tv, ds) = makeTable(vc); view = tv
            apply = { ds.apply(snapshot($0), animatingDifferences: true) }
        }
        for n in 1...5 {
            view.showSkeleton(); vc.view.layoutIfNeeded()
            if let o = overlayOf(view) { ids.insert(ObjectIdentifier(o)) }
            maxInstalled = max(maxInstalled, vc.view.subviews.count - 1)
            apply(Array(0..<n))
            view.hideSkeleton(); vc.view.layoutIfNeeded()
        }
        let count = (view as? UITableView)?.numberOfRows(inSection: 0) ?? (view as! UICollectionView).numberOfItems(inSection: 0)
        log("repeat: distinctOverlays=\(ids.count) maxOverlaysAtOnce=\(maxInstalled) overlaysAfter=\(vc.view.subviews.count - 1) realVisible=\(!view.isHidden) finalCount=\(count)")
    }

    /// cells updated by `apply` while the skeleton is shown must not get their old text back on hide
    func content(_ scenario: String, _ vc: UIViewController) {
        let texts: () -> [String]
        let apply: ([Int]) -> Void
        let view: UIScrollView
        if scenario == "cv-content" {
            let l = UICollectionViewFlowLayout(); l.itemSize = CGSize(width: 110, height: 90)
            let cv = UICollectionView(frame: vc.view.bounds, collectionViewLayout: l); vc.view.addSubview(cv)
            cv.register(DemoCCell.self, forCellWithReuseIdentifier: "C"); cv.isSkeletonable = true
            cv.registerSkeletonCell(DemoCCell.self, forCellWithReuseIdentifier: "C")
            let ds = UICollectionViewDiffableDataSource<Section, Int>(collectionView: cv) { c, i, item in
                let cell = c.dequeueReusableCell(withReuseIdentifier: "C", for: i) as! DemoCCell; cell.title.text = "\(item)"; return cell }
            keep.append(ds); view = cv
            apply = { ds.apply(snapshot($0), animatingDifferences: true) }
            texts = { (0..<cv.numberOfItems(inSection: 0)).compactMap { (cv.cellForItem(at: IndexPath(item: $0, section: 0)) as? DemoCCell)?.title.text } }
        } else {
            let tv = UITableView(frame: vc.view.bounds); vc.view.addSubview(tv)
            tv.register(DemoTCell.self, forCellReuseIdentifier: "C"); tv.rowHeight = 64; tv.isSkeletonable = true
            tv.registerSkeletonCell(DemoTCell.self, forCellReuseIdentifier: "C")
            let ds = UITableViewDiffableDataSource<Section, Int>(tableView: tv) { t, i, item in
                let c = t.dequeueReusableCell(withIdentifier: "C", for: i) as! DemoTCell; c.title.text = "\(item)"; return c }
            keep.append(ds); view = tv
            apply = { ds.apply(snapshot($0), animatingDifferences: true) }
            texts = { (0..<tv.numberOfRows(inSection: 0)).compactMap { (tv.cellForRow(at: IndexPath(row: $0, section: 0)) as? DemoTCell)?.title.text } }
        }
        // same sequence as the demo: show → apply while skeleton → hide, with varying counts
        var failures: [String] = []
        for (round, count) in [4, 5, 6, 3, 4, 5, 6, 3, 4].enumerated() {
            view.showAnimatedGradientSkeleton(); vc.view.layoutIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.3))
            apply(Array(1...count)); vc.view.layoutIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.3))
            view.hideSkeleton(); vc.view.layoutIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.3))
            let got = texts(), expected = (1...count).map(String.init)
            if got != expected { failures.append("round\(round + 1): \(got)≠\(expected)") }
        }
        log("content: correct=\(failures.isEmpty) \(failures.joined(separator: " | "))")
    }

    func countCustom(_ vc: UIViewController) {
        let (tv, _) = makeTable(vc, register: false)
        tv.registerSkeletonCell(TCell.self, forCellReuseIdentifier: "C", numberOfSections: 2, numberOfRows: 3)
        tv.showSkeleton(); vc.view.layoutIfNeeded()
        let to = overlayOf(tv) as! UITableView
        let tableCounts = (0..<to.numberOfSections).map { to.numberOfRows(inSection: $0) }
        tv.hideSkeleton(); tv.removeFromSuperview()

        let cv = UICollectionView(frame: vc.view.bounds, collectionViewLayout: UICollectionViewFlowLayout()); vc.view.addSubview(cv)
        cv.register(CCell.self, forCellWithReuseIdentifier: "C"); cv.isSkeletonable = true
        cv.registerSkeletonCell(CCell.self, forCellWithReuseIdentifier: "C", numberOfSections: 2, numberOfItems: 5)
        let ds = UICollectionViewDiffableDataSource<Section, Int>(collectionView: cv) { c, i, _ in c.dequeueReusableCell(withReuseIdentifier: "C", for: i) }
        keep.append(ds); ds.apply(snapshot([1]), animatingDifferences: false)
        cv.showSkeleton(); vc.view.layoutIfNeeded()
        let co = overlayOf(cv) as! UICollectionView
        let cvCounts = (0..<co.numberOfSections).map { co.numberOfItems(inSection: $0) }
        cv.hideSkeleton()
        log("count: table=\(tableCounts) ok=\(tableCounts == [3, 3]) | cv=\(cvCounts) ok=\(cvCounts == [5, 5])")
    }

    /// rowHeight and estimatedRowHeight both left to automaticDimension (-1) on the real table
    func tableAutoHeight(_ vc: UIViewController) {
        for rowHeight in [nil, 153] as [CGFloat?] {
            vc.view.subviews.forEach { $0.removeFromSuperview() }
            let tv = UITableView(frame: vc.view.bounds); vc.view.addSubview(tv)
            tv.register(TCell.self, forCellReuseIdentifier: "C"); tv.isSkeletonable = true
            tv.rowHeight = UITableView.automaticDimension; tv.estimatedRowHeight = UITableView.automaticDimension
            if let rowHeight = rowHeight {
                tv.registerSkeletonCell(TCell.self, forCellReuseIdentifier: "C", rowHeight: rowHeight)
            } else {
                tv.registerSkeletonCell(TCell.self, forCellReuseIdentifier: "C")
            }
            let ds = UITableViewDiffableDataSource<Section, Int>(tableView: tv) { t, i, _ in t.dequeueReusableCell(withIdentifier: "C", for: i) }
            keep.append(ds); ds.apply(snapshot([1, 2]), animatingDifferences: false); tv.layoutIfNeeded()
            tv.showSkeleton(); vc.view.layoutIfNeeded()
            guard let o = overlayOf(tv) as? UITableView else { log("FAIL no overlay"); continue }
            o.layoutIfNeeded()
            let expectedHeight = rowHeight ?? 44
            let rows = o.numberOfRows(inSection: 0)
            let expectedRows = Int(ceil(o.frame.height / expectedHeight))
            log("autoHeight(rowHeight: \(rowHeight.map { "\($0)" } ?? "nil")): overlayRowHeight=\(o.rowHeight) rows=\(rows) expectedRows=\(expectedRows) visibleSkeletonCells=\(o.visibleCells.filter { $0.sk.isSkeletonActive }.count) realRowHeight=\(tv.rowHeight) realEstimated=\(tv.estimatedRowHeight) ok=\(o.rowHeight == expectedHeight && rows == expectedRows && rows > 0)")
            tv.hideSkeleton()
        }
    }

    /// skeleton bars must match the label sizes even without the global layoutSubviews swizzle
    func overlayCellLayout(_ vc: UIViewController) {
        // another view showing then hiding its skeleton unswizzles layoutSubviews app wide (0.01 s later)
        let other = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)); other.isSkeletonable = true; vc.view.addSubview(other)
        other.showSkeleton(); other.hideSkeleton()
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        other.removeFromSuperview()

        // checked synchronously below, before the re-swizzle scheduled by showSkeleton (0.01 s) can run
        func barsMatch(_ labels: [UILabel]) -> String {
            let bad = labels.filter { label in
                guard let layer = label._skeletonLayer?.contentLayer else { return true }
                return layer.bounds.size != label.bounds.size || label.bounds.width == 0
            }
            let sample = labels.first.map { "label=\($0.bounds.size) bar=\($0._skeletonLayer?.contentLayer.bounds.size ?? .zero)" } ?? "-"
            return "match=\(bad.isEmpty && !labels.isEmpty) cells=\(labels.count) \(sample)"
        }

        // table
        let tv = UITableView(); tv.translatesAutoresizingMaskIntoConstraints = false; vc.view.addSubview(tv)
        let width = tv.widthAnchor.constraint(equalToConstant: 300)
        NSLayoutConstraint.activate([tv.topAnchor.constraint(equalTo: vc.view.topAnchor), tv.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
                                     tv.heightAnchor.constraint(equalToConstant: 400), width])
        tv.register(AutoLayoutTCell.self, forCellReuseIdentifier: "C"); tv.isSkeletonable = true
        tv.rowHeight = UITableView.automaticDimension; tv.estimatedRowHeight = UITableView.automaticDimension
        tv.registerSkeletonCell(AutoLayoutTCell.self, forCellReuseIdentifier: "C", rowHeight: 153)
        let tds = UITableViewDiffableDataSource<Section, Int>(tableView: tv) { t, i, _ in t.dequeueReusableCell(withIdentifier: "C", for: i) }
        keep.append(tds); tds.apply(snapshot([1]), animatingDifferences: false); vc.view.layoutIfNeeded()
        tv.showSkeleton(); vc.view.layoutIfNeeded()
        let to = overlayOf(tv) as! UITableView; to.layoutIfNeeded()
        let tLabels = { to.visibleCells.compactMap { ($0 as? AutoLayoutTCell)?.name } }
        log("table initial: \(barsMatch(tLabels())) overlayClass=\(type(of: to))")
        width.constant = 380; vc.view.layoutIfNeeded(); to.layoutIfNeeded()
        log("table resized: \(barsMatch(tLabels()))")
        tv.hideSkeleton(); vc.view.layoutIfNeeded()
        log("table hidden: overlayRemoved=\(to.superview == nil) realVisible=\(!tv.isHidden)")
        tv.removeFromSuperview()

        // collection view
        let l = UICollectionViewFlowLayout(); l.itemSize = CGSize(width: 140, height: 60)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: l); cv.translatesAutoresizingMaskIntoConstraints = false; vc.view.addSubview(cv)
        let cWidth = cv.widthAnchor.constraint(equalToConstant: 300)
        NSLayoutConstraint.activate([cv.topAnchor.constraint(equalTo: vc.view.topAnchor), cv.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
                                     cv.heightAnchor.constraint(equalToConstant: 300), cWidth])
        cv.register(AutoLayoutCCell.self, forCellWithReuseIdentifier: "C"); cv.isSkeletonable = true
        cv.registerSkeletonCell(AutoLayoutCCell.self, forCellWithReuseIdentifier: "C")
        let cds = UICollectionViewDiffableDataSource<Section, Int>(collectionView: cv) { c, i, _ in c.dequeueReusableCell(withReuseIdentifier: "C", for: i) }
        keep.append(cds); cds.apply(snapshot([1]), animatingDifferences: false); vc.view.layoutIfNeeded()
        cv.showSkeleton(); vc.view.layoutIfNeeded()
        let co = overlayOf(cv) as! UICollectionView; co.layoutIfNeeded()
        log("cv initial: \(barsMatch(co.visibleCells.compactMap { ($0 as? AutoLayoutCCell)?.name })) overlayClass=\(type(of: co))")
        cv.hideSkeleton(); vc.view.layoutIfNeeded()
        log("cv hidden: overlayRemoved=\(co.superview == nil) realVisible=\(!cv.isHidden)")
    }

    /// section headers of the overlay: height from the closure, the frame, Auto Layout, or no header
    func tableHeader(_ vc: UIViewController) {
        // header with a label pinned top and bottom: Auto Layout height = 10 + label + 10
        func autoLayoutHeader() -> UIView {
            let v = UIView(); v.isSkeletonable = true
            let l = UILabel(); l.text = "header"; l.isSkeletonable = true; l.translatesAutoresizingMaskIntoConstraints = false
            v.addSubview(l)
            NSLayoutConstraint.activate([l.topAnchor.constraint(equalTo: v.topAnchor, constant: 10),
                                         l.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -10),
                                         l.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
                                         l.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -16)])
            return v
        }
        func frameHeader() -> UIView {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50)); v.isSkeletonable = true
            let l = UILabel(frame: CGRect(x: 16, y: 10, width: 120, height: 20)); l.text = "header"; l.isSkeletonable = true
            v.addSubview(l)
            return v
        }
        let cases: [(String, ((Int) -> UIView?)?, ((Int) -> CGFloat)?, CGFloat?)] = [
            ("closure", { $0 == 0 ? autoLayoutHeader() : nil }, { $0 == 0 ? 35 : 0 }, 35),
            ("frame", { $0 == 0 ? frameHeader() : nil }, nil, 50),
            ("autolayout", { $0 == 0 ? autoLayoutHeader() : nil }, nil, nil),
            ("nil", { _ in nil }, nil, 0),
            ("no-closure", nil, nil, 0),
        ]
        for (name, viewFor, heightFor, expected) in cases {
            vc.view.subviews.forEach { $0.removeFromSuperview() }
            let tv = UITableView(frame: vc.view.bounds); vc.view.addSubview(tv)
            tv.register(TCell.self, forCellReuseIdentifier: "C"); tv.isSkeletonable = true; tv.rowHeight = 80
            tv.registerSkeletonCell(TCell.self, forCellReuseIdentifier: "C", numberOfSections: 2, numberOfRows: 2,
                                    viewForHeaderInSection: viewFor, heightForHeaderInSection: heightFor)
            let ds = UITableViewDiffableDataSource<Section, Int>(tableView: tv) { t, i, _ in t.dequeueReusableCell(withIdentifier: "C", for: i) }
            keep.append(ds); ds.apply(snapshot([1]), animatingDifferences: false); tv.layoutIfNeeded()
            tv.showSkeleton(); vc.view.layoutIfNeeded()
            guard let o = overlayOf(tv) as? UITableView else { log("\(name): FAIL no overlay"); continue }
            o.layoutIfNeeded()
            let h0 = o.rectForHeader(inSection: 0).height, h1 = o.rectForHeader(inSection: 1).height
            let firstRowY = o.rectForRow(at: IndexPath(row: 0, section: 0)).minY
            let header = o.headerView(forSection: 0) ?? o.subviews.first { $0.subviews.contains { $0 is UILabel && ($0 as! UILabel).text == "header" } }
            let label = header?.subviews.compactMap { $0 as? UILabel }.first
            let bar = label?._skeletonLayer?.contentLayer.bounds.size
            let heightOk = expected.map { abs(h0 - $0) < 0.5 } ?? (h0 > 20)  // autolayout: 20 + label height
            let skeletonOk = expected == 0 ? header == nil : (label?.sk.isSkeletonActive == true && bar == label?.bounds.size && (label?.bounds.width ?? 0) > 0)
            let section1Gap = o.rectForRow(at: IndexPath(row: 0, section: 1)).minY - o.rectForRow(at: IndexPath(row: 1, section: 0)).maxY
            log("\(name): section1Gap=\(section1Gap) header0=\(String(format: "%.1f", h0)) header1=\(String(format: "%.1f", h1)) firstRowY=\(String(format: "%.1f", firstRowY)) labelSkeleton=\(label?.sk.isSkeletonActive ?? false) bar=\(bar ?? .zero) label=\(label?.bounds.size ?? .zero) ok=\(heightOk && skeletonOk && h1 < 1 && (expected == 0 ? firstRowY == 0 : abs(firstRowY - h0 - 22) < 0.5))")
            tv.hideSkeleton(); vc.view.layoutIfNeeded()
        }
    }

    /// several cell classes: picked per section by default, or per row by `cellIdentifierForRowAt`; `prepareCellForSkeleton` fills texts
    func tableMultiCell(_ vc: UIViewController) {
        func makeTable() -> (UITableView, UITableViewDiffableDataSource<Section, Int>) {
            vc.view.subviews.forEach { $0.removeFromSuperview() }
            let tv = UITableView(frame: vc.view.bounds); vc.view.addSubview(tv)
            tv.register(TCell.self, forCellReuseIdentifier: "C"); tv.isSkeletonable = true; tv.rowHeight = 80
            let ds = UITableViewDiffableDataSource<Section, Int>(tableView: tv) { t, i, _ in t.dequeueReusableCell(withIdentifier: "C", for: i) }
            keep.append(ds); ds.apply(snapshot([1]), animatingDifferences: false); tv.layoutIfNeeded()
            return (tv, ds)
        }
        func kinds(_ o: UITableView, section: Int) -> [String] {
            (0..<o.numberOfRows(inSection: section)).compactMap { o.cellForRow(at: IndexPath(row: $0, section: section)) }.map { "\(type(of: $0))" }
        }

        // 1. default: section N uses the Nth cell, sections beyond use the last one
        var (tv, ds) = makeTable()
        tv.registerSkeletonCell((type: DemoTCell.self, identifier: "A"), (type: TCell.self, identifier: "B"),
                                numberOfSections: 3, numberOfRows: 2, rowHeight: 70,
                                prepareCellForSkeleton: { cell, indexPath in
                                    (cell as? DemoTCell)?.title.text = "s\(indexPath.section)r\(indexPath.row)"
                                })
        tv.showSkeleton(); vc.view.layoutIfNeeded()
        guard var o = overlayOf(tv) as? UITableView else { log("FAIL no overlay"); return }
        o.layoutIfNeeded()
        let perSection = (0..<3).map { kinds(o, section: $0) }
        let titles = (0..<2).compactMap { (o.cellForRow(at: IndexPath(row: $0, section: 0)) as? DemoTCell)?.title.text }
        let bars = o.visibleCells.compactMap { $0 as? DemoTCell }.allSatisfy { $0.title._skeletonLayer?.contentLayer.bounds.size == $0.title.bounds.size && $0.title.bounds.width > 0 }
        let skeleton = o.visibleCells.allSatisfy { $0.sk.isSkeletonActive }
        ds.apply(snapshot([1, 2, 3]), animatingDifferences: true)
        tv.hideSkeleton(); vc.view.layoutIfNeeded()
        let ok1 = perSection == [["DemoTCell", "DemoTCell"], ["TCell", "TCell"], ["TCell", "TCell"]] && titles == ["s0r0", "s0r1"] && o.rowHeight == 70 && skeleton && bars && o.superview == nil
        log("default: sections=\(perSection) titles=\(titles) skeleton=\(skeleton) bars=\(bars) realRows=\(tv.numberOfRows(inSection: 0)) ok=\(ok1)")

        // 2. per row with cellIdentifierForRowAt
        (tv, ds) = makeTable()
        tv.registerSkeletonCell((type: DemoTCell.self, identifier: "A"), (type: TCell.self, identifier: "B"),
                                numberOfRows: 4, cellIdentifierForRowAt: { $0.row % 2 == 0 ? "A" : "B" })
        tv.showSkeleton(); vc.view.layoutIfNeeded()
        guard let o2 = overlayOf(tv) as? UITableView else { log("FAIL no overlay"); return }
        o = o2; o.layoutIfNeeded()
        let rows = kinds(o, section: 0)
        tv.hideSkeleton(); vc.view.layoutIfNeeded()
        log("perRow: rows=\(rows) ok=\(rows == ["DemoTCell", "TCell", "DemoTCell", "TCell"])")
    }

    /// only the last registerSkeletonCell call is kept; while the skeleton is shown it applies from the next show
    func registerTwice(_ vc: UIViewController) {
        let tv = UITableView(frame: vc.view.bounds); vc.view.addSubview(tv)
        tv.register(TCell.self, forCellReuseIdentifier: "C"); tv.isSkeletonable = true; tv.rowHeight = 80
        let ds = UITableViewDiffableDataSource<Section, Int>(tableView: tv) { t, i, _ in t.dequeueReusableCell(withIdentifier: "C", for: i) }
        keep.append(ds); ds.apply(snapshot([1]), animatingDifferences: false); tv.layoutIfNeeded()
        func describe() -> String {
            guard let o = overlayOf(tv) as? UITableView else { return "no overlay" }
            o.layoutIfNeeded()
            let kind = o.visibleCells.first.map { "\(type(of: $0))" } ?? "-"
            return "\(kind) rowHeight=\(o.rowHeight)"
        }
        tv.registerSkeletonCell(TCell.self, forCellReuseIdentifier: "C", rowHeight: 80)
        tv.registerSkeletonCell((type: DemoTCell.self, identifier: "D"), rowHeight: 64)
        tv.showSkeleton(); vc.view.layoutIfNeeded()
        let first = describe()
        tv.registerSkeletonCell(TCell.self, forCellReuseIdentifier: "C", rowHeight: 100)  // while shown
        vc.view.layoutIfNeeded()
        let whileShown = describe()
        tv.hideSkeleton(); vc.view.layoutIfNeeded()
        tv.showSkeleton(); vc.view.layoutIfNeeded()
        let next = describe()
        tv.hideSkeleton()
        log("twice: first=\(first) | afterRegisterWhileShown=\(whileShown) | nextShow=\(next) ok=\(first == "DemoTCell rowHeight=64.0" && whileShown == first && next == "TCell rowHeight=100.0")")
    }

    /// grid with several items per line: the skeleton must fill every line and reach the bottom
    func cvFill(_ vc: UIViewController) {
        for useDelegate in [false, true] {
            vc.view.subviews.forEach { $0.removeFromSuperview() }
            let l = UICollectionViewFlowLayout(); l.minimumLineSpacing = 10; l.minimumInteritemSpacing = 10
            l.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            if !useDelegate { l.itemSize = CGSize(width: 110, height: 90) }
            let cv = UICollectionView(frame: vc.view.bounds, collectionViewLayout: l); vc.view.addSubview(cv)
            if useDelegate { cv.delegate = sizing }  // 120 x 60 while layout.itemSize stays at the 50 x 50 default
            cv.register(CCell.self, forCellWithReuseIdentifier: "C"); cv.isSkeletonable = true
            cv.registerSkeletonCell(CCell.self, forCellWithReuseIdentifier: "C")
            let ds = UICollectionViewDiffableDataSource<Section, Int>(collectionView: cv) { c, i, _ in c.dequeueReusableCell(withReuseIdentifier: "C", for: i) }
            keep.append(ds); ds.apply(snapshot([1]), animatingDifferences: false)
            cv.showSkeleton(); vc.view.layoutIfNeeded()
            let o = overlayOf(cv) as! UICollectionView; o.layoutIfNeeded()
            let frames = (0..<o.numberOfItems(inSection: 0)).compactMap { o.layoutAttributesForItem(at: IndexPath(item: $0, section: 0))?.frame }
            let perLine = frames.filter { $0.minY == frames[0].minY }.count
            let lastLine = frames.filter { $0.minY == frames.last!.minY }.count
            let reachesBottom = (frames.map { $0.maxY }.max() ?? 0) >= o.bounds.height - 1
            log("fill(\(useDelegate ? "delegate 120x60" : "itemSize 110x90")): items=\(frames.count) perLine=\(perLine) lastLineFull=\(lastLine == perLine) reachesBottom=\(reachesBottom) size=\(frames.first?.size ?? .zero)")
            cv.hideSkeleton()
        }
    }
}

// MARK: - Leaks (not part of "all": showing a skeleton on any view keeps it alive, already on main)

extension SceneDelegate {

    func leak(_ scenario: String, _ vc: UIViewController) {
        weak var weakView: UIView?
        weak var weakDS: AnyObject?
        weak var weakOverlay: UIView?
        autoreleasepool {
            if scenario == "leak-cv" {
                let cv = UICollectionView(frame: vc.view.bounds, collectionViewLayout: UICollectionViewFlowLayout()); vc.view.addSubview(cv)
                cv.register(CCell.self, forCellWithReuseIdentifier: "C"); cv.isSkeletonable = true
                cv.registerSkeletonCell(CCell.self, forCellWithReuseIdentifier: "C")
                let ds = UICollectionViewDiffableDataSource<Section, Int>(collectionView: cv) { c, i, _ in c.dequeueReusableCell(withReuseIdentifier: "C", for: i) }
                ds.apply(snapshot([1, 2]), animatingDifferences: false)
                cv.showSkeleton(); vc.view.layoutIfNeeded(); weakOverlay = overlayOf(cv)
                cv.hideSkeleton(); vc.view.layoutIfNeeded()
                weakView = cv; weakDS = ds
                cv.removeFromSuperview()
            } else {
                let tv = UITableView(frame: vc.view.bounds); vc.view.addSubview(tv)
                tv.register(TCell.self, forCellReuseIdentifier: "C"); tv.rowHeight = 80; tv.isSkeletonable = true
                tv.registerSkeletonCell(TCell.self, forCellReuseIdentifier: "C")
                let ds = UITableViewDiffableDataSource<Section, Int>(tableView: tv) { t, i, _ in t.dequeueReusableCell(withIdentifier: "C", for: i) }
                ds.apply(snapshot([1, 2]), animatingDifferences: false)
                tv.showSkeleton(); vc.view.layoutIfNeeded(); weakOverlay = overlayOf(tv)
                tv.hideSkeleton(); vc.view.layoutIfNeeded()
                weakView = tv; weakDS = ds
                tv.removeFromSuperview()
            }
        }
        RunLoop.main.run(until: Date().addingTimeInterval(2.0))
        log("leak: viewAlive=\(weakView != nil) diffableAlive=\(weakDS != nil) overlayAlive=\(weakOverlay != nil)")
    }

    func leakPlain(_ scenario: String, _ vc: UIViewController) {
        weak var weakView: UIView?
        autoreleasepool {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100)); v.isSkeletonable = true
            let l = UILabel(frame: CGRect(x: 8, y: 8, width: 100, height: 20)); l.isSkeletonable = true; l.text = "x"; v.addSubview(l)
            vc.view.addSubview(v); vc.view.layoutIfNeeded()
            if scenario == "leak-plain" { v.showSkeleton(); vc.view.layoutIfNeeded(); v.hideSkeleton(); vc.view.layoutIfNeeded() }
            weakView = v
            v.removeFromSuperview()
        }
        RunLoop.main.run(until: Date().addingTimeInterval(2.0))
        log("plain: viewAlive=\(weakView != nil)")
    }
}

// MARK: - Visual demo: table (top) + collection (bottom), loops show → apply while skeleton → hide

extension SceneDelegate {

    func demo(_ vc: UIViewController) {
        vc.view.backgroundColor = .systemBackground
        let status = UILabel(); status.font = .boldSystemFont(ofSize: 15); status.textAlignment = .center; status.numberOfLines = 0
        status.translatesAutoresizingMaskIntoConstraints = false
        let tv = UITableView(); tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(DemoTCell.self, forCellReuseIdentifier: "C"); tv.rowHeight = 64; tv.isSkeletonable = true
        tv.registerSkeletonCell(DemoTCell.self, forCellReuseIdentifier: "C")
        let layout = UICollectionViewFlowLayout(); layout.itemSize = CGSize(width: 110, height: 90)
        layout.minimumLineSpacing = 10; layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout); cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(DemoCCell.self, forCellWithReuseIdentifier: "C"); cv.isSkeletonable = true
        cv.registerSkeletonCell(DemoCCell.self, forCellWithReuseIdentifier: "C")
        [status, tv, cv].forEach { vc.view.addSubview($0) }
        let g = vc.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            status.topAnchor.constraint(equalTo: g.topAnchor, constant: 8),
            status.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
            status.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
            tv.topAnchor.constraint(equalTo: status.bottomAnchor, constant: 8),
            tv.leadingAnchor.constraint(equalTo: g.leadingAnchor), tv.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            tv.heightAnchor.constraint(equalTo: g.heightAnchor, multiplier: 0.45),
            cv.topAnchor.constraint(equalTo: tv.bottomAnchor, constant: 8),
            cv.leadingAnchor.constraint(equalTo: g.leadingAnchor), cv.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            cv.bottomAnchor.constraint(equalTo: g.bottomAnchor)
        ])
        let tds = UITableViewDiffableDataSource<Section, Int>(tableView: tv) { t, i, item in
            let c = t.dequeueReusableCell(withIdentifier: "C", for: i) as! DemoTCell; c.title.text = "Row \(item)  (real data)"; return c }
        let cds = UICollectionViewDiffableDataSource<Section, Int>(collectionView: cv) { c, i, item in
            let cell = c.dequeueReusableCell(withReuseIdentifier: "C", for: i) as! DemoCCell; cell.title.text = "Item \(item)"; return cell }
        keep.append(tds); keep.append(cds)
        var round = 0
        func step() {
            round += 1
            let count = 3 + round % 4
            status.text = "① showSkeleton()  (round \(round))"
            tv.showAnimatedGradientSkeleton(); cv.showAnimatedGradientSkeleton()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                status.text = "② apply(\(count) items) WHILE skeleton is shown — no crash"
                tds.apply(snapshot(Array(1...count)), animatingDifferences: true)
                cds.apply(snapshot(Array(1...count)), animatingDifferences: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    status.text = "③ hideSkeleton() → real data (\(count) items)"
                    tv.hideSkeleton(); cv.hideSkeleton()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // only visible cells can be read (on small screens some rows are off screen),
                        // so check the counts, then that every visible cell shows the item at its index path
                        let rowsOk = tv.numberOfRows(inSection: 0) == count && tv.indexPathsForVisibleRows?.allSatisfy {
                            (tv.cellForRow(at: $0) as? DemoTCell)?.title.text == "Row \($0.row + 1)  (real data)"
                        } == true
                        let itemsOk = cv.numberOfItems(inSection: 0) == count && cv.indexPathsForVisibleItems.allSatisfy {
                            (cv.cellForItem(at: $0) as? DemoCCell)?.title.text == "Item \($0.item + 1)"
                        }
                        log("demo round \(round) count=\(count) ok=\(rowsOk && itemsOk) visibleRows=\(tv.indexPathsForVisibleRows?.count ?? 0) visibleItems=\(cv.indexPathsForVisibleItems.count)")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { step() }
                }
            }
        }
        step()
    }
}

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(AppDelegate.self))

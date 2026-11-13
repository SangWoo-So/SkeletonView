//
//  SkeletonDiffableCellRegistration.swift
//  SkeletonView-iOS
//
//  Copyright © 2017 SkeletonView. All rights reserved.
//

import UIKit

public extension UITableView {

    /// Registers the cell used to draw the skeleton when the data source is a `UITableViewDiffableDataSource`.
    ///
    /// The skeleton is drawn on an overlay table view placed above this one, so the diffable
    /// data source never loses its table view and `apply(_:)` keeps working while the skeleton is shown.
    ///
    /// - Parameters:
    ///   - numberOfSections: number of skeleton sections. Default: 1
    ///   - numberOfRows: number of skeleton rows in each section. Default: as many as fit in the table view
    ///   - rowHeight: height of the skeleton rows. Default: the table view's `rowHeight`, else its
    ///     `estimatedRowHeight`, else 44 (useful when both are `automaticDimension`)
    ///   - viewForHeaderInSection: header of each skeleton section (`nil`: no header). Its skeletonable
    ///     subviews are skeletonized like the cells. `section` is the skeleton section, not a snapshot section.
    ///     The closure is kept by the table view: capture `self` weakly.
    ///   - heightForHeaderInSection: header heights. Default: the view's frame height, else its Auto Layout height
    func registerSkeletonCell(_ cellClass: AnyClass?,
                              forCellReuseIdentifier identifier: String,
                              numberOfSections: Int = 1,
                              numberOfRows: Int = UITableView.automaticNumberOfSkeletonRows,
                              rowHeight: CGFloat? = nil,
                              viewForHeaderInSection: ((_ section: Int) -> UIView?)? = nil,
                              heightForHeaderInSection: ((_ section: Int) -> CGFloat)? = nil) {
        skeletonCellRegistration = SkeletonCellRegistration(source: .cellClass(cellClass),
                                                            identifier: identifier,
                                                            numberOfSections: numberOfSections,
                                                            numberOfItems: numberOfRows,
                                                            rowHeight: rowHeight,
                                                            viewForHeaderInSection: viewForHeaderInSection,
                                                            heightForHeaderInSection: heightForHeaderInSection)
    }

    /// Registers several cell classes used to draw the skeleton when the data source is a `UITableViewDiffableDataSource`.
    ///
    /// - Parameters:
    ///   - cells: the cell classes and their reuse identifiers, all registered on the skeleton overlay
    ///   - cellIdentifierForRowAt: identifier of each skeleton row, one of `cells`. Default: section N uses the Nth cell,
    ///     and the sections beyond use the last one
    ///   - prepareCellForSkeleton: called on each skeleton cell before it's skeletonized (e.g. to set placeholder texts)
    ///   - The other parameters are the same as `registerSkeletonCell(_:forCellReuseIdentifier:...)`.
    ///
    /// `indexPath` and `section` are skeleton ones, not ones of your snapshot. The closures are kept by the table view:
    /// capture `self` weakly. Only the last `registerSkeletonCell` call is kept, and registering while the skeleton
    /// is shown applies from the next `showSkeleton`.
    func registerSkeletonCell(_ cells: (type: AnyClass, identifier: String)...,
                              numberOfSections: Int = 1,
                              numberOfRows: Int = UITableView.automaticNumberOfSkeletonRows,
                              rowHeight: CGFloat? = nil,
                              cellIdentifierForRowAt: ((_ indexPath: IndexPath) -> String)? = nil,
                              prepareCellForSkeleton: ((_ cell: UITableViewCell, _ indexPath: IndexPath) -> Void)? = nil,
                              viewForHeaderInSection: ((_ section: Int) -> UIView?)? = nil,
                              heightForHeaderInSection: ((_ section: Int) -> CGFloat)? = nil) {
        guard let first = cells.first else {
            assertionFailure("registerSkeletonCell needs at least one cell")
            return
        }
        skeletonCellRegistration = SkeletonCellRegistration(source: .cellClasses(cells),
                                                            identifier: first.identifier,
                                                            numberOfSections: numberOfSections,
                                                            numberOfItems: numberOfRows,
                                                            rowHeight: rowHeight,
                                                            viewForHeaderInSection: viewForHeaderInSection,
                                                            heightForHeaderInSection: heightForHeaderInSection,
                                                            cellIdentifierForRowAt: cellIdentifierForRowAt,
                                                            prepareCellForSkeleton: prepareCellForSkeleton)
    }

    /// Registers the nib used to draw the skeleton when the data source is a `UITableViewDiffableDataSource`.
    func registerSkeletonCell(_ nib: UINib?,
                              forCellReuseIdentifier identifier: String,
                              numberOfSections: Int = 1,
                              numberOfRows: Int = UITableView.automaticNumberOfSkeletonRows,
                              rowHeight: CGFloat? = nil,
                              viewForHeaderInSection: ((_ section: Int) -> UIView?)? = nil,
                              heightForHeaderInSection: ((_ section: Int) -> CGFloat)? = nil) {
        skeletonCellRegistration = SkeletonCellRegistration(source: .nib(nib),
                                                            identifier: identifier,
                                                            numberOfSections: numberOfSections,
                                                            numberOfItems: numberOfRows,
                                                            rowHeight: rowHeight,
                                                            viewForHeaderInSection: viewForHeaderInSection,
                                                            heightForHeaderInSection: heightForHeaderInSection)
    }
}

public extension UICollectionView {

    /// Registers the cell used to draw the skeleton when the data source is a `UICollectionViewDiffableDataSource`.
    ///
    /// The skeleton is drawn on an overlay collection view placed above this one, so the diffable
    /// data source never loses its collection view and `apply(_:)` keeps working while the skeleton is shown.
    /// Only `UICollectionViewFlowLayout` (and its subclasses) is supported.
    ///
    /// - Parameters:
    ///   - numberOfSections: number of skeleton sections. Default: 1
    ///   - numberOfItems: number of skeleton items in each section. Default: as many as fit in the collection view
    func registerSkeletonCell(_ cellClass: AnyClass?,
                              forCellWithReuseIdentifier identifier: String,
                              numberOfSections: Int = 1,
                              numberOfItems: Int = UICollectionView.automaticNumberOfSkeletonItems) {
        skeletonCellRegistration = SkeletonCellRegistration(source: .cellClass(cellClass),
                                                            identifier: identifier,
                                                            numberOfSections: numberOfSections,
                                                            numberOfItems: numberOfItems)
    }

    /// Registers the nib used to draw the skeleton when the data source is a `UICollectionViewDiffableDataSource`.
    func registerSkeletonCell(_ nib: UINib?,
                              forCellWithReuseIdentifier identifier: String,
                              numberOfSections: Int = 1,
                              numberOfItems: Int = UICollectionView.automaticNumberOfSkeletonItems) {
        skeletonCellRegistration = SkeletonCellRegistration(source: .nib(nib),
                                                            identifier: identifier,
                                                            numberOfSections: numberOfSections,
                                                            numberOfItems: numberOfItems)
    }
}

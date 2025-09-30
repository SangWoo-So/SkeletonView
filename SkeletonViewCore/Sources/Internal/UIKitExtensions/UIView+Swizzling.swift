//
//  Copyright SkeletonView. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  UIView+Swizzling.swift
//
//  Created by Juanpe Catalán on 19/8/21.

import UIKit

extension UIView {

    @objc func skeletonLayoutSubviews() {
        guard Thread.isMainThread else { return }
        skeletonLayoutSubviews()
        guard sk.isSkeletonActive else { return }
        layoutSkeletonIfNeeded()
    }

    @objc func skeletonTraitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        skeletonTraitCollectionDidChange(previousTraitCollection)
        guard isSkeletonable, sk.isSkeletonActive, let config = _currentSkeletonConfig else { return }
        updateSkeleton(skeletonConfig: config)
    }
    
    func swizzleLayoutSubviews() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            DispatchQueue.once(token: "UIView.SkeletonView.swizzleLayoutSubviews") {
                swizzle(selector: #selector(self.layoutSubviews),
                        with: #selector(self.skeletonLayoutSubviews),
                        inClass: Self.self,
                        usingClass: Self.self)
                self.layoutSkeletonIfNeeded()
            }
        }
    }
    
    func unSwizzleLayoutSubviews() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            DispatchQueue.removeOnce(token: "UIView.SkeletonView.swizzleLayoutSubviews") {
                swizzle(selector: #selector(self.skeletonLayoutSubviews),
                        with: #selector(self.layoutSubviews),
                        inClass: Self.self,
                        usingClass: Self.self)
            }
        }
    }
    
    func swizzleTraitCollectionDidChange() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            DispatchQueue.once(token: "UIView.SkeletonView.swizzleTraitCollectionDidChange") {
                swizzle(selector: #selector(self.traitCollectionDidChange(_:)),
                        with: #selector(self.skeletonTraitCollectionDidChange(_:)),
                        inClass: Self.self,
                        usingClass: Self.self)
            }
        }
    }
    
    func unSwizzleTraitCollectionDidChange() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            DispatchQueue.removeOnce(token: "UIView.SkeletonView.swizzleTraitCollectionDidChange") {
                swizzle(selector: #selector(self.skeletonTraitCollectionDidChange(_:)),
                        with: #selector(self.traitCollectionDidChange(_:)),
                        inClass: Self.self,
                        usingClass: Self.self)
            }
        }
    }
    
}

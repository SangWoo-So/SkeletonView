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
        func action () {
            DispatchQueue.once(token: "UIView.SkeletonView.swizzleLayoutSubviews") {
                swizzle(selector: #selector(UIView.layoutSubviews),
                        with: #selector(UIView.skeletonLayoutSubviews),
                        class: UIView.self)
                self.layoutSkeletonIfNeeded()
            }
        }
        if Thread.isMainThread {
            action()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                action()
            }
        }
    }
    
    func unSwizzleLayoutSubviews() {
        func action() {
            DispatchQueue.removeOnce(token: "UIView.SkeletonView.swizzleLayoutSubviews") {
                swizzle(selector: #selector(UIView.skeletonLayoutSubviews),
                        with: #selector(UIView.layoutSubviews),
                        class: UIView.self)
            }
        }
        if Thread.isMainThread {
            action()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                action()
            }
        }
    }
    
    func swizzleTraitCollectionDidChange() {
        func action() {
            DispatchQueue.once(token: "UIView.SkeletonView.swizzleTraitCollectionDidChange") {
                swizzle(selector: #selector(UIView.traitCollectionDidChange(_:)),
                        with: #selector(UIView.skeletonTraitCollectionDidChange(_:)),
                        class: UIView.self)
            }
        }
        if Thread.isMainThread {
            action()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                action()
            }
        }
    }
    
    func unSwizzleTraitCollectionDidChange() {
        func action() {
            DispatchQueue.removeOnce(token: "UIView.SkeletonView.swizzleTraitCollectionDidChange") {
                swizzle(selector: #selector(UIView.skeletonTraitCollectionDidChange(_:)),
                        with: #selector(UIView.traitCollectionDidChange(_:)),
                        class: UIView.self)
            }
        }
        if Thread.isMainThread {
            action()
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                action()
            }
        }
    }
    
}

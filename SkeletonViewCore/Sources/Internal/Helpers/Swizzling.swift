// Copyright © 2019 SkeletonView. All rights reserved.

import Foundation

//func swizzle(selector originalSelector: Selector, with swizzledSelector: Selector, inClass: AnyClass, usingClass: AnyClass) {
//    guard let originalMethod = class_getInstanceMethod(inClass, originalSelector),
//        let swizzledMethod = class_getInstanceMethod(usingClass, swizzledSelector)
//        else { return }
//
//    if class_addMethod(inClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)) {
//        class_replaceMethod(inClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
//    } else {
//        method_exchangeImplementations(originalMethod, swizzledMethod)
//    }
//}

func swizzle(selector originalSelector: Selector, with swizzledSelector: Selector, inClass: AnyClass, usingClass: AnyClass) {
    guard let originalMethod = class_getInstanceMethod(inClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(usingClass, swizzledSelector)
        else { return }
    
    if class_addMethod(inClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)) {
        class_replaceMethod(inClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    }
    else {
        guard let originalIMP = class_getMethodImplementation(inClass, originalSelector), let swizzledIMP = class_getMethodImplementation(usingClass, swizzledSelector) else {
            return
        }
        method_setImplementation(originalMethod, swizzledIMP)
        method_setImplementation(swizzledMethod, originalIMP)
//        method_exchangeImplementations(originalMethod, swizzledMethod)
//        
//        method_setImplementation(origin, <#T##imp: IMP##IMP#>)
    }
}

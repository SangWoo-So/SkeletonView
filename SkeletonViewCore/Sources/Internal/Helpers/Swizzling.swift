// Copyright © 2019 SkeletonView. All rights reserved.

import Foundation

func swizzle(selector originalSelector: Selector, with swizzledSelector: Selector, inClass: AnyClass, usingClass: AnyClass) {
    guard let originalMethod = class_getInstanceMethod(inClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(usingClass, swizzledSelector)
        else { return }

    if class_addMethod(inClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)) {
        class_replaceMethod(inClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

func swizzle(selector originalSelector: Selector, with swizzledSelector: Selector, class cls: AnyClass){
    var resolvedClass:AnyClass = cls
    if let aClass = object_getClass(cls) {
        resolvedClass = aClass
    }
    guard let originalMethod = class_getClassMethod(resolvedClass, originalSelector), let swizzledMethod = class_getClassMethod(resolvedClass, swizzledSelector) else { return }
    
    let originalIMP = method_getImplementation(originalMethod)
    let swizzledIMP = method_getImplementation(swizzledMethod)
    if class_addMethod(resolvedClass, swizzledSelector, originalIMP, method_getTypeEncoding(originalMethod)) {
        class_replaceMethod(resolvedClass, originalSelector, swizzledIMP, method_getTypeEncoding(swizzledMethod))
    }
    else {
        method_setImplementation(originalMethod, swizzledIMP)
        method_setImplementation(swizzledMethod, originalIMP)
    }
}


//func swizzle(selector originalSelector: Selector, with swizzledSelector: Selector, inClass: AnyClass, usingClass: AnyClass) {
//    guard let c_inClass = object_getClass(inClass), let c_usingClass = object_getClass(usingClass) else { return }
//    guard let originalMethod = class_getInstanceMethod(c_inClass, originalSelector),
//        let swizzledMethod = class_getInstanceMethod(c_usingClass, swizzledSelector)
//        else { return }
//    
//    if class_addMethod(c_inClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)) {
//        class_replaceMethod(c_inClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
//    }
//    else {
////        method_exchangeImplementations(originalMethod, swizzledMethod)
//        guard let originalIMP = class_getMethodImplementation(c_inClass, originalSelector), let swizzledIMP = class_getMethodImplementation(c_usingClass, swizzledSelector) else {
//            return
//        }
//        method_setImplementation(originalMethod, swizzledIMP)
//        method_setImplementation(swizzledMethod, originalIMP)
////        
////        method_setImplementation(origin, <#T##imp: IMP##IMP#>)
//    }
//}

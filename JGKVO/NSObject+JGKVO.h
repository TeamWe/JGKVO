//
//  NSObject+JGKVO.h
//  JGKVO
//
//  Created by jiguang on 16/8/23.
//  Copyright © 2016年 jiguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JGKVO)
- (void) jg_addObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
- (void) jg_observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context;

- (void)jg_willChangeValueForKey:(nullable NSString *)key;

- (void)jg_didChangeValueForKey:(nullable NSString *)key;

@end

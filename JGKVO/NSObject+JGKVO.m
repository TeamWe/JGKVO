//
//  NSObject+JGKVO.m
//  JGKVO
//
//  Created by jiguang on 16/8/23.
//  Copyright © 2016年 jiguang. All rights reserved.
//

#import "NSObject+JGKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString *key;
id kvoObserve;
static void jg_setValue(id self, SEL _cmd, id newValue){
    [self setValue:newValue forKey:key];
    objc_msgSend();
    SEL cmd = @selector(jg_observeValueForKeyPath:ofObject:change:context:);
    void (*objc_kvoSend)(id self,SEL _cmd,NSString *,id,NSDictionary *, void *) = (void *)objc_msgSend;
    objc_kvoSend(kvoObserve,cmd,key,nil,nil,nil);
}

static NSString* jg_getGetter(const NSString *setter){
    if([setter length]<=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"])
        return nil;
    NSString *getString = [setter substringFromIndex:4];
    return getString;
}

static NSString* jg_getSetter(const NSString *getter){
    
    if([getter length] <= 0)
        return nil;
    
    NSString *firstString = [[getter substringToIndex:1]localizedUppercaseString];
    NSString *otherString = [getter substringFromIndex:1];
    NSString *setter = [NSString stringWithFormat:@"set%@%@",firstString,otherString];
    
    return setter;
}

@implementation NSObject (JGKVO)
- (void) jg_addObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context{
    Class currentClass = [self class];
    key = keyPath;
    kvoObserve = observer;
//    const char *superName = class_getName(currentClass);
    NSString *currentString = NSStringFromClass(currentClass);
    
    if(![currentString hasPrefix:@"jg_kvo_"]){
        NSString *name = [NSString stringWithFormat:@"jg_kvo_%@",currentClass];
        currentClass = jg_createSubClass([name UTF8String], self);
        object_setClass(self, currentClass);
    }
    
    
    NSString *setter = jg_getSetter(keyPath);
    
    if(![self jg_HasSelector:NSSelectorFromString(setter)]){
        
        class_addMethod(currentClass, NSSelectorFromString(setter), (IMP)jg_setValue, "v@:@");
    }
    
    
}
//判断是否存在某个方法当前类内
- (BOOL)jg_HasSelector:(SEL)selector{
    Class class = [self class];
    unsigned count;
    Method *methods = class_copyMethodList(class, &count);
    for (int i=0; i<count; i++) {
        SEL sel = method_getName(methods[i]);
        if(sel == selector){
            free(methods);
            return YES;
        }
    }
    free(methods);
    return NO;
}

- (void) jg_observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context{
    
}

- (void)jg_willChangeValueForKey:(nullable NSString *)key{
    
}

- (void)jg_didChangeValueForKey:(nullable NSString *)key{
    
}

Class jg_createSubClass(const char *name,id self){

//    va_list args; 加入clas的判断
    Class superClass = [self class];
    
    Class newClass = objc_allocateClassPair(superClass,name,0);
    
    objc_registerClassPair(newClass);
    
    return newClass;
}




@end

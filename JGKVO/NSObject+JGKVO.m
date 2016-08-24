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
//    --内存泄漏这样会一直掉用这个方法然后就崩了,这是一只掉用的子类的方法然后一直循环引用，看堆栈信息可以得到
//    [self setValue:newValue forKey:key];

    id oldValue = [self valueForKey:key];
    
    if (newValue) {
        //掉用父类方法来赋值
        struct objc_super superclazz = {
            .receiver = self,
            .super_class = class_getSuperclass(object_getClass(self))
        };
        
        // cast our pointer so the compiler won't complain
        void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
        
        // call super's setter, which is original class's setter method
        objc_msgSendSuperCasted(&superclazz, _cmd, newValue);
        
    }
    
    SEL cmd = @selector(jg_observeValueForKeyPath:ofObject:change:context:);
    void (*objc_kvoSend)(id self,SEL _cmd,NSString *,id,NSDictionary *, void *) = (void *)objc_msgSend;
    NSLog(@"i'm come：%@",key);
    objc_kvoSend(kvoObserve,cmd,key,oldValue,nil,nil);
}

static NSString* jg_getSetter(const NSString *getter){
    
    if([getter length] <= 0)
        return nil;
    
    NSString *firstString = [[getter substringToIndex:1]localizedUppercaseString];
    NSString *otherString = [getter substringFromIndex:1];
    NSString *setter = [NSString stringWithFormat:@"set%@%@:",firstString,otherString];
    
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
    
    if(![currentClass jg_HasSelector:NSSelectorFromString(setter)]){
        
        class_addMethod(currentClass, NSSelectorFromString(setter), (IMP)jg_setValue, "v@:@");
        NSLog(@"setter is:%@",setter);
    }
    
    
}
//判断是否存在某个方法当前类内,继承下来的不会有变化
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
    jg_setValue(self, _cmd, nil);
}

Class jg_createSubClass(const char *name,id self){

//    va_list args; 加入clas的判断
    Class superClass = [self class];
    
    Class newClass = objc_allocateClassPair(superClass,name,0);
    
    //只需要修改实例方法因为人家类方法就永远不会掉用到。。
    const char*type = method_getTypeEncoding(class_getInstanceMethod(superClass, @selector(class)));
    IMP imp = imp_implementationWithBlock(^(){
        return superClass;
    });
    class_addMethod(newClass, @selector(class), imp, type);
    
    
    objc_registerClassPair(newClass);
    
    return newClass;
}




@end

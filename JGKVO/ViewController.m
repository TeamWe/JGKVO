//
//  ViewController.m
//  JGKVO
//
//  Created by jiguang on 16/8/23.
//  Copyright © 2016年 jiguang. All rights reserved.
//

#import "ViewController.h"
#import "JGModel.h"
#import "NSObject+JGKVO.h"
#import <objc/runtime.h>
@interface ViewController (){
    JGModel *model;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    model = [[JGModel alloc]init];
    
    [model jg_addObserver:self forKeyPath:@"kvoString" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
    model.kvoString = @"123";
//    NSLog(@"%@and%@",model.kvoString,[JGModel class]);
    
    
}

- (void)jg_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSLog(@"%@",keyPath);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [model jg_willChangeValueForKey:@"kvoString"];
    [model jg_didChangeValueForKey:@"kvoString"];
}


@end

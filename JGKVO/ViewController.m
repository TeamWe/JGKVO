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
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    JGModel *model = [[JGModel alloc]init];
    
    [model jg_addObserver:self forKeyPath:@"kvoString" options:NSKeyValueObservingOptionNew context:nil];
    
    model.kvoString = @"123";
    NSLog(@"%@and%@",model.kvoString,[model class]);
}

- (void)jg_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSLog(@"11");
}


@end

//
//  MyOperation.m
//  NSOpreationDemo
//
//  Created by sven on 16/12/3.
//  Copyright © 2016年 song ximing. All rights reserved.
//

#import "MyOperation.h"

@implementation MyOperation
- (void)main {
    NSLog(@"sven's operation---当前线程%@",[NSThread currentThread]);
    
    
    // 正式开始执行任务之前检查
    if (self.isCancelled) {
        return;
    }
    
    for (int i = 0; i < 10; i++) {
        // 每个循环开始之前检查
        if (self.isCancelled) {
            NSLog(@"退出当前任务");
            return;
        }
        
        // 一个漫长的任务
    }
    
    // 阶段性任务之间检查
//    [self processLongTask];
}
@end

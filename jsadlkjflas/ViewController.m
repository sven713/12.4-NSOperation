//
//  ViewController.m
//  jsadlkjflas
//
//  Created by sven on 16/11/20.
//  Copyright © 2016年 sven. All rights reserved.
//

#import "ViewController.h"
#import "MyOperation.h"

@interface ViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:self.imageView];
    self.imageView.backgroundColor = [UIColor orangeColor];
    //当前主线程
//    NSLog(@"当前线程：%@",[NSThread currentThread]);//获取一个全局的并行队列
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    
//    //同步添加任务
//    dispatch_sync(queue, ^{ // 全局队列可以走,
//        NSLog(@"任务1，当前线程：%@",[NSThread currentThread]);
//    });
//    
//    dispatch_sync(dispatch_get_main_queue(), ^{ // 主队列不能走,why
//        NSLog(@"会打印么?");
//    });
//    
//    NSLog(@"会--打印么?");
    
//    dispatch_sync(queue, ^{
//        NSLog(@"任务2，当前线程：%@",[NSThread currentThread]);
//    });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self blockOp]; // 测试NSBlockOperation
    MyOperation *op = [[MyOperation alloc]init];
    [op cancel];
    [op start]; // 直接start是主线程
//    [self operationQueue]; // 测试operationQueue
    
//    [self comminuteThrowThread]; // 线程间通信--------------------->
//    [self blockThread];
//    [self depandance]; // 依赖
}

- (void)depandance {
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"写上面的操作");
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"写下面的操作");
    }];
    
//    [op1 addDependency:op2];
    
    [[NSOperationQueue mainQueue] addOperation:op1];
    [[NSOperationQueue mainQueue] addOperation:op2];
}

- (void)blockThread { // 阻塞线程,直接start并没有阻塞
    NSLog(@"开始.%@",[NSThread currentThread]);
//    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
//    [queue addOperationWithBlock:^{
//        
//    }];
    NSBlockOperation *OP = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"会打印么-%@",[NSThread currentThread]);
    }];
    [OP start];
    NSLog(@"能到这么?");
}

- (void)blockOp {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation--thread%@",[NSThread currentThread]);
    }];
    
    [op addExecutionBlock:^{ // 添加超过一个就会异步执行
        NSLog(@"task2--%@",[NSThread currentThread]);
    }];
    
    [op addExecutionBlock:^{
        NSLog(@"task3--%@",[NSThread currentThread]);
    }];
    
    [op addExecutionBlock:^{
        NSLog(@"task4--%@",[NSThread currentThread]);
    }];
    
//    [op start]; // 同步 操作开始执行，或者操作结束的时候不能再添加到操作中，会崩溃, 任务执行的线程是随机的,跟添加的先后没关系
    [op start];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op依赖操作-第二个op");
    }];
    [op1 start];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op依赖操作-第三个op");
    }];
    [op2 addDependency:op]; // 依赖测试
    [op2 addDependency:op1];
    
    op2.completionBlock = ^{ // 任务完成的回调,要写在start前面
        NSLog(@"任务完成了");
    };
    [op2 start]; // 每个NSOperation都要Start不然不会执行
    
}

- (void)operationQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue setMaxConcurrentOperationCount:3]; // 并发数1 串行, 但是任务所在的线程不确定,不是主线程
    [queue addOperationWithBlock:^{
        NSLog(@"operationQueue mession1--%@",[NSThread currentThread]);
    }];
    
    [queue addOperationWithBlock:^{
        NSLog(@"operationQueue mession2--%@",[NSThread currentThread]);
    }];
//    [queue cancelAllOperations]; // 能取消全部么 最后添加的不会执行
    [queue addOperationWithBlock:^{
        NSLog(@"operationQueue mession3--%@",[NSThread currentThread]);
    }];
}

- (void)comminuteThrowThread {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:@"http://www.gdpx.com.cn/files/modimg/2001_big.jpg"]; // url浏览器可以访问,但是客户端显示不出来
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSLog(@"data-->%@",data);
//        if (data) {
//            [self performSelectorOnMainThread:@selector(refreshImage:) withObject:data waitUntilDone:NO]; // 回到主线程更新UI
//        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = [UIImage imageWithData:data]; // 主线程更新UI 第二种方式
        }];
        
//        NSURL *url = [NSURL URLWithString:@"http://img.pconline.com.cn/images/photoblog/9/9/8/1/9981681/200910/11/1255259355826.jpg"];
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        NSLog(@"data--><--%@",data);
//        UIImage *image = [[UIImage alloc] initWithData:data];
//        // 回到主线程进行显示
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            self.imageView.image = image;
//        }];
    }];
}

- (void)refreshImage:(NSData *)data {
    self.imageView.image = [UIImage imageWithData:data];
}

@end

//blockOperation--thread<NSThread: 0x7fde6ac022b0>{number = 1, name = main}
//    2016-12-01 00:27:30.588 jsadlkjflas[12475:1113954] task4--<NSThread: 0x7fde6ac022b0>{number = 1, name = main}
//    2016-12-01 00:27:30.588 jsadlkjflas[12475:1114145] task2--<NSThread: 0x7fde6ac2ec10>{number = 2, name = (null)}
//    2016-12-01 00:27:30.589 jsadlkjflas[12475:1114561] task3--<NSThread: 0x7fde6ac2ef80>{number = 3, name = (null)}
// http://www.jianshu.com/p/2de9c776f226
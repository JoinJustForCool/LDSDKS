//
//  LDBus.m
//  Future
//
//  Created by 洛洛 on 2020/12/22.
//

#import "LDBus.h"

typedef enum : NSUInteger {
    LDBusTypeUnset,//未设置
    LDBusTypeSerial,//串行
    LDBusTypeConcurrent,//并发
} LDBusType;

@interface LDBus ()

typedef void (^NetBlock)(id obj);
/**
 信号量
 */
@property (retain , nonatomic) dispatch_semaphore_t semaphore;

/**
 类型
 */
@property (nonatomic , assign) LDBusType  busType;

/**
串行使用串行队列，并发使用并发队列
 */
@property (nonatomic , retain) dispatch_queue_t queue;

/**
 并发使用的group
 */
@property (nonatomic , strong) dispatch_group_t group;


@end

@implementation LDBus

- (instancetype)init{
    self = [super init];
    
    
    return self;
}
//串行
- (LDBus *(^)(LDParameter *s,ResponseBlock responseBlock))serial{
    if (self.busType == LDBusTypeUnset) {
        self.busType = LDBusTypeSerial;
    }
    
    if (self.busType != LDBusTypeSerial) {
        NSException *e = [NSException exceptionWithName:@"任务管理错误" reason:@"暂时不支持串行和并发混合模式" userInfo:nil];
        @throw e;
    }
    
    return ^(LDParameter *s,ResponseBlock responseBlock){
        __weak typeof(self) weakSelf = self;
        if (!self.queue) {
            self.queue = dispatch_queue_create("task", DISPATCH_QUEUE_SERIAL);
        }
        dispatch_async(self.queue, ^{
            if (!self.semaphore) {
                self.semaphore = dispatch_semaphore_create(0);
            }
            [self performNetTaskWithParameter:s netBlock:^(id obj) {
                responseBlock(obj);
                //发信号 通知任务执行完毕
                dispatch_semaphore_signal(weakSelf.semaphore);
            }];
            //等待任务执行完毕
            dispatch_semaphore_wait(weakSelf.semaphore, DISPATCH_TIME_FOREVER);
        });
        return self;
    };
}

//并行
- (LDBus *(^)(LDParameter *s,ResponseBlock responseBlock))concurrent{
    if (self.busType == LDBusTypeUnset) {
        self.busType = LDBusTypeConcurrent;
    }
    
    if (self.busType != LDBusTypeConcurrent) {
        NSException *e = [NSException exceptionWithName:@"任务管理错误" reason:@"暂时不支持串行和并发混合模式" userInfo:nil];
        @throw e;
    }
    
    return ^(LDParameter *s,ResponseBlock responseBlock){
        
        if (!self.group) {
            self.group = dispatch_group_create();
        }
        if (!self.queue) {
            self.queue = dispatch_queue_create("groupQueue", DISPATCH_QUEUE_CONCURRENT);
        }
        dispatch_group_enter(self.group);
        dispatch_group_async(self.group,self.queue, ^{
            [self performNetTaskWithParameter:s netBlock:^(id obj) {
                responseBlock(obj);
                //发信号 通知任务执行完毕
                dispatch_group_leave(self.group);
            }];
        });
        return self;
    };
}



//
- (void (^)(ResponseBlock responseBlock))end{
    return ^(ResponseBlock responseBlock){
        if (self.busType == LDBusTypeSerial) {
            dispatch_async(self.queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    responseBlock(@"");
                });
            });
        }else if(self.busType == LDBusTypeConcurrent){
            dispatch_group_notify(self.group, dispatch_get_main_queue(), ^{
                NSLog(@"所有任务执行完毕");
                responseBlock(@"");
            });
        }else{
            NSException *e = [NSException exceptionWithName:@"任务管理错误" reason:@"未添加可执行任务" userInfo:nil];
            @throw e;
        }
    };
}

//自定义的网络请求方法
- (void)performNetTaskWithParameter:(LDParameter *)paramater netBlock:(NetBlock)netBlock{
    NSString *str = paramater.url;
    //* 这里添加自己的网络请求方法 记得网络请求完成调用 netBlock();
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSLog(@"%@",[NSThread currentThread]);
    NSLog(@"%@---%@",paramater,paramater.url);
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"%@---%@",paramater,paramater.url);
        netBlock(data);
    }];
    [task resume];
}


@end

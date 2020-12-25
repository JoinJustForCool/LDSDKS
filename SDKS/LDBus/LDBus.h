//
//  LDBus.h
//  Future
//
//  Created by 洛洛 on 2020/12/22.
//

#import <Foundation/Foundation.h>
#import "LDParameter.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ResponseBlock)(id obj);

@interface LDBus : NSObject

//串行
- (LDBus *(^)(LDParameter *s,ResponseBlock b))serial;
//并发
- (LDBus *(^)(LDParameter *s,ResponseBlock b))concurrent;
//全部执行完回调的方法
- (void (^)(ResponseBlock b))end;

@end

NS_ASSUME_NONNULL_END

//
//  NPNetParameter.h
//  Future
//
//  Created by 洛洛 on 2020/12/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//网络请求类型
typedef enum : NSUInteger {
    LDNetTypeGet,
    LDNetTypePost,
} LDNetType;

@interface LDParameter : NSObject

/**
 请求地址
 */
@property (nonatomic , copy)NSString *url;

/**
 网络请求类型
 get post 可扩展
 */
@property (nonatomic , assign) LDNetType  netType;

/**
 请求参数
 可以通过修改这个参数来让后一个请求的参数依赖前一个网络请求得到的数据。
 */
@property (nonatomic , strong)NSMutableDictionary *parameter;


@end

NS_ASSUME_NONNULL_END

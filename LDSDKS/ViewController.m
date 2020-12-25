//
//  ViewController.m
//  LDSDKS
//
//  Created by 洛洛 on 2020/12/24.
//

#import "ViewController.h"
#import "LDBus.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testUI];
}


- (void)testUI{
    float value = (float)0xdf/0xff;
    self.view.backgroundColor = [UIColor colorWithRed:value green:value blue:value alpha:1];
    
    
    UIView *busView =  [[UIView alloc] init];
    busView.backgroundColor = [UIColor whiteColor];
    busView.frame = CGRectMake(15, 50, CGRectGetWidth(self.view.frame)-30, 80);
    [self.view addSubview:busView];
    busView.layer.cornerRadius = 5;
    busView.layer.masksToBounds = YES;
    
    UIButton *asyncButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [asyncButton setBackgroundColor:[UIColor blackColor]];
    [asyncButton setTitle:@"async" forState:UIControlStateNormal];
    asyncButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [asyncButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    asyncButton.frame = CGRectMake(20, 20, 100, 40);
    asyncButton.layer.cornerRadius = 5;
    asyncButton.layer.masksToBounds = YES;
    [busView addSubview:asyncButton];
    
    UIButton *syncButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [syncButton setBackgroundColor:[UIColor blackColor]];
    [syncButton setTitle:@"sync" forState:UIControlStateNormal];
    syncButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [syncButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    syncButton.frame = CGRectMake(CGRectGetWidth(busView.frame)-20-100, 20, 100, 40);
    syncButton.layer.cornerRadius = 5;
    syncButton.layer.masksToBounds = YES;
    [busView addSubview:syncButton];
    
    
    [asyncButton addTarget:self action:@selector(asyncAction:) forControlEvents:UIControlEventTouchUpInside];
    [syncButton addTarget:self action:@selector(syncAction:) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)asyncAction:(UIButton *)button{
    // 接口地址，参数
    LDParameter *p1 = [[LDParameter alloc] init];
    p1.url = @"https://www.baidu.com/";
    
    LDParameter *p2 = [[LDParameter alloc] init];
    p2.url = @"https://www.baidu.com/";
    
    LDBus *bus = [[LDBus alloc] init];
    //next&next next&end 可以连接 在一起也可以分开写。
    bus.concurrent(p1,^(id obj){
        NSLog(@"%@",obj);
        p2.url = @"https://www.baidu.com/?o=0";
        sleep(2);
    })
    .concurrent(p2,^(id obj){
        NSLog(@"%@",obj);
    })
    .end(^(id obj){
        NSLog(@"全部完成");
    });
    
    NSLog(@"主线程阻塞了吗？");
}

- (void)syncAction:(UIButton *)button{
    // 接口地址，参数
    LDParameter *p1 = [[LDParameter alloc] init];
    p1.url = @"https://www.baidu.com/";
    
    LDParameter *p2 = [[LDParameter alloc] init];
    p2.url = @"https://www.baidu.com/";
    
    LDBus *bus = [[LDBus alloc] init];
    //next&next next&end 可以连接 在一起也可以分开写。
    bus.serial(p1,^(id obj){
        NSLog(@"%@",obj);
//        可以修改下一个请求的参数 和 请求方式
        p2.url = @"https://www.baidu.com/?o=0";
        sleep(2);
    })
    .serial(p2,^(id obj){
        NSLog(@"%@",obj);
    })
    .end(^(id obj){
        NSLog(@"全部完成");
    });

    NSLog(@"主线程阻塞了吗？");
}

@end

//
//  ViewController.m
//  WidgetTest
//
//  Created by huangjian on 2018/8/8.
//  Copyright © 2018年 huangjian. All rights reserved.
//

#import "ViewController.h"

static ViewController *vc = nil;
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (nonatomic,assign)NSInteger number;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *value=[self readDataFromNSUserDefaults];
    self.numberLabel.text=@"0";
    self.number=0;
    if (value) {
        self.numberLabel.text=value;
        self.number=[value integerValue];
    }
    vc=self;
    [self addObserver];
}
// 添加监听

- (void)addObserver
{
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterAddObserver(notification, (__bridge const void *)(self), observerMethod, CFSTR("widgetNoti"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

void observerMethod (CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSString *value=[vc readDataFromNSUserDefaults];
    if (value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            vc.number=[value integerValue];
            vc.numberLabel.text=value;
        });
    }
    NSDictionary  *nsdic = (__bridge_transfer  NSDictionary*)userInfo;
    NSLog(@"hahahaha -%@",nsdic);
}

// 移除监听
- (void)removeObserver
{
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterRemoveObserver(notification, (__bridge const void *)(self), CFSTR("widgetNoti"), NULL);
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.number++;
    self.numberLabel.text=[NSString stringWithFormat:@"%ld",self.number];
    [self saveDataByNSUserDefaults:[NSString stringWithFormat:@"%ld",self.number]];
}

- (void)saveDataByNSUserDefaults:(NSString *)value
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.atomi.atomites"];
    [shared setObject:value forKey:@"widget"];
    [shared synchronize];
}
- (NSString *)readDataFromNSUserDefaults
{
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.atomi.atomites"];
    NSString *value = [shared valueForKey:@"widget"];
    return value;
}

@end

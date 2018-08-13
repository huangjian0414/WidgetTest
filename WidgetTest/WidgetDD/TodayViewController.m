//
//  TodayViewController.m
//  WidgetDD
//
//  Created by huangjian on 2018/8/8.
//  Copyright © 2018年 huangjian. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <MJExtension.h>
#import "MModel.h"
#import "HelloWorld.h"
static TodayViewController *vc=nil;
@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (nonatomic,assign)NSInteger number;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //设置这个才有展开按钮
    if (@available(iOS 10.0, *)) {
        self.extensionContext.widgetLargestAvailableDisplayMode=NCWidgetDisplayModeExpanded;
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(numberChange:) name:@"numberChange" object:nil];
    vc=self;
    [self addObserver];
    self.numberLabel.text=@"";
    MModel *model=[MModel mj_objectWithKeyValues:@{@"hello":@"你好啊"}];
    NSLog(@"---%@",model.hello);
    self.imgView.image=[UIImage imageNamed:@"dd"];
}
-(void)numberChange:(NSNotification *)noti
{
    NSString *value=[self readDataFromNSUserDefaults];
    self.number=0;
    if (value) {
        self.number=[value integerValue];
    }
    self.numberLabel.text=[NSString stringWithFormat:@"%ld",self.number];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *value=[self readDataFromNSUserDefaults];
    self.number=0;
    if (value) {
        self.number=[value integerValue];
    }
    self.numberLabel.text=[NSString stringWithFormat:@"%ld",self.number];
}
// 发送通知
- (void)postNotificaiton
{
    CFStringRef keys[1];
    keys[0] = CFSTR("wiwi");
    CFStringRef values[1];
    values[0] = CFSTR("90");
    CFDictionaryRef dic = CFDictionaryCreate(NULL, (void*)keys,(void*)values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterPostNotification(notification, CFSTR("widgetNoti"), NULL, dic, YES);
    
}
// 添加监听
- (void)addObserver
{
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterAddObserver(notification, (__bridge const void *)(self), observerMethod, CFSTR("widgetNoti1"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

void observerMethod (CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSString *value=[vc readDataFromNSUserDefaults];
    if (value) {
        dispatch_async(dispatch_get_main_queue(), ^{
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
    CFNotificationCenterRemoveObserver(notification, (__bridge const void *)(self), CFSTR("widgetNoti1"), NULL);
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
- (IBAction)add:(UIButton *)sender {
    self.number++;
    self.numberLabel.text=[NSString stringWithFormat:@"%ld",self.number];
    [self saveDataByNSUserDefaults:[NSString stringWithFormat:@"%ld",self.number]];
    [self postNotificaiton];
}
- (IBAction)delete:(UIButton *)sender {
    self.number--;
    self.numberLabel.text=[NSString stringWithFormat:@"%ld",self.number];
    [self saveDataByNSUserDefaults:[NSString stringWithFormat:@"%ld",self.number]];
    [self postNotificaiton];
}
- (IBAction)goApp:(UIButton *)sender {
    [self openURLContainingAPP];
}
//通过openURL的方式启动Containing APP
- (void)openURLContainingAPP
{
    //scheme为app的scheme
    [self.extensionContext openURL:[NSURL URLWithString:@"WidgetTest://"]
                 completionHandler:^(BOOL success) {
                     NSLog(@"open url result:%d",success);
                 }];
}
-(void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize
API_AVAILABLE(ios(10.0)){
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 110);
    } else {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 528);
    }
    
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end

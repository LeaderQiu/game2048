//
//  JJMessageViewController.m
//  game2048
//
//  Created by Jason on 15/1/29.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "JJMessageViewController.h"

@interface JJMessageViewController ()

@end

@implementation JJMessageViewController

#define JJScreenWidth [UIScreen mainScreen].bounds.size.width
#define JJScreenHeight [UIScreen mainScreen].bounds.size.height
#define JJApplication [UIApplication sharedApplication]

// 显示的提示信息栏
static UIView *_messageView;

/**
 *  显示提示信息 - 霓虹效果
 *
 *  @param messageContent 信息的内容
 *  @param timeInterval   信息显示的时长,秒数
 */
- (void)showMessageInBottom:(NSString *)messageContent withDuration:(NSTimeInterval)timeInterval {
    if ( _messageView != nil ) return;
    
    CGFloat viewHeight = UIInterfaceOrientationIsLandscape(JJApplication.statusBarOrientation) ? 30.f : 40.f;
    
    
    _messageView = [[UIView alloc] initWithFrame:CGRectMake(0, JJScreenHeight - viewHeight, JJScreenWidth, viewHeight)];
    
    _messageView.backgroundColor = UIInterfaceOrientationIsLandscape(JJApplication.statusBarOrientation) ? [UIColor colorWithRed:.85 green:.9 blue:.9 alpha:1] : [UIColor grayColor];
    [[UIApplication sharedApplication].keyWindow addSubview:_messageView];
    
    // 创建一个显示文字的Label, 设置Label长度为自适应文字，居中显示
    UILabel *label = [[UILabel alloc] init];
    label.text = messageContent;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    [label sizeToFit];
    label.center = CGPointMake(- label.bounds.size.width * .5, _messageView.bounds.size.height * .5);
    [_messageView addSubview:label];
    
    
    [UIView animateWithDuration:.8 animations:^{
        label.center = CGPointMake(_messageView.bounds.size.width * .5, _messageView.bounds.size.height * .5);
        
    } completion:^(BOOL finished) {
        // 为每个文字添加不同的色彩, 间隔显示
        NSMutableAttributedString *msg = [[NSMutableAttributedString alloc] initWithString:messageContent];
        
        for ( int i = 0; i < msg.length; i ++ ) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/msg.length * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [msg addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:arc4random_uniform(2) green:arc4random_uniform(2) blue:arc4random_uniform(2) alpha:1] range:NSMakeRange(i, 1)];
                label.attributedText = msg;
            });
        }
        
        [UIView animateWithDuration:1 delay:timeInterval options:UIViewAnimationOptionCurveEaseOut animations:^{
            _messageView.alpha = 0;
        } completion:^(BOOL finished) {
            _messageView = nil;
        }];
    }];
}

/*
 屏幕旋转
 
 1. 从视图中移除提示条
 
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // 将提示条移除
    [_messageView removeFromSuperview];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

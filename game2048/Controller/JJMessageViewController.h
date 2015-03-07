//
//  JJMessageViewController.h
//  game2048
//
//  Created by Jason on 15/1/29.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJMessageViewController : UIViewController

/**
 在屏幕底部显示信息，设置持续时间
 */
- (void)showMessageInBottom:(NSString *)messageContent withDuration:(NSTimeInterval)timeInterval;

@end

//
//  JJCellView.h
//  二手设备
//
//  Created by Jason on 15/1/23.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJCellView : UIView
// 格子中的数字
@property (nonatomic, assign) int num;
//
@property (nonatomic, assign) int initNum;
@property (nonatomic, strong) NSDictionary *color;
@property (nonatomic, assign) float redColor;
@property (nonatomic, assign) float greenColor;
@property (nonatomic, assign) float blueColor;

@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@end

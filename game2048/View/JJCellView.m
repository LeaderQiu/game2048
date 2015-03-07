//
//  JJCellView.m
//  二手设备
//
//  Created by Jason on 15/1/23.
//  Copyright (c) 2015年 jason. All rights reserved.
//
#import "JJCellView.h"
@interface JJCellView ()

@end

@implementation JJCellView

/*
 Cell背景色设定
 
 */
- (NSDictionary *)color {
    if ( _color == nil ) {
        _color = @{
//                   @"back-0":@[@(160/255.0), @(160/255.0), @(163/255.0)],
//                   @"back-2":@[@(232/255.0), @(222/255.0), @(229/255.0)],
//                   @"back-4":@[@(224/255.0), @(226/255.0), @(219/255.0)],
//                   @"back-8":@[@(233/255.0), @(201/255.0), @(213/255.0)],
                   
                   
//                   @"back-16":@[@(218/255.0), @(210/255.0), @(233/255.0)],
//                   @"back-32":@[@(191/255.0), @(209/255.0), @(227/255.0)],
//                   @"back-64":@[@(197/255.0), @(223/255.0), @(191/255.0)],
//                   @"back-128":@[@(233/255.0), @(217/255.0), @(165/255.0)],
//                   @"back-256":@[@(173/255.0), @(227/255.0), @(234/255.0)],
                   
                   @"back-512":@[@(213/255.0), @(110/255.0), @(120/255.0)],
                   
                   @"back-1024":@[@(224/255.0), @(212/255.0), @(209/255.0)],
                   
                   @"back-2048":@[@(224/255.0), @(212/255.0), @(209/255.0)],
                   @"back-4096":@[@(224/255.0), @(212/255.0), @(209/255.0)],
                   @"back-8192":@[@(224/255.0), @(212/255.0), @(209/255.0)],
                   @"back-16384":@[@(224/255.0), @(212/255.0), @(209/255.0)],
                   @"back-32768":@[@(224/255.0), @(212/255.0), @(209/255.0)],
                   @"back-65536":@[@(224/255.0), @(212/255.0), @(209/255.0)],
                   @"back-131072":@[@(224/255.0), @(212/255.0), @(209/255.0)],
                   
                   @"back-0":@[@(90/255.0), @(96/255.0), @(105/255.0)],
                   @"back-2":@[@(166/255.0), @(156/255.0), @(189/255.0)],
//                   @"back-4":@[@(122/255.0), @(102/255.0), @(122/255.0)],
                   @"back-4":@[@(146/255.0), @(166/255.0), @(146/255.0)],
                   
                   @"back-8":@[@(233/255.0), @(201/255.0), @(213/255.0)],
                   @"back-16":@[@(251/255.0), @(194/255.0), @(128/255.0)],
                   @"back-32":@[@(191/255.0), @(209/255.0), @(227/255.0)],
                   @"back-64":@[@(197/255.0), @(233/255.0), @(191/255.0)],
                   @"back-128":@[@(233/255.0), @(217/255.0), @(165/255.0)],
                   @"back-256":@[@(173/255.0), @(227/255.0), @(234/255.0)],
                   
//                  130	36	37 251	194	128 198	255	255
                   };
    }
    return _color;
}

/*
 设置Cell的num值
 
 1. 设置Cell的num值
 2. 设置Cell的numLabel内容 及内容字体的颜色
 3. 设置Cell的背景色
 4. 将背景色重绘到Cell上
 */
- (void)setNum:(int)num {
    // 1. 设置num
    _num = num;
    
    // 2. 在cell的numLabel中显示数字 及这些数字的颜色
    if ( num != 0 ) {
        // 设置numLabel显示非0数字
        self.numLabel.text = [NSString stringWithFormat:@"%d", num];
        
        // 设置这些非0数字的颜色 --- 4以上的数字颜色偏亮(白色), 2/4的数字颜色偏暗(灰色)
        self.numLabel.textColor = num > 4 ? [UIColor colorWithRed:247/255.0 green:243/255.0 blue:243/255.0 alpha:1] : [UIColor colorWithRed:101/255.0 green:81/255.0 blue:81/255.0 alpha:1];
    
    } else {
        // 设置num为0时,numLabel显示为空
        self.numLabel.text = @"";
    }
    
    // 3. 设置cell的背景色
    _redColor = [self.color[[NSString stringWithFormat:@"back-%d", num]][0] floatValue];
    _greenColor = [self.color[[NSString stringWithFormat:@"back-%d", num]][1] floatValue];
    _blueColor = [self.color[[NSString stringWithFormat:@"back-%d", num]][2] floatValue];
    
    // 4. 重绘Cell,跟新背景色
    [self setNeedsDisplay];
}


/*
 cell的初始化
 
 1. Cell的num值都初始为0
 2. Cell的numLabel中初始均显示为空
 3. 设置Cell的初始背景色
 */
- (void)awakeFromNib {
    // 1. 初始化所有cell的值为0
    _num = 0;
    
    // 2. 初始numLabel不显示任何内容
    self.numLabel.text = @"";
    
    // 3. 设置Cell的初始背景色
    _redColor = [self.color[@"back-0"][0] floatValue];
    _greenColor = [self.color[@"back-0"][1] floatValue];
    _blueColor = [self.color[@"back-0"][2] floatValue];
}


/*
 cell的绘制
 
 1. 设置Cell的宽高
 2. 绘制cell 及 设置圆角
 3. 填充色彩
 */
- (void)drawRect:(CGRect)rect {
    // 获取上下文
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    
    // 1. 设置Cell的宽高
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    
    // 2. 绘制Cell
    
    // 设置Cell的圆角半径为长宽的1/10
    CGFloat radius = w * 0.1;

    // 移动到初始点
    CGContextMoveToPoint(cxt, radius, 0);
    
    // 画第一条上面的直线与右上的圆角
    CGContextAddLineToPoint(cxt, w - radius, 0);
    CGContextAddArc(cxt, w - radius, radius, radius, -M_PI_2, 0, 0);
    
    // 绘制右边线和右下圆角
    CGContextAddLineToPoint(cxt, w, h - radius);
    CGContextAddArc(cxt, w - radius, h - radius, radius, 0, M_PI_2, 0);
    
    // 绘制下边线和左下圆角
    CGContextAddLineToPoint(cxt, radius, h);
    CGContextAddArc(cxt, radius, h - radius, radius, M_PI_2, M_PI, 0);
    
    // 绘制左边线和左上圆角
    CGContextAddLineToPoint(cxt, 0, h - radius);
    CGContextAddArc(cxt, radius, radius, radius, M_PI, M_PI * 1.5, 0);
    
    // 闭合路径
    CGContextClosePath(cxt);
    
    // 3. 填充背景色
    CGContextSetRGBFillColor(cxt, _redColor, _greenColor, _blueColor, 1);
    CGContextDrawPath(cxt, kCGPathFill);
}



@end

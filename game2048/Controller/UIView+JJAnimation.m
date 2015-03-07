//
//  UIView+JJAnimation.m
//  game2048
//
//  Created by Jason on 15/1/26.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "UIView+JJAnimation.h"
#import "JJCellView.h"

@implementation UIView (JJAnimation)

/**
 *  为cell添加旋转动画
 */
- (void)addRotaionAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.toValue = @(M_PI * 2);
    animation.duration = .5;
    animation.removedOnCompletion = YES;
    [self.layer addAnimation:animation forKey:nil];
}


/**
 *  为cell添加心跳动画
 */
- (void)addHeartBeatAnimation {
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    animation.toValue = @.8;
//    animation.repeatCount = 1; // 默认只播放一遍
//    [self.layer addAnimation:animation forKey:nil];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    anim.values = [NSArray arrayWithObjects:@.8, @1.2, nil];
    anim.duration = .25;
    anim.removedOnCompletion = YES;
    [self.layer addAnimation:anim forKey:nil];
    
//    // 创建不断改变CALayer的transform属性的属性动画
//    CAKeyframeAnimation* anim = [CAKeyframeAnimation
//                                 animationWithKeyPath:@"transform"];
//    // 设置CAKeyframeAnimation控制transform属性依次经过的属性值
//    anim.values = [NSArray arrayWithObjects:
//                   [NSValue valueWithCATransform3D:self.layer.transform],
//                   [NSValue valueWithCATransform3D:CATransform3DScale
//                    (self.layer.transform , 0.8, 0.8, 1)],
//                   [NSValue valueWithCATransform3D:CATransform3DScale
//                    (self.layer.transform, 1.2, 1.2 , 1)],
//                   [NSValue valueWithCATransform3D:self.layer.transform], nil];

}

/**
 *  添加移动阴影动画
 *
 *  @param toCell 要移动到的Cell
 */
- (void)addMoveShadowAnimationWithToCell:(JJCellView *)toCell {
    [toCell.superview bringSubviewToFront:toCell]; // 将cell移到最高层级做动画，防止被挡
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:self.center];
    animation.toValue = [NSValue valueWithCGPoint:toCell.center];
    animation.duration = 0.25;
    animation.removedOnCompletion = YES;
    [toCell.layer addAnimation:animation forKey:nil];
}

/**
 *  添加随机变化2、4的动画
 *  动画必须要快，若慢的话，此处的cell已经移开，而cell的颜色和numLabel都还在赋值
 */
- (void)addRandNumAnimation {
    JJCellView *cell = (JJCellView *)self;
    int changeCount = cell.num == 2 ? arc4random_uniform(2) * 2 + 3 : arc4random_uniform(2) * 2 + 4;
    
    [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(changeNum:) userInfo:@(changeCount) repeats:YES];
}

- (void)changeNum:(NSTimer *)timer {
    
    JJCellView *cell = (JJCellView *)self;
    NSArray *numArr = [NSArray arrayWithObjects:@"2", @"4", nil];
    if ( cell.initNum < [timer.userInfo intValue] ) {
        // 文字变换
        cell.numLabel.text = numArr[cell.initNum % 2];
        // 颜色变换
        NSArray *colorArr = [cell.color valueForKey:[NSString stringWithFormat:@"back-%@", numArr[cell.initNum % 2]]];
        cell.redColor = [colorArr[0] floatValue];
        cell.greenColor = [colorArr[1] floatValue];
        cell.blueColor = [colorArr[2] floatValue];
        
        [cell setNeedsDisplay];
        
        cell.initNum ++;
    } else {
        cell.initNum = 0;
        // 还原cell的真实状态
        cell.num = cell.num;
        
        [timer invalidate];
    }
}


/*************************
 
 动画测试
 
 *************************************/


- (void)addTestAnimation {
    
    JJCellView *cell = (JJCellView *)self;
    int changeCount = cell.num == 2 ? arc4random_uniform(5) * 2 + 3 : arc4random_uniform(5) * 2 + 4;
    
    // 这个动画存在BUG
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(changeNum:) userInfo:@(changeCount) repeats:YES];
    
    
}



// 测试1
- (void)test1 {
    self.layer.cornerRadius = 6.0;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 2.0;
    
}

- (void)test2 {
    CALayer *subLayer = [CALayer layer]; // 创建一个CALayer对象
    subLayer.backgroundColor = [UIColor yellowColor].CGColor;
    subLayer.cornerRadius = 6.0;
    subLayer.borderWidth = 2.0;
    subLayer.borderColor = [UIColor blackColor].CGColor;
    // 设置subLayer的阴影偏移(右下)
    subLayer.shadowOffset = CGSizeMake(5, 4);
    // 设置subLayer的阴影模糊程度(值越大越模糊)
    subLayer.shadowRadius = 1;
    subLayer.shadowColor = [UIColor redColor].CGColor;
    subLayer.shadowOpacity = 0.8; // 阴影的不透明度
    subLayer.frame = CGRectMake(10, 10, 40, 40);
    [self.layer addSublayer:subLayer];
    
}

- (void)test3 {
    CALayer *subLayer = [CALayer layer];
//    subLayer.backgroundColor = [UIColor yellowColor].CGColor;
    subLayer.cornerRadius = 6.0;
    subLayer.borderWidth = 2.0;
    subLayer.borderColor = [UIColor blackColor].CGColor;
    subLayer.shadowOffset = CGSizeMake(4, 4);
    subLayer.shadowRadius = 1;
    subLayer.shadowOpacity = 0.8;
    subLayer.shadowColor = [UIColor redColor].CGColor;
    subLayer.masksToBounds = YES; // 遮罩的作用是什么???
    subLayer.frame = CGRectMake(10, 10, 40, 40);
    [self.layer addSublayer:subLayer];

}

- (void)test4 {
    CALayer *subLayer = [CALayer layer];
    //    subLayer.backgroundColor = [UIColor yellowColor].CGColor;
    subLayer.cornerRadius = 6.0;
    subLayer.borderWidth = 2.0;
    subLayer.borderColor = [UIColor blackColor].CGColor;
    subLayer.shadowOffset = CGSizeMake(4, 4);
    subLayer.shadowRadius = 2.0;
    subLayer.shadowOpacity = 0.5;
    subLayer.shadowColor = [UIColor redColor].CGColor;
    subLayer.masksToBounds = YES; // 遮罩的作用是什么???
    subLayer.frame = CGRectMake(10, 10, 40, 40);
    [self.layer addSublayer:subLayer];
    
// 使用CALayer显示图片
    CALayer *imageLayer = [CALayer layer];
    imageLayer.contents = (id)[[UIImage imageNamed:@"123"] CGImage];
    imageLayer.frame = subLayer.bounds;
    [subLayer addSublayer:imageLayer];
    
}




/*
 核心动画知识整理
    CoreAnimation 动画使用CALayer来创建用户界面，每个UIView上可以放置几百个CALayer，各种大小不同的CALayer层叠、
 组合在一起，各CALayer可以自由地控制它们的位置、大小和形状，这样就可以创建出复杂的用户界面。
    使用CoreAnimation创建动画更加简单，性能更好:
 1. CoreAnimation动画在单独的线程中完成，不会阻塞主线程。
 2. CoreAnimation动画只会重绘界面上变化的部分(局部刷新)。
 
    CoreAnimation动画的核心是CALayer，每个UIView都有自己的CALayer，而且每个CALayer都可以不断地添加子CALayer，
 CALayer所在的CALayer被称为父CALayer，CALayer的这种组织方式被称为Layer Tree。
 
 1. CAAnimation: 它是所有动画类的基类，它实现了CAMediaTiming协议，提供了动画的持续时间、速度和重复计数等。
 CAAnimation还实现了CAAction协议，该协议为CALayer动画触发的动作提供标准化响应。
 2. CATransition: CAAnimation的子类，CAAnimation可通过预置的过渡效果来控制CALayer层的过渡动画。
 3. CAPropertyAnimation: 它是CAAnimation的子类，它代表一个属性动画。
 可通过 +animationWithKeyPath:类方法来创建属性动画，该方法需要指定一个CALayer支持动画的属性，然后通过它的子类(
    CABasicAnimation、CAKeyframeAnimation)控制CALayer的动画属性慢慢地改变，即可实现CALayer动画。
 4. CABasicAnimation: CAPropertyAnimation的子类，简单控制CALayer层的属性慢慢改变，从而实现动画效果。
 很多CALayer层的属性值的修改默认会执行这个动画类。比如大小、透明度、颜色等属性。
 5. CAKeyframeAnimation: CAPropertyAnimation的子类，支持关键帧的属性动画，该动画的最大特点在于可通过values属性
 指定多个关键帧，通过多个关键帧可以指定动画的各阶段的关键值。
 6. CAAnimationGroup: 它是CAAnimation的子类，用于将多个动画组合在一起执行。
 
 CALayer的使用
 1. 创建一个CALayer。
 2. 设置CALayer的contents属性即可设置该CALayer所显示的内容，该属性通常可指定一个CGImage，即代表该CALayer将要显示的图片。
 如果要自行绘制该CALayer所显示的内容，可为CALayer指定delegate属性，该属性值应该是一个实现CALayerDelegate非正式协议的对象，
 重写该协议中的drawLayer:inContext:方法，即可完成CALayer的绘制。
 3. 为CALayer设置backgroundColor(背景色)、frame(设置大小和位置)、position(位置)、anchorPoint(锚点)、
 borderXXX(设置边框的相关属性)、shadowXXX(设置阴影相关属性)等属性。
 4. 将该CALayer添加父CALayer中即可。
 
 与CALayer显示相关的几个常用属性
 1. contents: 该属性控制CALayer显示的内容。
 2. contentsRect: 该属性控制CALayer的显示区域，其属性值是一个形如(0.0, 0.0, 1.0, 1.0)的CGRect结构体，
 其中，1.0代表CALayer完整的宽和高。
 3. contentsCenter: 该属性控制CALayer的显示中心，其属性值是一个形如(0.0, 0.0, 1.0, 1.0)的CGRect结构体，
 其中，1.0代表CALayer完整的宽和高。通过该属性可以把CALayer分成#字形的网格，该属性指定的区域位置位于#字形中心。
 若是指定了contentsCenter的contentsGravity属性为缩放模式，那么该CALayer被分成#字形的网格上、下区域只进行水平缩放，
 #字形的网格上的左、右区域只进行垂直缩放，中间区域进行两个方向的缩放，四个角则不进行缩放。
 4. contentsGravity: 该属性是一个NSString类型的常量值，用于控制CALayer中内容的缩放、对齐方式，它支持kCAGravityCenter等
 表示中心、上、下、左、右等对齐方式的属性值，也支持kCAGravityResizeXXX表示缩放的属性值。  // gravity 重力、引力
 
 */

@end













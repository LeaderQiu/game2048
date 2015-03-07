//
//  UIView+JJAnimation.h
//  game2048
//
//  Created by Jason on 15/1/26.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JJCellView;

@interface UIView (JJAnimation)

/*
 旋转动画
 
 */
- (void)addRotaionAnimation;

/* 
 心跳动画
 
 */
- (void)addHeartBeatAnimation;

/**
 *  移动痕迹动画
 *
 *  @param toCell
 */
- (void)addMoveShadowAnimationWithToCell:(JJCellView *)toCell;

/**
 *  添加随机变化2、4的动画
 *  动画必须要快，若慢的话，此处的cell已经移开，而cell的颜色和numLabel都还在赋值
 */
- (void)addRandNumAnimation;

- (void)addTestAnimation;
@end

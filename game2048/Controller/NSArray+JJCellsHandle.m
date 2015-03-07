//
//  NSArray+JJCellsHandle.m
//  game2048
//
//  Created by Jason on 15/1/26.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "NSArray+JJCellsHandle.h"
#import "JJCellView.h"
#import "UIView+JJAnimation.h"

@implementation NSArray (JJCellsHandle)

/**
 *  通过位置来获取Cell的num值
 *
 *  @param point JJPoint类型 cell的位置
 *
 *  @return 返回Cell的num值
 */
- (int)cellNumWithPoint:(JJPoint)point {
    return [JJCellWithPoint(point) num];
}

/**
 *  设置cell的num值
 *
 *  @param num   num值
 *  @param point cell的位置
 */
- (void)setCellNum:(int)num WithPoint:(JJPoint)point {
    [JJCellWithPoint(point) setNum:num];
}

#define JJNotificationCenter [NSNotificationCenter defaultCenter]
#define JJScoreNotification @"scoreNotification"
/**
 *  移动cell到另一个位置
 *
 *  1. 移动cell的位置(假象。本质是更改两个位置cell的num值)
 *  2. 判断是否应该加分(YES 给成绩加分)
 *  3. 给移动cell添加动画
 *  @param fromPoint    要移动的cell位置
 *  @param toPoint      要移动的cell将要到达的位置
 */
- (void)moveCellFromPoint:(JJPoint)fromPoint toPoint:(JJPoint)toPoint {
    // 要移动到的位置的cell的num值为0，此时没有得分
    if ( [self cellNumWithPoint:toPoint] == 0 ) {
        // 设置要移动到的位置num值为0的情况
        [self setCellNum:[self cellNumWithPoint:fromPoint] WithPoint:toPoint];
        
    } else {
        [self setCellNum:2 * [self cellNumWithPoint:fromPoint] WithPoint:toPoint];
        // 动画效果
//        [[self cellWithPoint:toPoint] addHeartBeatAnimation];
        [JJCellWithPoint(fromPoint) addMoveShadowAnimationWithToCell:JJCellWithPoint(toPoint)];
        
        // 更新总成绩 使用通知
        [JJNotificationCenter postNotificationName:JJScoreNotification object:@([self cellNumWithPoint:toPoint])];
        
    }
    // 更新原位置cell
    [self setCellNum:0 WithPoint:fromPoint];
    
}


/**
 *  判断某一方向上的行或者列上的任意两个cell是否可以移动
 *
 *  @param fromPoint      想要做移动动作的cell的位置
 *  @param toPoint        想要移动cell到达的位置
 *  @param swipeDirection 手势滑动的方向
 *
 *  @return     是否可以移动cell到另一个位置 YES 可以移动, NO 不能够移动
 */
- (BOOL)canMoveCellFromPoint:(JJPoint)fromPoint toPoint:(JJPoint)toPoint direction:(int)swipeDirection {
    // first. 要移动的cell必须是能够显示出效果的cell(num值不为0)
    if ( [self cellNumWithPoint:JJPointMake(fromPoint.x, fromPoint.y)] != 0 ) {
        // second. cell移动的起始位置到要停在的位置之间没有阻塞
        if ( [self hasNoBlockBetweenFromPoint:fromPoint andToPoint:toPoint direction:swipeDirection] ) {
            
            // third. 可以移动cell的两种情况:
            // 1. 移动到空白处
            // 2. 移动到同一num值得Cell上(表现的效果,并非真的移动Cell)
            if ( [self cellNumWithPoint:JJPointMake(toPoint.x, toPoint.y)] == 0 ||
                [self cellNumWithPoint:JJPointMake(toPoint.x, toPoint.y)] == [self cellNumWithPoint:JJPointMake(fromPoint.x, fromPoint.y)] ) {
                
                return YES;
            }
        }
    }
    
    return NO;
}


/**
 *  判断在某个方向上 同一行 或者 同一列 的两个Cell之间是否有阻塞  point.x 代表第x行， point.y 代表第y列
 *
 *  @param fromPoint        想要做移动动作的cell的位置
 *  @param toPoint          想要移动Cell到达的某个位置
 *  @param swipeDirection   手势滑动的方向
 *  @return     这两个位置间是否没有阻塞 YES 没有阻塞, NO 有阻塞
 */
- (BOOL)hasNoBlockBetweenFromPoint:(JJPoint)fromPoint andToPoint:(JJPoint)toPoint direction:(int)swipeDirection {
    
    // 水平方向上的滑动 --- 左、右
    if ( swipeDirection & ( UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight ) ) {
        
        // 先确保fromPoint.y 不能大于 toPoint.y
        if ( toPoint.y < fromPoint.y ) {
            // 交换两者的值
            JJPoint tmpPoint = toPoint;
            toPoint = fromPoint;
            fromPoint = tmpPoint;
        }
        
        // 遍历两个Cell之间的所有Cell值是否为0, 若有不为0则两点之间有阻塞
        for ( int col = fromPoint.y + 1; col < toPoint.y; col ++ ) {
//            JJCellView *cell = self[fromPoint.x][col];
            if ( [self cellNumWithPoint:JJPointMake(fromPoint.x, col)] != 0 ) return NO;
        }
        
    } else { // 垂直方向上的滑动 ---- 上、下
        
        // 确保fromPoint.x 不能大于 toPoint.x
        if ( toPoint.x < fromPoint.x ) {
            JJPoint tmpPoint = toPoint;
            toPoint = fromPoint;
            fromPoint = tmpPoint;
        }
        
        for ( int row = fromPoint.x + 1; row < toPoint.x; row ++ ) {
//            JJCellView *cell = self[row][fromPoint.y];
            if ( [self cellNumWithPoint:JJPointMake(row, fromPoint.y)] != 0 ) return NO;
        }
    }
    
    return YES;
}


@end

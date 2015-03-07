//
//  NSArray+JJCellsHandle.h
//  game2048
//
//  Created by Jason on 15/1/26.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJPoint.h"

@class JJCellView;

#define JJCellWithPoint(point) self[point.x][point.y]

@interface NSArray (JJCellsHandle)

/**
 *  通过位置获取cell的num值
 *
 *  @param point cell的位置
 *
 *  @return cell的num值
 */
- (int)cellNumWithPoint:(JJPoint)point;

/**
 *  设置cell的num值
 *
 *  @param num   num值
 *  @param point cell的位置
 */
- (void)setCellNum:(int)num WithPoint:(JJPoint)point;

/**
 *  移动cell到另一个位置
 *
 *  1. 移动cell的位置(假象。本质是更改两个位置cell的num值)
 *  2. 判断是否应该加分(YES 给成绩加分)
 *  3. 给移动cell添加动画
 *  @param fromPoint    要移动的cell位置
 *  @param toPoint      要移动的cell将要到达的位置
 */
- (void)moveCellFromPoint:(JJPoint)fromPoint toPoint:(JJPoint)toPoint;


/**
 *  判断某一方向上的行或者列上的任意两个cell是否可以移动
 *
 *  @param fromPoint      想要做移动动作的cell的位置
 *  @param toPoint        想要移动cell到达的位置
 *  @param swipeDirection 手势滑动的方向
 *
 *  @return     是否可以移动cell到另一个位置 YES 可以移动, NO 不能够移动
 */
- (BOOL)canMoveCellFromPoint:(JJPoint)fromPoint toPoint:(JJPoint)toPoint direction:(int)swipeDirection;


@end



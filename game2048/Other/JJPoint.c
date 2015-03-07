//
//  JJPoint.c
//  game2048
//
//  Created by Jason on 15/1/30.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#include "JJPoint.h"

/**
 * 创建一个JJPoint
 *
 * @param int x cell的X轴位置
 * @param int y cell的Y轴位置
 */
JJPoint JJPointMake(int x, int y) {
    JJPoint p; p.x = x; p.y = y; return p;
}

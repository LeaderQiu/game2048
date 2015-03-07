//
//  JJPoint.h
//  game2048
//
//  Created by Jason on 15/1/30.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#ifndef __game2048__JJPoint__
#define __game2048__JJPoint__

#include <stdio.h>

/*
 自定义JJPoint
 
 */
struct JJPoint{
    int x;
    int y;
};

typedef struct JJPoint JJPoint;

JJPoint JJPointMake(int x, int y);

#endif /* defined(__game2048__JJPoint__) */

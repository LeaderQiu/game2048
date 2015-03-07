//
//  JJGameController.m
//  二手设备
//
//  Created by Jason on 15/1/23.
//  Copyright (c) 2015年 jason. All rights reserved.
//

#import "JJGameController.h"
#import "JJCellView.h"
#import "UIView+JJAnimation.h"
#import "NSArray+JJCellsHandle.h"
#import "JJMessageViewController.h"


// cell的行数
#define JJCellRows 4
// cell的列数
#define JJCellCols 4

@interface JJGameController ()


// 游戏界面的背景
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
// 得分栏
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
// 回退按钮
@property (weak, nonatomic) IBOutlet UIButton *backButton;
// 历史最高得分栏
@property (weak, nonatomic) IBOutlet UILabel *historyHighestScoreLabel;
// 得分等级栏
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

// 移动的格子
@property (nonatomic, strong) NSArray *cells;
// 一个二维数组，包装的格子
@property (nonatomic, strong) NSArray *cells2D;
// 表示游戏结束
@property (nonatomic, assign, getter=isGameOver) BOOL gameOver;
// 每次随机出来的cell
@property (nonatomic, strong) NSArray *randCells;
// 得分
@property (nonatomic, assign) int score;
// 历史最高得分
@property (nonatomic, assign) int historyHighestScore;
// 所有cell的上一次状态，用于退回上一步使用
@property (nonatomic, strong) NSArray *cellsNumBack;
// 上一次的得分,回退时扣除的分数参照
@property (nonatomic, assign) int backScore;
// 游戏的一些提示
@property (nonatomic, strong) NSMutableDictionary *tips;

@property (nonatomic, weak) JJMessageViewController *messageVC;

// 游戏设置:
// 初始化时，随机的cell数量
@property (nonatomic, assign) int initCellCount;

@end

@implementation JJGameController
// 用于在程序终止时存档得分
int globalScore;
#define JJGlobalScore @"globalScore"

// 程序终止时存档cells状态
NSArray *globalCellsNumBack;
#define JJGlobalCellsNumBack @"globalCellsNumBack"

#define JJHasNotTippedHistoryHighestScoreBreaked @"hasNotTippedHistoryHighestScoreBreaked"

#define JJNotificationCenter [NSNotificationCenter defaultCenter]
#define JJScoreNotification @"scoreNotification"
/*
 视图创建完成
 
 */
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 游戏初始化设置
    [self gameInitSetting];
    
    // 将cell加入背景中
    [self addCells];
    
    // 初始化得分和cell(从存档读取状态 或 创建)
    [self initScoreAndCells];
    
    // 获取历史最高得分
    _historyHighestScoreLabel.text = [NSString stringWithFormat:@"%d", [self getGameHighestScore]];
    
    // 设置back按钮初始为不可点击
    self.backButton.enabled = NO;
    
    // 监听滑动手势
    [self addSwipe];
    
    // 接收更新成绩的通知  UIKeyboardDidShowNotification
    [JJNotificationCenter addObserver:self selector:@selector(scoreWithNotification:) name:JJScoreNotification object:nil];
}

/**
 懒加载cells
 
 1. 初始化所有cells
 2. 创建一个所有cell转成的二维数组cells2D
 */
- (NSArray *)cells {
    if ( _cells == nil ) {
        NSMutableArray *cellsTemp = [NSMutableArray array];
        CGFloat cellW = 60.0, cellH = 60.0, marginX = 12.0, marginY = 12.0;
        int cellsCount = JJCellRows * JJCellCols;
        
        for ( int i = 0; i < cellsCount; i++ ) {
            JJCellView *cell = [[[NSBundle mainBundle] loadNibNamed:@"JJCellView" owner:nil options:nil] lastObject];
            CGRect rect = CGRectMake(marginX + (marginX + cellW) * (i % JJCellCols), marginY + (marginY + cellH) * (i / JJCellCols), cellW, cellH);
            cell.frame = rect;
            [cellsTemp addObject:cell];
        }
        _cells = [cellsTemp copy];
        
        // 初始化二维数组
        _cells2D = [NSArray array];
        NSMutableArray *cells2DTemp = [NSMutableArray array];
        NSMutableArray *cellsTemp2 = [NSMutableArray array];
        [_cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [cellsTemp2 addObject:obj];
            if ( idx % JJCellCols == 3 ) {
                [cells2DTemp addObject:[cellsTemp2 copy]];
                [cellsTemp2 removeAllObjects];
            }
        }];
        _cells2D = [cells2DTemp copy];
    }
    return _cells;
}

/**
 懒加载 messageVC
 
 1. 创建 JJMessageViewController, 使用临时变量强引用
 2. 使用弱指针 _messageVC引用JJMessageViewController
 3. 将 JJMessageViewController注册为GameController的子控制器
 */
- (JJMessageViewController *)messageVC {
    if ( _messageVC == nil ) {
        JJMessageViewController *messageVC = [[JJMessageViewController alloc] init];
        _messageVC = messageVC;
        // 注册为GameController的子控制器
        [self addChildViewController:messageVC];
    }
    return _messageVC;
}


/*
 游戏提示初始化
 
 1. 本次游戏是否没有打破历史记录
 */
- (NSMutableDictionary *)tips {
    if ( _tips == nil ) {
        _tips = [NSMutableDictionary dictionary];
        [_tips setValue:@1 forKey:JJHasNotTippedHistoryHighestScoreBreaked]; // 没有提示过历史最高记录被打破
    }
    return _tips;
}


/*
 设置得分
 
 1. 更新得分分值
 2. 更新得分显示
 3. 打破历史最高记录提示
 */
- (void)setScore:(int)score {
    // 1. 更新得分分值
    _score = score;
    
    // 2. 显示最新分数
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    
    // 3. 打破历史最高记录提示
    if ( _historyHighestScore < score && [[self.tips valueForKey:JJHasNotTippedHistoryHighestScoreBreaked] intValue] )
    {
        // 记录已经提示过打破历史记录，后面就不再提示
        [self.tips setValue:@0 forKey:JJHasNotTippedHistoryHighestScoreBreaked];
        
        [self.messageVC showMessageInBottom:@"恭喜您打破了历史最高得分记录" withDuration:5];
    }
    
    // 4. 将得分保存至全局，测试游戏恢复
    globalScore = score;
}

#pragma mark - 外部使用通知更新游戏得分
- (void)scoreWithNotification:(NSNotification *)note {
    self.score += [note.object intValue];
}

/**
 游戏结束设置
 
 1. 设置游戏状态
 2. Game Over提示
 3. 保存游戏最高记录
*/
- (void)setGameOver:(BOOL)gameOver {
    // 1. 游戏状态
    _gameOver = gameOver;
    
    if ( gameOver ) {
        // 2. 游戏结束提示
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"游戏结束" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil] show];
        
        // 3. 存档游戏最高记录(需判断)
        [self archiveGameHighestScore];
    }
}


#define JJUserDefaults [NSUserDefaults standardUserDefaults]
#define JJHistoryHighestScore @"historyHighestScore"

/**
 存档游戏最高记录
 
 1. 取历史最高分
 2. 当前分数是否超过历史最高分 保存最高分
 */
- (void)archiveGameHighestScore {
    // 1. 取出最高分
    int historyHighestScore = [self getGameHighestScore];
    
//    [JJUserDefaults setInteger:_score forKey:JJHistoryHighestScore];
    
    // 2. 判断当前分数是否超过历史最高分 保存最高分
    if ( historyHighestScore < _score ) {
        // 存档最高分
        [JJUserDefaults setInteger:_score forKey:JJHistoryHighestScore];
    }
}

#pragma mark - 读取游戏的历史最高分
- (int)getGameHighestScore {
    _historyHighestScore = (int)[JJUserDefaults integerForKey:JJHistoryHighestScore];
    return _historyHighestScore;
}

/**
 懒加载randCells
 */
- (NSArray *)randCells {
    if ( _randCells == nil ) {
        _randCells = [NSArray array];
    }
    return _randCells;
}

#pragma mark - 游戏初始化设置
- (void)gameInitSetting {
    // 设置背景圆角
    _backgroundView.layer.cornerRadius = 6.0;
    _backgroundView.backgroundColor = [UIColor colorWithRed:118/255.0 green:77/255.0 blue:57/255.0 alpha:1];
    
    // 设置初始时随机Cell的个数
    _initCellCount = 3;
}


/**
 开始新的游戏
 
 1. 存档历史最高分
 2. 初始化Cell设置初始num值为0
 3. 初始化一些Cell的num值为 2或4
 4. 初始化游戏得分和历史最高记录
 5. 初始所有游戏提示为未有过提示状态
 */
#pragma mark - 开始新的游戏
- (IBAction)newGame {
    // 1. 存档历史最高分
    [self archiveGameHighestScore];
    
    // 2. 初始化cells设置初始num=0
    [self.cells enumerateObjectsUsingBlock:^(JJCellView *obj, NSUInteger idx, BOOL *stop) {
        obj.num = 0;
    }];
    
    // 3. 初始化一些Cell的num值为 2或4
    [self initCellWithCount:_initCellCount];
    
    // 4. 初始化游戏得分
    [self initScore];
    
    // 5. 初始所有游戏提示为未有过提示状态
    _tips = nil;
}


/*
 返回上一步
 
 点击后完成的功能:
 1. 扣分(有分可扣的情况下)
 2. 点击提醒 与 扣分提醒(只有在真正扣分时才提醒)
 3. 更新cells为上一次状态
 4. 回退按钮设为不可点击状态
 */
#pragma mark - 回退一步
- (IBAction)back {
    // 有保存回退状态值的情况下
    if ( _cellsNumBack != nil ) {
        if ( _backScore == 0 ) {
            // 点击按钮提醒
            [self.messageVC showMessageInBottom:@"点击了回退按钮" withDuration:3];
        } else {
            // 1. 回到上次备份的成绩
            int cutScore = _score - _backScore;
            
            self.score = _backScore;
            // 2. 点击按钮提醒 与 扣分提醒
            
            [self.messageVC showMessageInBottom:[NSString stringWithFormat:@"点击了回退按钮,扣除%d分", cutScore] withDuration:3];
        }
        
        // 3. cells回到上一次状态, _cellsNumBack中保存的状态
        [_cellsNumBack enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
            JJCellView *cell = self.cells[idx];
            cell.num = obj.intValue;
        }];
        
        // 4. 回退之后，back按钮不能再点击
        self.backButton.enabled = NO;
    }
}

#pragma mark - 初始化游戏得分与cells状态(自动判断是否有存档)
- (void)initScoreAndCells {
    // 若是有存档则从存档中加载数据
    if ( [self initCellFromArchive] ) {
        [self initScoreFromArchive];
    } else {
        [self initScore];
        [self initCellWithCount:_initCellCount];
    }

}


/**
 初始化游戏分数
 
 1. 游戏得分初始化为0
 2. 游戏得分栏显示的内容为0
 */
- (void)initScore {
    // 1. 游戏得分初始为0
    _score = 0;
    
    // 2. 游戏得分栏初始显示为0
    self.scoreLabel.text = @"0";
}

/**
 从存档中初始化Cell状态
 
 */
- (BOOL)initCellFromArchive {
    self.cellsNumBack = [JJUserDefaults valueForKey:JJGlobalCellsNumBack];
    if ( self.cellsNumBack == nil ) return NO;
    
    [self.cells enumerateObjectsUsingBlock:^(JJCellView *cell, NSUInteger idx, BOOL *stop) {
        cell.num = [self.cellsNumBack[idx] intValue];
    }];
    return YES;
}


/**
 从存档中加载得分,可以继续上次游戏
 
 1. 游戏得分初始化为存档得分
 2. 游戏得分栏显示的内容为存档得分
 */
- (void)initScoreFromArchive {
    // 1. 游戏得分初始化为存档得分
    _score = [[JJUserDefaults valueForKey:JJGlobalScore] intValue];
    
    // 2. 游戏得分栏显示的内容为存档得分
    _scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
}

/**
 *  添加滑动手势识别器 需同时监听4个方向(上下左右)的滑动
 */
- (void)addSwipe {
//    UISwipeGestureRecognizerDirectionRight = 1 << 0,
//    UISwipeGestureRecognizerDirectionLeft  = 1 << 1,
//    UISwipeGestureRecognizerDirectionUp    = 1 << 2,
//    UISwipeGestureRecognizerDirectionDown  = 1 << 3
    
    for ( int i = 0; i < 4; i++ ) {
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        swipeGesture.direction = 1 << i;
        [self.backgroundView addGestureRecognizer:swipeGesture];
    }
}


// 监听手势处理动作
#pragma mark - 手势滑动处理(核心逻辑)
- (void)swipeAction:(UISwipeGestureRecognizer *)swipe {
    // 是否 不需要产生随机cell  当某次移动视图上的cell位置 没有变化，则不需要产生随机cell
    BOOL isNotNeedRandCell = YES;
    // 备份成绩
    _backScore = _score;
    
    // 备份cell的num,用于返回上一步
    [self backUpCellsNum];
 

#define JJSwipeHorizontal(swipe) ((swipe.direction) == UISwipeGestureRecognizerDirectionLeft || (swipe.direction) == UISwipeGestureRecognizerDirectionRight)
#define JJSwipeLeftOrUp(swipe) ((swipe.direction) == UISwipeGestureRecognizerDirectionLeft || (swipe.direction) == UISwipeGestureRecognizerDirectionUp)
    
    // 确定数组的第一/二维度是行数还是列数
    int arrayDimensionalOne = JJSwipeHorizontal(swipe) ? JJCellRows : JJCellCols;
    int arrayDimensionalTwo = JJSwipeHorizontal(swipe) ? JJCellCols : JJCellRows;
    
    for ( int i = 0; i < arrayDimensionalOne; i ++ ) {
        // 这一行或列中是否已存在一次碰撞得分的情况
        int hasAHitScore = 0;
    
        if ( JJSwipeLeftOrUp(swipe) ) {
            for ( int j = 1; j < arrayDimensionalTwo; j ++ ) { // 由前往后遍历 忽略第0行或列
                for ( int k = 0; k < j; k ++ ) { // 左边的列 或 上边的行
        
                    JJPoint fromPoint, toPoint;
                    if ( swipe.direction == UISwipeGestureRecognizerDirectionLeft ){
                        fromPoint = JJPointMake(i, j);
                        toPoint = JJPointMake(i, k);
                    } else { // Up
                        fromPoint = JJPointMake(j, i);
                        toPoint = JJPointMake(k, i);
                    }
                    if ( [_cells2D canMoveCellFromPoint:fromPoint toPoint:toPoint direction:swipe.direction] ) {
                        // 记录没有更改前的toPointCell的num
                        int toPointNum = [_cells2D cellNumWithPoint:toPoint];
                        
                        if ( toPointNum != 0 && hasAHitScore == 1 ) continue;
                        
                        [_cells2D moveCellFromPoint:fromPoint toPoint:toPoint];
                        
                        if ( toPointNum != 0 ) {
                            hasAHitScore = 1;
                            if ( j == 1 && k == 0 ) {
                                JJPoint fromPoint2, fromPoint3, toPoint1;
                                
                                if ( swipe.direction == UISwipeGestureRecognizerDirectionLeft ) {
                                    fromPoint2 = JJPointMake(i, 2);
                                    fromPoint3 = JJPointMake(i, 3);
                                    toPoint1 = JJPointMake(i, 1);
                                } else {
                                    fromPoint2 = JJPointMake(2, i);
                                    fromPoint3 = JJPointMake(3, i);
                                    toPoint1 = JJPointMake(1, i);
                                }
                                if ( [_cells2D cellNumWithPoint:fromPoint2] != 0 && [_cells2D cellNumWithPoint:fromPoint2] == [_cells2D cellNumWithPoint:fromPoint3] ) {
                                    [_cells2D moveCellFromPoint:fromPoint2 toPoint:toPoint1];
                                    [_cells2D moveCellFromPoint:fromPoint3 toPoint:toPoint1];
                                }
                            }
                        }
                        isNotNeedRandCell = NO;
                        break;
                        
                    
                    }
                }
            }
        } else {
            for ( int j = arrayDimensionalTwo - 2; j >= 0; j -- ) { // 由后往前遍历 忽略最后的行或列
                for ( int k = arrayDimensionalTwo - 1; k > j; k -- ) {
                    JJPoint fromPoint, toPoint;
                    if ( swipe.direction == UISwipeGestureRecognizerDirectionRight ) {
                        fromPoint = JJPointMake(i, j);
                        toPoint = JJPointMake(i, k);
                    } else { // Down
                        fromPoint = JJPointMake(j, i);
                        toPoint = JJPointMake(k, i);
                    }
                    if ( [_cells2D canMoveCellFromPoint:fromPoint toPoint:toPoint direction:swipe.direction] ) {
                        int toPointNum = [_cells2D cellNumWithPoint:toPoint];
                        if ( toPointNum != 0 && hasAHitScore == 1 ) continue;
                        
                        [_cells2D moveCellFromPoint:fromPoint toPoint:toPoint];
                        
                        if ( toPointNum != 0 ) {
                            hasAHitScore = 1;
                            if ( j == 2 && k == 3 ) {
                                JJPoint fromPoint0, fromPoint1, toPoint2;
                                
                                if ( swipe.direction == UISwipeGestureRecognizerDirectionRight ) {
                                    fromPoint0 = JJPointMake(i, 0);
                                    fromPoint1 = JJPointMake(i, 1);
                                    toPoint2 = JJPointMake(i, 2);
                                } else {
                                    fromPoint0 = JJPointMake(0, i);
                                    fromPoint1 = JJPointMake(1, i);
                                    toPoint2 = JJPointMake(2, i);
                                }
                                if ( [_cells2D cellNumWithPoint:fromPoint0] != 0 && [_cells2D cellNumWithPoint:fromPoint0] == [_cells2D cellNumWithPoint:fromPoint1] ) {
                                    [_cells2D moveCellFromPoint:fromPoint0 toPoint:toPoint2];
                                    [_cells2D moveCellFromPoint:fromPoint1 toPoint:toPoint2];
                                }
                            }
                        }
                        isNotNeedRandCell = NO;
                        break;
                    }
                }
            }
        }
    }
    
    
    // 如果有移动数字的情况 则产生随机 cell
    if ( isNotNeedRandCell == NO ) {
        // 产生随机1个cell
        [self initCellWithCount:1];
        
        // 设置回退按钮为可点击状态
        self.backButton.enabled = YES;
        
        // 设置全局
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:_cells.count];
        [self.cells enumerateObjectsUsingBlock:^(JJCellView *cell, NSUInteger idx, BOOL *stop) {
            [tempArr addObject:@(cell.num)];
        }];
        globalCellsNumBack = [tempArr copy];
    }
}


/**
 备份Cell移动的状态(用于回退)
 
 */
- (void)backUpCellsNum {
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:self.cells.count];
    [self.cells enumerateObjectsUsingBlock:^(JJCellView *cell, NSUInteger idx, BOOL *stop) {
        [tempArr addObject:@(cell.num)];
    }];
    self.cellsNumBack = [tempArr copy];
}



// 随机任意个cell
- (void)initCellWithCount:(int)cnt {
    // 不能生成这些个cell时，游戏结束
    if ( ![self canRandCellCount:cnt] ) {
        self.gameOver = YES;
        return;
    }
    
    // 为cell生成随机值
    [self settingCellNum];
    
    // 如果cell填满，且相邻两个数均不相同 则game over
    [self gameOverForCannotMove];
}

/**
 *  游戏结束(没有可以移动的cell了)
 */
- (void)gameOverForCannotMove {
    
    for ( int i = 0; i < self.cells.count; i++ ) {
        JJCellView *cell = self.cells[i];
        
        if ( cell.num == 0 ) return; // cell还没满
    }
    
    // 是否任意相邻的两个cell的num值都不等
    // 比较方式： 第0-2行的每个cell与其右边 和 下方 的cell做比较， 第3行的cell 只做右边比较  第3列的cell 只做下边比较
    for ( int idx = 0; idx < self.cells.count; idx++ ) {
        JJCellView *cell = self.cells[idx];
        if ( idx % 4 == 3 || idx >= 12 ) { // 第3列的cell || 第3行的cell
            if ( idx % 4 == 3 && idx >= 12 ) { // 最后一个cell不做比较， 来到这个cell，说明game over
                self.gameOver = TRUE;
            } else if ( idx % 4 == 3 ) { // 第3列的cell， 只与下方做比较
                if ( cell.num == [self.cells[idx + 4] num] ) return;
            } else { // 第3行的cell, 与右边cell作比较
                if ( cell.num == [self.cells[idx + 1] num] ) return;
            }
        } else { // 其他情况下比较 右方 和下方的cell
            if ( cell.num == [self.cells[idx + 4] num] || cell.num == [self.cells[idx + 1] num] ) return;
        }
    }
}

// 为随机出的cell设num值
- (void)settingCellNum {
    [self.randCells enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        [self.cells[[obj intValue]] setNum:arc4random_uniform(2)  == 0 ? 2 : 4];
        
        // 为非初始化 随机的cell添加 旋转动画
        if ( self.randCells.count == 1 )
            [self.cells[[obj intValue]] addRandNumAnimation];
//            [self.cells[[obj intValue]] addTestAnimation];
        
    }];

}


// 随机N个 可用cell的索引
- (BOOL)canRandCellCount:(int)cnt {
    NSMutableArray *cellsTemp = [NSMutableArray arrayWithCapacity:cnt];
    NSMutableArray *usableCellIndexes = [NSMutableArray array];
    // 遍历可使用的cell
    [self.cells enumerateObjectsUsingBlock:^(JJCellView *obj, NSUInteger idx, BOOL *stop) {
        if ( obj.num == 0 ) {
            [usableCellIndexes addObject:@(idx)];
        }
    }];
    // 如果可用的cell的数量少于 cnt 个，则game over
    if ( usableCellIndexes.count < cnt ) {
        return NO;
    }
    // 随机任意 cnt 个 可用的cell的索引
    for ( int i = 0; i < cnt; i++ ) {
        int cellIndex = arc4random_uniform((int)usableCellIndexes.count);
        [cellsTemp addObject:usableCellIndexes[cellIndex]];
        [usableCellIndexes removeObjectAtIndex:cellIndex];
    }

    self.randCells = [cellsTemp copy]; // 每次重新设值
    
    return YES;
}

// 将生成的cell放入背景中
- (void)addCells {
    [self.cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.backgroundView addSubview:obj];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [JJNotificationCenter removeObserver:self];
}

/*
 
 游戏的功能扩展：

 1. 历史最高记录和游戏等级
 2. 回退 扣分 OK
 3. 好友分数排名
 4. 颜色板， 自定义各自的颜色
 5. 游戏结束时的提示
 6. 游戏背景音乐
 7. 游戏截图
 
 Bug 与 不足：
 1. 主要逻辑的优化与重构
 2. 回退时应更改globalCellsNumBack
 3. newGame的游戏存储逻辑

 
 遇到的问题： 
 1. 显示消息 封装成框架时，若是使用UIWindow 则屏幕旋转时，window不会自动旋转(已解决)
 只用controller才能自动旋转,使用自控制器的方法解决
 
 2. 显示消息时，当横屏切换到竖屏时，显示动画的View 位置错乱
    解决方案：
    尝试：-(void)viewWillTransitionToSize: 在该方法中设置 _myview = nil
    结果：没有成功，导致旋转屏幕后，位置错乱的_myview一直显示
    其它设想的方案：在_myview做动画时，禁止屏幕旋转
    (已解决)
    使用removeFromSuperview
 
 3.
 
 
 学习与总结：
 1. 添加window时，即使在Controller中设置-(BOOL)prefersStatusBarHidden 为YES,还是会显示statusBar
    解决方案：在info.plist中配置 status bar is initially hidden = YES,
        view controller-based status bar appearence = NO
        然后在需要显示statusBar的controller中使用 [UIApplication sharedApplication].statusBarHidden = YES
 
 2. 只有view才会随着屏幕的旋转而旋转，window不会。
 
 3. 两下Home键，会调用 applicationDidEnterBackground:方法 和 applicationWillTerminate:
    使用全局属性保存数据，在applicationWillTerminate:方法中存档
 */


@end

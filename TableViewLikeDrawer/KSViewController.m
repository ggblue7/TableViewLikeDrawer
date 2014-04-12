//
//  KSViewController.m
//  TableViewLikeDrawer
//
//  Created by blue on 14-4-13.
//  Copyright (c) 2014年 blue. All rights reserved.
//
#import "KSViewController.h"
#import "KSSubTableViewController.h"
#import "KSCell.h"
#import "KSSubTableViewController.h"
#define kTransform 200
#define kDuration 0.5f
#define kMainScreenH [UIScreen mainScreen].bounds.size.height
#define kMainScreenW [UIScreen mainScreen].bounds.size.width

@interface KSViewController ()
{
    NSMutableArray           *_visibleCells;
    KSSubTableViewController *_subVC;
    int                       _second;
}

@end

@implementation KSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _subVC = [[KSSubTableViewController alloc] init];
    [self addChildViewController:_subVC];
    
    self.tableView.rowHeight = 104;
    self.tableView.backgroundColor = [UIColor redColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"main";
    
    KSCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[KSCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"第 %d 行",(int)indexPath.row];
    
    return cell;
}

/**
 *  关闭抽屉
 */
- (void)closeBox
{
    for (KSCell *cell in _visibleCells) {
        CGFloat distance = cell.orignY - cell.frame.origin.y;
        [self moveDistance:distance cell:cell];
    }
    // 移除子视图
    [self removeSubView];
    
    [_visibleCells removeAllObjects];
    self.tableView.scrollEnabled = YES;
}

/**
 *  添加子视图
 */
- (void)insertSubViewWithClickCellMaxY:(CGFloat)clickCellMaxY moveUpDistance:(CGFloat)moveUpDistance
{
    _subVC.view.frame = CGRectMake(0, clickCellMaxY, kMainScreenW, 0);
    _subVC.orignY = _subVC.view.frame.origin.y;
    [self.tableView addSubview:_subVC.view];
    
    [UIView animateWithDuration:kDuration animations:^{
        CGRect rect = _subVC.view.frame;
        rect.size.height = kTransform;
        rect.origin.y = clickCellMaxY + moveUpDistance;
        _subVC.view.frame = rect;
    } completion:^(BOOL finished) {
        self.tableView.allowsSelection = YES;
    }];
    
    [_subVC.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
}

/**
 *  移除子视图
 */
- (void)removeSubView
{
    [UIView animateWithDuration:kDuration animations:^{
        CGRect rect = _subVC.view.frame;
        rect.size.height = 0;
        rect.origin.y = _subVC.orignY;
        _subVC.view.frame = rect;
    } completion:^(BOOL finished) {
        self.tableView.allowsSelection = YES;
//        [_subVC.view removeFromSuperview];
    }];
}

/**
 *  打开抽屉
 */
- (void)openBoxWithClickCellMaxY:(CGFloat)clickCellMaxY
{
    // tableView焦点位置
    CGFloat offsetY = self.tableView.contentOffset.y;
    // 下方空余高度
    CGFloat bottomSpace = kMainScreenH - (clickCellMaxY - offsetY);
    
    // 向上移动距离
    CGFloat moveUpDistance = 0;
    // 向下移动距离
    CGFloat moveDowmDistance = kTransform;
    
    for (KSCell *cell in _visibleCells) {
        
        // 当前可见的cell的y
        CGFloat cellY = cell.frame.origin.y;
        cell.orignY = cellY;
        
        if (bottomSpace < kTransform) {
            moveDowmDistance = bottomSpace;
            moveUpDistance = -(kTransform - moveDowmDistance);
            
            // 选中cell上方cell移动
            if (cellY < clickCellMaxY) {
                [self moveDistance:moveUpDistance cell:cell];
            }
        }
        
        // 选中cell下方cell移动
        if (cellY >= clickCellMaxY) {
            [self moveDistance:moveDowmDistance cell:cell];
        }
        
        [self insertSubViewWithClickCellMaxY:clickCellMaxY moveUpDistance:moveUpDistance];
    }
}

/**
 *  开关抽屉动画
 *
 *  @param distance cell移动距离
 *  @param cell     需要移动的cell
 */
- (void)moveDistance:(CGFloat)distance cell:(UITableViewCell *)cell
{
    [UIView animateWithDuration:kDuration animations:^{
        CGRect rect = cell.frame;
        rect.origin.y += distance;
        cell.frame = rect;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.allowsSelection = NO;
    tableView.scrollEnabled = NO;
    
    if (_visibleCells.count != 0) {
        // 子视图不移动时才能关闭抽屉
        if (!_subVC.tableView.isDecelerating) {
            // 关闭抽屉
            [self closeBox];
        }else{
            tableView.allowsSelection = YES;
        }
        return;
    }
    
    
    NSArray *visible = [tableView visibleCells];
    _visibleCells = [NSMutableArray arrayWithArray:visible];
    
    KSCell *clickCell = (KSCell *)[tableView cellForRowAtIndexPath:indexPath];
    CGFloat clickCellMaxY = CGRectGetMaxY(clickCell.frame);
    
    // 打开抽屉
    [self openBoxWithClickCellMaxY:clickCellMaxY];
    
}

@end

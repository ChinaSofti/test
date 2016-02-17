//
//  SVTestingCtrl.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

/**
 **cell设置界面
 **/
#import <UIKit/UIKit.h>

#define kCellH (kScreenW - 20) * 0.22
#define kMargin 10
#define kCornerRadius 5

#import "SVToolModels.h"

@class SVToolCells;

@protocol SVToolCellsDelegate <NSObject>
/**
 *  cell点击事件
 */
- (void)toolCellClick:(SVToolCells *)cell;
@end

@interface SVToolCells : UITableViewCell

@property (nonatomic, retain) UIButton *bgdBtn;
@property (nonatomic, assign) id<SVToolCellsDelegate> delegate;

- (void)cellViewModel2:(SVToolModels *)model section:(NSInteger)section;

@end

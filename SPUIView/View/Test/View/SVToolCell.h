//
//  SVToolCell.h
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

/**
 *  cell设置界面
 */

#import "SVToolModel.h"
#import <UIKit/UIKit.h>

@class SVToolCell;

@protocol SVToolCellDelegate <NSObject>
- (void)toolCellClick:(SVToolCell *)cell;
@end

@interface SVToolCell : UITableViewCell

@property (nonatomic, retain) UIButton *bgdBtn;
@property (nonatomic, assign) id<SVToolCellDelegate> delegate;

- (void)cellViewModel:(SVToolModel *)model section:(NSInteger)section;

@end

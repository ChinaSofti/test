//
//  SVToolCells.h
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

@property (nonatomic, assign) id<SVToolCellsDelegate> delegate;

// 初始化title的cell
- (instancetype)initTitleCellWithStyle:(UITableViewCellStyle)style
                       reuseIdentifier:(NSString *)reuseIdentifier
                                 title:(NSString *)title
                             imageName:(NSString *)imageName;

// 初始化testUrl的cell
- (instancetype)initUrlCellWithStyle:(UITableViewCellStyle)style
                     reuseIdentifier:(NSString *)reuseIdentifier
                             testUrl:(NSString *)testUrl;

- (void)cellViewModelByToolModel:(SVToolModels *)model Section:(NSInteger)section;

@end

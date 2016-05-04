//
//  SVResultCell.h
//  SPUIView
//
//  Created by 许彦彬 on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVSummaryResultModel;

@class SVResultCell;

@protocol SVResultCellDelegate <NSObject>
- (void)toolCellClick:(SVResultCell *)cell;
@end

@interface SVResultCell : UITableViewCell

@property (nonatomic, assign) id<SVResultCellDelegate> delegate;

@property (nonatomic, retain) UIButton *bgdBtn;

@property int selectedTag;

@property (nonatomic, copy) void (^cellBlock) ();

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setResultModel:(SVSummaryResultModel *)resultModel;

- (SVSummaryResultModel *)getResultModel;

/**
 *  转换被选中列的字体颜色
 *
 *  @param columnIndex 被选中列索引
 */
- (void)chanageSelectedColumnColor:(NSInteger)columnIndex;

@end

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

@property (nonatomic, strong) SVSummaryResultModel *resultModel;

@property (nonatomic, assign) id<SVResultCellDelegate> delegate;

@property (nonatomic, retain) UIButton *bgdBtn;

@property (nonatomic, strong) NSString *columnName;

@property int selectedTag;

@property (nonatomic, copy) void (^cellBlock) ();

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier;


@end

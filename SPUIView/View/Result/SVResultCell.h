//
//  SVResultCell.h
//  SPUIView
//
//  Created by 许彦彬 on 16/1/25.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVSummaryResultModel;

@interface SVResultCell : UITableViewCell


@property (nonatomic, strong) SVSummaryResultModel *resultModel;


@property (nonatomic, retain) UIButton *bgdBtn;


@property (nonatomic, copy) void (^cellBlock) ();

@end

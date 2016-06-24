//
//  SVGuideView.h
//  SpeedPro
//
//  Created by 徐瑞 on 16/6/23.
//  Copyright © 2016年 Huawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVGuideView;

@protocol SVGuideViewDelegate <NSObject>

/**
 *  隐藏引导页
 */
- (void)hideGuideView:(SVGuideView *)guideView;
@end


@interface SVGuideView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) id<SVGuideViewDelegate> delegate;

/**
 * 根据页面个数初始化View
 */
- (id)initWithPageNumber:(int)pageNumber;

@end

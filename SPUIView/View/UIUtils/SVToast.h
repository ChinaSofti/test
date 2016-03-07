//
//  SVToast.h
//  SpeedPro
//
//  Created by Rain on 3/4/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//


@interface SVToast : NSObject
{
    NSString *text;
    UIButton *contentView;
    CGFloat duration;
}

+ (void)showWithText:(NSString *)text_
        bottomOffset:(CGFloat)bottomOffset_
            duration:(CGFloat)duration_;

+ (void)showWithText:(NSString *)text_;


@end

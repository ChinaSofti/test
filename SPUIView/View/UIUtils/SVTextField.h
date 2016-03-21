//
//  SVTextField.h
//  SpeedPro
//
//  Created by Rain on 3/21/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVTextField : UITextField <UITextFieldDelegate>


- (id)initWithFrame:(CGRect)frame;

/**
 *  控制UITextField字符个数
 *
 *  @param length 字符个数
 */
- (void)setCharacterLength:(int)length;

@end

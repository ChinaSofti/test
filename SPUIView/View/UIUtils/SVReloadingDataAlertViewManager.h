//
//  SVReloadingDataAlertViewManager.h
//  SpeedPro
//
//  Created by Rain on 5/5/16.
//  Copyright © 2016 Huawei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVReloadingDataAlertViewManager : NSObject

/**
 *  单例
 *
 *  @return 单例对象
 */
+ (id)sharedInstance;

- (void)showAlertView;

@end

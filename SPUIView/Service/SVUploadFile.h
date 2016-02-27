//
//  SVUploadFile.h
//  SpeedPro
//
//  Created by WBapple on 16/2/26.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

/**
 *  设置页面的上传日志方法
 */
#import <Foundation/Foundation.h>

@interface SVUploadFile : NSObject

- (void)uploadFileWithURL:(NSURL *)url data:(NSData *)data;
@end

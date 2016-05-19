//
//  SVCurrentResultViewCtrl.h
//  SPUIView
//
//  Created by Rain on 2/14/16.
//  Copyright © 2016 chinasofti. All rights reserved.
//

/**
 *  当前结果页面
 */

#import "SVCurrentResultModel.h"
#import <UIKit/UIKit.h>

@interface SVCurrentResultViewCtrl
: SVViewController <UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate>
{
    SVCurrentResultModel *_resultModel;
}

- (id)initWithResultModel:(SVCurrentResultModel *)resultModel;

@end

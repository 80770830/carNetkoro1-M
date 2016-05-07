//
//  GarageDetailReturn.h
//  CLWsdht
//
//  Created by OYJ on 16/5/6.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GarageDetailData.h"

@interface GarageDetailReturn : NSObject
@property(nonatomic,copy)NSString *Success;
@property(nonatomic,copy)NSString *Message;
@property(nonatomic,strong)GarageDetailData *Data;
@end

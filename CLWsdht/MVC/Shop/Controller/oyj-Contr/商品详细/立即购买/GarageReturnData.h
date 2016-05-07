//
//  GarageReturnData.h
//  CLWsdht
//
//  Created by OYJ on 16/5/5.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GarageData.h"

@interface GarageReturnData : NSObject
@property(nonatomic,copy)NSString *Success;
@property(nonatomic,copy)NSString *Message;
@property(nonatomic,strong)GarageData *Data;
@end

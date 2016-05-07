//
//  ServicePartsUseFor.h
//  CLWsdht
//
//  Created by OYJ on 16/5/6.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServicePartsUseFor : NSObject
@property(nonatomic,copy)NSString *UsrGarageId;
@property(nonatomic,copy)NSString *PartsUseForId;
@property(nonatomic,copy)NSString *PartsUsrForName;
@property(nonatomic,copy)NSString *SIG;
@property(nonatomic,assign)int Grade;

@end

//
//  GarageModal.h
//  CLWsdht
//
//  Created by OYJ on 16/5/5.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GarageModal : NSObject
@property(nonatomic,copy)NSString *Id;
@property(nonatomic,copy)NSString *Mobile;
@property(nonatomic,copy)NSString *Pwd;
@property(nonatomic,copy)NSString *Name;
@property(nonatomic,copy)NSString *ProvincialId;
@property(nonatomic,copy)NSString *CityId;
@property(nonatomic,copy)NSString *DistrictId;
@property(nonatomic,copy)NSString *AddDate;
@property(nonatomic,copy)NSString *IdNumber;
@property(nonatomic,copy)NSString *Lng;
@property(nonatomic,copy)NSString *Lat;
@property(nonatomic,copy)NSString *Address;
@property(nonatomic,copy)NSString *ProvincialName;
@property(nonatomic,copy)NSString *CityName;
@property(nonatomic,copy)NSString *Img;
@property(nonatomic,copy)NSString *Url;
@property(nonatomic,assign)int EvalTimes;
@property(nonatomic,assign)float Score;
@property(nonatomic,assign)int Rating;

@property(nonatomic,copy)NSString *CarBrandSIG;
@property(nonatomic,copy)NSString *PartsUseForSIG;
@property(nonatomic,assign)BOOL Enable;
@property(nonatomic,assign)float TotalScore;
@property(nonatomic,assign)float Balance;
@property(nonatomic,assign)BOOL Verified;
@property(nonatomic,copy)NSString *Reason;




@end

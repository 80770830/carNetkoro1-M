//
//  GarageDetailData.h
//  CLWsdht
//
//  Created by OYJ on 16/5/6.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GarageDetailData : NSObject
@property(nonatomic,copy)NSString *Id;
@property(nonatomic,copy)NSString *Mobile;
@property(nonatomic,copy)NSString *Name;
@property(nonatomic,copy)NSString *ProvincialId;
@property(nonatomic,copy)NSString *CityId;
@property(nonatomic,copy)NSString *DistrictId;
@property(nonatomic,copy)NSString *Address;
@property(nonatomic,copy)NSString *ProvincialName;
@property(nonatomic,copy)NSString *CityName;
@property(nonatomic,copy)NSString *Img;
@property(nonatomic,copy)NSString *Url;
@property(nonatomic,copy)NSString *IdNumber;
@property(nonatomic,copy)NSString *Lng;
@property(nonatomic,copy)NSString *Lat;
@property(nonatomic,strong)NSMutableArray *ServiceCarBrand;
@property(nonatomic,strong)NSMutableArray *ServicePartsUseFor;



@end

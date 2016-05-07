//
//  GarageDetailController.h
//  CLWsdht
//
//  Created by OYJ on 16/5/6.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "BaseViewController.h"
#import "BuyNowController.h"
@interface GarageDetailController : BaseViewController
@property(nonatomic,strong)BuyNowController *buyNowController;
//传过来的元素
@property(nonatomic,strong)NSString *storeMobile;

//界面元素
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *StoreDetail;
@property (weak, nonatomic) IBOutlet UILabel *storeLeval;
@property (weak, nonatomic) IBOutlet UIImageView *storeLevalimage;
@property (weak, nonatomic) IBOutlet UILabel *PeopleNum;

@property (weak, nonatomic) IBOutlet UIButton *contectGarageBut;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIScrollView *segmentScrollView;

@end

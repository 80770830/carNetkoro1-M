//
//  PayController.h
//  CLWsdht
//
//  Created by OYJ on 16/4/25.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "BaseViewController.h"
#import "MaintainModel.h"

@interface PayController : BaseViewController
@property (weak, nonatomic) IBOutlet UIButton *AliPaySelectButton;
@property (weak, nonatomic) IBOutlet UIButton *WxSelectButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property(nonatomic,assign)BOOL AlipaySelected;

//数据
@property(strong,nonatomic) MaintainModel *orderModal;

@end

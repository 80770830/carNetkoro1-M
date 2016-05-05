//
//  PayOrderController.h
//  CLWsdht
//
//  Created by OYJ on 16/5/5.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "BaseViewController.h"
#import "OrderModel.h"

@interface PayOrderController : BaseViewController

@property (weak, nonatomic) IBOutlet UIButton *AliPaySelectButton;
@property (weak, nonatomic) IBOutlet UIButton *WxSelectButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property(nonatomic,assign)BOOL AlipaySelected;

//数据
@property(strong,nonatomic) OrderModel *orderModal;
@end

//
//  PayOrderController.m
//  CLWsdht
//
//  Created by OYJ on 16/5/5.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "PayOrderController.h"
//支付需要的头文件
#import "UIViewController+WeChatAndAliPayMethod.h"
@interface PayOrderController ()
@property(nonatomic,copy)NSString *partner;
@property(nonatomic,copy)NSString *seller_id;
@property(nonatomic,copy)NSString *out_trade_no;
@property(nonatomic,copy)NSString *subject;
@property(nonatomic,copy)NSString *body;
@property(nonatomic,copy)NSString *total_fee;
@property(nonatomic,copy)NSString *ify_url;
@property(nonatomic,copy)NSString *service;
@property(nonatomic,copy)NSString *payment_type;
@property(nonatomic,copy)NSString *input_charset;
@property(nonatomic,copy)NSString *it_b_pay;
@property(nonatomic,copy)NSString *sign;
@property(nonatomic,copy)NSString *sign_type;
@end

@implementation PayOrderController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.AlipaySelected=YES;
    self.priceLabel.text=[NSString stringWithFormat:@"%@元",self.orderModal.Price];
    [self.payButton setTitle:[NSString stringWithFormat:@"确认支付%@元",self.orderModal.Price] forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)payButtonAction:(id)sender {
    if(self.AlipaySelected)
    {
        //支付宝
        [self gotoAlipay:self.orderModal];
    }
    else
    {
        //微信
        [self gotoWxchatPay:self.orderModal];
        
    }
}
- (IBAction)selectButtonAction:(UIButton*)sender {
    [self.AliPaySelectButton setBackgroundImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
    [self.WxSelectButton setBackgroundImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
    if (sender.tag==888) {
        if (self.AlipaySelected) {
            self.AlipaySelected=NO;
            [self.WxSelectButton setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
            
        }
        else
        {
            self.AlipaySelected=YES;
            [self.AliPaySelectButton setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
        }
    }
    else
    {
        if (self.AlipaySelected) {
            self.AlipaySelected=NO;
            [self.WxSelectButton setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
            
        }
        else
        {
            self.AlipaySelected=YES;
            [self.AliPaySelectButton setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
        }
    }
    
}

-(void)gotoAlipay:(OrderModel*)orderModal{
    [self getAlipayOrderInfoFromNetWork];
}

-(void)gotoWxchatPay:(OrderModel*)orderModal{
    [self payTheMoneyUseWeChatPayWithPrepay_id:@"wx20160412175918bdd8518e0b0779766239" nonce_str:@"131688030120160412175906437"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatPayResultNoti:) name:WX_PAY_RESULT object:nil];
}

//微信支付付款成功失败
-(void)weChatPayResultNoti:(NSNotification *)noti{
    NSLog(@"%@",noti);
    if ([[noti object] isEqualToString:IS_SUCCESSED]) {
        [self showMessage:@"支付成功"];
        
    }else{
        [self showMessage:@"支付失败"];
    }
    //移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WX_PAY_RESULT object:nil];
}

//支付宝支付成功失败
-(void)AliPayResultNoti:(NSNotification *)noti
{
    NSLog(@"%@",noti);
    if ([[noti object] isEqualToString:ALIPAY_SUCCESSED]) {
        [self.navigationController popViewControllerAnimated:YES];
        [self showMessage:@"支付成功"];
        //        [SVProgressHUD showWithStatus:@"支付成功"]；
        
        
    }else{
        [self showMessage:@"支付失败"];
    }
    //移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALI_PAY_RESULT object:nil];
}

- (void) showMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:alert.cancelButtonIndex animated:YES];
    });
}

#pragma mark - Networking
/**
 *  @author oyj, 16-04-13
 *
 *  获取调用支付宝相关信息
 */

-(void)getAlipayOrderInfoFromNetWork
{
    [SVProgressHUD showWithStatus:k_Status_Load];
    __block NSString *returnData;
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"Platform.asmx/AlipayPaymentUrl"];
    NSDictionary *paramDict = @{
                                @"subject":self.orderModal.StoreName,
                                @"body":@"订单",
                                @"price":self.orderModal.Price,
                                @"out_trade_no":self.orderModal.Id
                                };
    
    [ApplicationDelegate.httpManager POST:urlStr
                               parameters:paramDict
                                 progress:^(NSProgress * _Nonnull uploadProgress) {}
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      if (task.state == NSURLSessionTaskStateCompleted) {
                                          NSError* error;
                                          NSDictionary* jsonDic = [NSJSONSerialization
                                                                   JSONObjectWithData:responseObject
                                                                   options:kNilOptions
                                                                   error:&error];
                                          if ([jsonDic objectForKey:@"Success"]) {
                                              returnData=[jsonDic objectForKey:@"Data"];
                                              
                                              [[AlipaySDK defaultService] payOrder:returnData fromScheme:kAliPayURLScheme callback:^(NSDictionary *resultDic) {
                                                  NSLog(@"reslut = %@",resultDic);
                                                  if ([resultDic[@"resultStatus"] intValue]==9000) {
                                                      //进入充值列表页面
                                                      NSLog(@"支付成功");
                                                      
                                                      [TSMessage showNotificationInViewController:self
                                                                                            title:@"提示"
                                                                                         subtitle:@"付款成功"
                                                                                             type:TSMessageNotificationTypeSuccess];
                                                      //请求成功的本地回调接口
                                                      [self postAlipayOrderStateToNetWork:self.orderModal.Id];
                                                  }
                                                  else{
                                                      if([[resultDic objectForKey:@"resultStatus"] isEqual:@"8000"])
                                                      {
                                                          [SVProgressHUD showErrorWithStatus:@"正在处理中..."];
                                                      }
                                                      if([[resultDic objectForKey:@"resultStatus"] isEqual:@"4000"])
                                                      {
                                                          [SVProgressHUD showErrorWithStatus:@"订单支付失败！"];
                                                      }
                                                      if([[resultDic objectForKey:@"resultStatus"] isEqual:@"6001"])
                                                      {
                                                          [SVProgressHUD showErrorWithStatus:@"用户中途取消！"];
                                                      }
                                                      if([[resultDic objectForKey:@"resultStatus"] isEqual:@"6002"])
                                                      {
                                                          [SVProgressHUD showErrorWithStatus:@"网络连接出错！"];
                                                      }
                                                      /*
                                                       9000 订单支付成功
                                                       8000 正在处理中
                                                       4000 订单支付失败
                                                       6001 用户中途取消
                                                       6002 网络连接出错
                                                       */

                                                  }
                                              }];
                                              
                                          } else {
                                              [SVProgressHUD showErrorWithStatus:k_Error_WebViewError];
                                              
                                          }
                                          
                                      } else {
                                          [SVProgressHUD showErrorWithStatus:k_Error_Network];
                                      }
                                      
                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                      //请求异常
                                      [SVProgressHUD showErrorWithStatus:k_Error_Network];
                                  }];
}
/**
 *  @author oyj, 16-04-27
 *
 *  支付宝支付成功后，更改订单状态回调函数
 */
-(void)postAlipayOrderStateToNetWork:(NSString *)orderId
{
    [SVProgressHUD showWithStatus:k_Status_Load];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"Usr.asmx/PayParts"];
    NSDictionary *paramDict = @{
                                @"OrdersId":orderId,
                                @"IsRecharge":@"true"
                                };
    
    [ApplicationDelegate.httpManager POST:urlStr
                               parameters:paramDict
                                 progress:^(NSProgress * _Nonnull uploadProgress) {}
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      if (task.state == NSURLSessionTaskStateCompleted) {
                                          NSError* error;
                                          NSDictionary* jsonDic = [NSJSONSerialization
                                                                   JSONObjectWithData:responseObject
                                                                   options:kNilOptions
                                                                   error:&error];
                                          if ([jsonDic objectForKey:@"Success"]) {
                                              //订单状态修改成功
                                              [self.navigationController popViewControllerAnimated:YES ];
                                          } else {
                                              [SVProgressHUD showErrorWithStatus:k_Error_WebViewError];
                                              
                                          }
                                          
                                      } else {
                                          [SVProgressHUD showErrorWithStatus:k_Error_Network];
                                      }
                                      
                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                      //请求异常
                                      [SVProgressHUD showErrorWithStatus:k_Error_Network];
                                  }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

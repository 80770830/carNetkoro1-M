//
//  GarageDetailController.m
//  CLWsdht
//
//  Created by OYJ on 16/5/6.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "GarageDetailController.h"
#import "GarageDetailReturn.h"
#import "GarageDetailData.h"
#import "ServiceCarBrand.h"
#import "ServicePartsUseFor.h"
#import "MJExtension.h"

@interface GarageDetailController ()
@property(nonatomic,strong)GarageDetailReturn *returnData;
@end

@implementation GarageDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getGarageFromNetwork];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)contectGarageAction:(id)sender {
    [MJYUtils mjy_telForStartWithTelNum:self.returnData.Data.Mobile];
}
- (IBAction)segmentValueChange:(UISegmentedControl*)sender {
    [self.segmentScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (sender.selectedSegmentIndex==0) {
        UILabel *serviceCarBrand=[[UILabel alloc]initWithFrame:CGRectMake(20, 10, 80, 30)];
        serviceCarBrand.text=@"维修品牌";
        serviceCarBrand.textColor=[UIColor darkGrayColor];
        [self.segmentScrollView addSubview:serviceCarBrand];
        //添加维修品牌分类按钮
        float buttonWith=(self.segmentScrollView.frame.size.width-40-2*10)/3;
        float buttonHeight=40;
        UIButton *button;
        ServiceCarBrand *brandModal;
        for (int i=0; i<self.returnData.Data.ServiceCarBrand.count
             ; i++) {
            brandModal=[self.returnData.Data.ServiceCarBrand objectAtIndex:i];
            button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(20+i%3*(buttonWith+10), CGRectGetMaxY(serviceCarBrand.frame)+5+i/3*(buttonHeight+10),buttonWith,buttonHeight)];
            [button setBackgroundColor:[UIColor orangeColor]];
            [button setTitle:brandModal.BrandName forState:UIControlStateNormal];
            [self.segmentScrollView addSubview:button];
            
        }
        float servicePartsUseFor_y;
        if (self.returnData.Data.ServiceCarBrand.count==0) {
            servicePartsUseFor_y=10+20;
        }else
        {
            servicePartsUseFor_y=10+CGRectGetMaxY(button.frame);

        }
        UILabel *servicePartsUseFor=[[UILabel alloc]initWithFrame:CGRectMake(20,servicePartsUseFor_y , 80, 30)];
        servicePartsUseFor.text=@"维修能力";
        servicePartsUseFor.textColor=[UIColor darkGrayColor];
        [self.segmentScrollView addSubview:servicePartsUseFor];
        ServicePartsUseFor *serviceModal;
        //添加维修能力分类按钮
        for (int i=0; i<self.returnData.Data.ServicePartsUseFor.count
             ; i++) {
            serviceModal=[self.returnData.Data.ServicePartsUseFor objectAtIndex:i];
            button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(20+i%3*(buttonWith+10), CGRectGetMaxY(servicePartsUseFor.frame)+5+i/3*(buttonHeight+10),buttonWith,buttonHeight)];
            [button setBackgroundColor:[UIColor orangeColor]];
            [button setTitle:serviceModal.PartsUsrForName forState:UIControlStateNormal];
            [self.segmentScrollView addSubview:button];
            
        }

        
    }else
    {
        
    }
}
- (IBAction)confirmSelectAction:(id)sender {
    
    GarageDetailData *modal=self.returnData.Data;
    [self.buyNowController.selectAddressDic setValue:modal.Id forKey:@"Id"];
    [self.buyNowController.selectAddressDic setValue:modal.Mobile forKey:@"Mobile"];
    [self.buyNowController.selectAddressDic setValue:modal.Name forKey:@"Name"];
    [self.buyNowController.selectAddressDic setValue:modal.ProvincialId forKey:@"ProvincialId"];
    [self.buyNowController.selectAddressDic setValue:modal.ProvincialName forKey:@"ProvincialName"];
    [self.buyNowController.selectAddressDic setValue:modal.CityName forKey:@"CityName"];
    [self.buyNowController.selectAddressDic setValue:modal.CityId forKey:@"CityId"];
    [self.buyNowController.selectAddressDic setValue:modal.Address forKey:@"Address"];
    [self.buyNowController.selectAddressDic setValue:modal.DistrictId forKey:@"DistrictId"];
    self.buyNowController.state=YES;

    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - Networking
/**
 *  @author oyj, 16-05-06
 *
 *  获取修配厂信息
 */
-(void)getGarageFromNetwork
{
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"auth.asmx/GarageByMobile"];
    
    NSDictionary *paramDict = @{
                                @"mobile":self.storeMobile,
                                };
    [ApplicationDelegate.httpManager POST:urlStr
                               parameters:paramDict
                                 progress:^(NSProgress * _Nonnull uploadProgress) {}
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      //http请求状态
                                      if (task.state == NSURLSessionTaskStateCompleted) {
                                          NSDictionary *jsonDic = [JYJSON dictionaryOrArrayWithJSONSData:responseObject];
                                          if (jsonDic[@"Success"]) {
                                              [SVProgressHUD showSuccessWithStatus:@"获取成功！"];
                                              self.returnData=[GarageDetailReturn mj_objectWithKeyValues:jsonDic];
                                              [self updateUI];
                                              
                                          } else {
                                              //失败
                                              [SVProgressHUD showErrorWithStatus:@"订单提交失败！"];
                                              
                                          }
                                          
                                      } else {
                                          [SVProgressHUD showErrorWithStatus:k_Error_Network];
                                      }
                                      
                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                      //请求异常
                                      [SVProgressHUD showErrorWithStatus:k_Error_Network];
                                  }];
}
-(void)updateUI
{
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:self.returnData.Data.Url]];
    self.storeName.text=self.returnData.Data.Name;
    self.StoreDetail.text=[NSString stringWithFormat:@"%@ %@",self.returnData.Data.ProvincialName,self.returnData.Data.CityName];
    [self segmentValueChange:self.segment];

    
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

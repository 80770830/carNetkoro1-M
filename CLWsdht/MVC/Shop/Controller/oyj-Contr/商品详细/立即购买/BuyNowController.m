//
//  BuyNowController.m
//  CLWsdht
//
//  Created by OYJ on 16/4/21.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "BuyNowController.h"
#import "ImgModal.h"
#import "GoodInfoReturn.h"
#import "MJExtension.h"
#import "UserInfo.h"//用户模型信息
#import "AddressSelectController.h"
#import "GarageListController.h"

@interface BuyNowController ()<UIPickerViewDelegate,UIPickerViewDataSource>
//地址信息
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *Mobile;
//所选品牌车型
@property (weak, nonatomic) IBOutlet UILabel *selectCarBrandLabel;

//商品信息
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UIImageView *goodImage;
@property (weak, nonatomic) IBOutlet UILabel *goodName;
@property (weak, nonatomic) IBOutlet UILabel *goodPrice;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *styleLabel2;
@property (weak, nonatomic) IBOutlet UITextField *countTextField;


@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *reduceButton;


//卖家留言
@property (weak, nonatomic) IBOutlet UITextField *leaveWordsTextField;
//合计
@property (weak, nonatomic) IBOutlet UILabel *goodsTotalCount;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;

//选择修配厂收货时，必须选择车型
@property(strong,nonatomic)NSArray *CarBrandArray;
@property(strong,nonatomic)UIView *pickerCarStyleView;//装载车型选择picker的View
@property(strong,nonatomic)UIPickerView *carStylePicker;//车型选择picker
@property(assign,nonatomic)NSInteger selectComponent1;//选择的车的品牌下标
@property(assign,nonatomic)NSInteger selectComponent2;//选择的车的型号下标
@property(assign,nonatomic)BOOL selectCarBrandState;//是否选择车型 0未选 1选择

@end

@implementation BuyNowController
-(NSArray *)CarBrandArray
{
    if (!_CarBrandArray) {
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *filePath = [docPath stringByAppendingPathComponent:@"CarBrandCarModel.plist"];
        self.CarBrandArray=[NSArray arrayWithContentsOfFile:filePath];
    }
    return _CarBrandArray;
}
-(UIView *)pickerCarStyleView
{
    if (!_pickerCarStyleView) {
        self.pickerCarStyleView=[[UIView alloc]init];
        _carStylePicker=[[UIPickerView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 260)];
        _carStylePicker.delegate=self;
        _carStylePicker.dataSource=self;
        _carStylePicker.showsSelectionIndicator=YES;
        _carStylePicker.backgroundColor=[UIColor whiteColor];
        _carStylePicker.tag=1;
        UIToolbar   *pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        
        pickerDateToolbar.barStyle = UIBarStyleDefault;
        [pickerDateToolbar sizeToFit];
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(toolBarCanelClick)];
        [barItems addObject:cancelBtn];
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [barItems addObject:flexSpace];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(toolBarDoneClick)];
        [barItems addObject:doneBtn];
        [pickerDateToolbar setItems:barItems animated:YES];
        [self.pickerCarStyleView addSubview:pickerDateToolbar];
        [self.pickerCarStyleView addSubview:_carStylePicker];
    }
    return _pickerCarStyleView;
}
-(NSDictionary *)selectAddressDic
{
    if (!_selectAddressDic) {
        self.selectAddressDic=[[NSMutableDictionary alloc]initWithObjectsAndKeys://修配厂信息
                               @"",@"Id",
                               @"",@"Mobile",
                               @"",@"Name",
                               @"",@"ProvincialId",
                               @"",@"ProvincialName",
                               @"",@"CityName",
                               @"",@"CityId",
                               @"",@"DistrictId",
                               @"",@"Address",
                               nil];
    }
    return _selectAddressDic;
}


- (void)viewDidLoad {
    self.title=@"下单";
    [super viewDidLoad];
    UIBarButtonItem *returnBut=[[UIBarButtonItem alloc]initWithTitle:@"<返回" style:UIBarButtonItemStylePlain target:self action:@selector(returnAction)];
    self.navigationItem.leftBarButtonItem=returnBut;
    [self updateUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.state) {//选择发到修配厂地址
        //我的信息
        self.name.text=[self.selectAddressDic objectForKey:@"Name"];
        self.address.text=[NSString stringWithFormat:@"%@%@%@",[self.selectAddressDic objectForKey:@"ProvincialName"],[self.selectAddressDic objectForKey:@"CityName"],[self.selectAddressDic objectForKey:@"Address"]];
        self.Mobile.text=[self.selectAddressDic objectForKey:@"Mobile"];
        
    }else{
        if (self.newUsrAdsressState) {//选择新的用户地址
            //我的信息
            self.name.text=[self.selectAddressDic objectForKey:@"Name"];
            self.address.text=[NSString stringWithFormat:@"%@%@%@",[self.selectAddressDic objectForKey:@"ProvincialName"],[self.selectAddressDic objectForKey:@"CityName"],[self.selectAddressDic objectForKey:@"Address"]];
            self.Mobile.text=[self.selectAddressDic objectForKey:@"Mobile"];
        }
        else //默认登陆用户地址
        {
            //我的信息
            self.name.text=ApplicationDelegate.userInfo.Name;
            self.address.text=[NSString stringWithFormat:@"%@%@%@",ApplicationDelegate.userInfo.ProvincialName,ApplicationDelegate.userInfo.CityName,ApplicationDelegate.userInfo.Address];
            self.Mobile.text=ApplicationDelegate.userInfo.Mobile;
        }
    }
    
}
#pragma mark - UI&Data
-(void)updateUI
{
 
//商品信息
    //店铺名字
    self.storeName.text=self.goodInfo.StoreName;
    //商品图片
    ImgModal *modal=[self.goodInfo.Imgs objectAtIndex:0];
    [self.goodImage sd_setImageWithURL:[NSURL URLWithString:[modal valueForKey:@"Url"]] placeholderImage:[UIImage imageNamed:@"rc_ic_picture"]];
    //商品名字
    self.goodName.text=self.goodInfo.Name;
    //商品数量
    self.countLabel.text=@"×1";
    //商品新旧
    self.styleLabel1.text=self.goodInfo.PurityName;
    //商品性质
    self.styleLabel2.text=self.goodInfo.PartsSrcName;
    //商品价格
    self.goodPrice.text=[NSString stringWithFormat:@"￥%.2f",self.goodInfo.Price];
 //合计
    self.totalPrice.text=[NSString stringWithFormat:@"￥%.2f",self.goodInfo.Price];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Networking
/**
 *  @author oyj, 16-04-21
 *
 *  立即购买
 */
-(void)buyNowToNetwork
{
    //选择地址维修配厂，则必须选择品牌车型
    if (self.state&&(self.selectCarBrandState==NO)) {
        [SVProgressHUD showErrorWithStatus:@"请选择品牌车型"];
        return;
    }
    
    
    [SVProgressHUD showWithStatus:k_Status_Load];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"Usr.asmx/AddOrders"];
    NSString *garageOrdersId=[MJYUtils mjy_uuid];
    NSString *partsLstOrdersId=[MJYUtils mjy_uuid];
    NSString *partsOrdersId=[MJYUtils mjy_uuid];
    NSDictionary *garageOrdersJson;
    NSDictionary *partsOrdersJson;
    if (self.state) {//发送到修配厂
        NSArray *array= [[self.CarBrandArray objectAtIndex:self.selectComponent1 ]objectForKey:@"T_DicCarModel"];
        garageOrdersJson =@{
                            @"CarBrandId":[[self.CarBrandArray objectAtIndex:self.selectComponent1 ]objectForKey:@"Id"],//车辆品牌编号
                            @"CarModelId":[[array objectAtIndex:self.selectComponent2]objectForKey:@"Id" ],//车辆型号编号
                            @"Evaluate":@"",
                            @"Id":garageOrdersId,//修理订单编号 自己生成uuid
                            @"Message":@"",
                            @"Mobile":[self.selectAddressDic objectForKey:@"Mobile"],//修理厂电话
                            @"Price":@"0",
                            @"Reason":@"",
                            @"Serial":@"",
                            @"UsrGarageId":[self.selectAddressDic objectForKey:@"Id"],//修理厂编号
                            @"UsrId":ApplicationDelegate.userInfo.user_Id,//下单人编号
                            };
        partsOrdersJson =@{
                           @"Addr":self.address.text,
                           @"CityId":[self.selectAddressDic objectForKey:@"CityId"],
                           @"Consignee":self.name.text,
                           @"GarageOrdersId":garageOrdersId,
                           @"Id":partsOrdersId,
                           @"Mobile":self.Mobile.text,
                           @"Msg":self.leaveWordsTextField.text,
                           @"Price":[NSString stringWithFormat:@"%.2f",[self.countTextField.text intValue]*self.goodInfo.Price],
                           @"StoreId":self.goodInfo.UsrStoreId,
                           @"UsrId":ApplicationDelegate.userInfo.user_Id,
                           @"UsrType":@"0"
                           };
        NSLog(@"");
        
    }else//发送到用户地址
    {
        NSString *cityID;
        if (self.newUsrAdsressState) {
            cityID=[self.selectAddressDic objectForKey:@"CityId"];
        }else{
            cityID=ApplicationDelegate.userInfo.CityId;
        }
        
        garageOrdersJson =@{};
        partsOrdersJson =@{
                           @"Addr":self.address.text,
                           @"CityId":cityID,
                           @"Consignee":self.name.text,
                           @"GarageOrdersId":@"",
                           @"Id":partsOrdersId,
                           @"Mobile":self.Mobile.text,
                           @"Msg":self.leaveWordsTextField.text,
                           @"Price":[NSString stringWithFormat:@"%.2f",[self.countTextField.text intValue]*self.goodInfo.Price],
                           @"StoreId":self.goodInfo.UsrStoreId,
                           @"UsrId":ApplicationDelegate.userInfo.user_Id,
                           @"UsrType":@"0",
                           };
        
    }
   
    NSArray *partsOrdersJsonArray=@[partsOrdersJson];

    NSDictionary *partsLstJson =@{
                                  @"Cnt":self.countTextField.text,
                                  @"Id":partsLstOrdersId,
                                  @"OrdersId":partsOrdersId,
                                  @"PartsId":self.goodInfo.Id,
                                  @"Price":[NSString stringWithFormat:@"%.2f",[self.countTextField.text intValue]*self.goodInfo.Price]
                                  };

    NSArray *partsLstJsonArray=@[partsLstJson];
    NSDictionary *paramDict = @{
                                @"garageOrdersJson":[JYJSON JSONStringWithDictionaryOrArray:garageOrdersJson],
                                @"partsOrdersJson":[JYJSON JSONStringWithDictionaryOrArray:partsOrdersJsonArray],
                                @"partsLstJson":[JYJSON JSONStringWithDictionaryOrArray:partsLstJsonArray],
                                };
    NSLog(@"%@ %@ %@",[JYJSON JSONStringWithDictionaryOrArray:garageOrdersJson],[JYJSON JSONStringWithDictionaryOrArray:partsOrdersJsonArray],[JYJSON JSONStringWithDictionaryOrArray:partsLstJsonArray]);

    [ApplicationDelegate.httpManager POST:urlStr
                               parameters:paramDict
                                 progress:^(NSProgress * _Nonnull uploadProgress) {}
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      //http请求状态
                                      if (task.state == NSURLSessionTaskStateCompleted) {
                                                      NSDictionary *jsonDic = [JYJSON dictionaryOrArrayWithJSONSData:responseObject];
                                          if (jsonDic[@"Success"]) {
                                                [self dismissViewControllerAnimated:YES completion:^{
                                                  [SVProgressHUD showSuccessWithStatus:@"订单提交成功！"];
                                              }];
                                              
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



#pragma mark - Action
-(IBAction)buyNowAction:(id)sender
{
    [self buyNowToNetwork];
}

- (IBAction)addressButton:(id)sender {
    UIStoryboard *addressSB= [UIStoryboard storyboardWithName:@"AddressSelect" bundle:nil];
    AddressSelectController *addressContr = [addressSB instantiateViewControllerWithIdentifier:@"AddressSelectController"];
    addressContr.buyNowContr=self;
    [self.navigationController pushViewController:addressContr animated:YES];
}

- (IBAction)addButtonAction:(id)sender {
    //更改数量
    int number=[self.countTextField.text intValue]+1;
    self.countLabel.text=[NSString stringWithFormat:@"×%d",number];
    self.countTextField.text=[NSString stringWithFormat:@"%d",number];
    //更改件数
    self.goodsTotalCount.text=[NSString stringWithFormat:@"共计%d件商品",number];
    //更改合计价格
    self.totalPrice.text=[NSString stringWithFormat:@"￥%.2f",number*self.goodInfo.Price];

}
- (IBAction)reduceButtonAction:(id)sender {
    //更改数量
    
    int number=[self.countTextField.text intValue]-1;
    if (number==0) {
        [SVProgressHUD showInfoWithStatus:@"购买数量不能低于1件"];
        return;
    }
    self.countLabel.text=[NSString stringWithFormat:@"×%d",number];
    self.countTextField.text=[NSString stringWithFormat:@"%d",number];
    //更改件数
    self.goodsTotalCount.text=[NSString stringWithFormat:@"共计%d件商品",number];
    //更改合计价格
    self.totalPrice.text=[NSString stringWithFormat:@"￥%.2f",number*self.goodInfo.Price];
    
}
/**
 *  选择修配厂
 *
 *  @param sender
 */
- (IBAction)selectRepairFactoryAction:(id)sender {
    UIStoryboard *GarageListSB= [UIStoryboard storyboardWithName:@"GarageListStoryboard" bundle:nil];
    GarageListController *GarageListContr = [GarageListSB instantiateViewControllerWithIdentifier:@"GarageListController"];
    GarageListContr.buyNowController=self;
    [self.navigationController pushViewController:GarageListContr animated:YES];
    
    
}
/**
 *  选择车型
 *
 *  @param sender
 */
- (IBAction)carBrandSelectAction:(id)sender {
    self.pickerCarStyleView.frame=CGRectMake(0, self.view.frame.size.height-300, self.view.frame.size.width, 300);
    [self.view addSubview:self.pickerCarStyleView];
}

//车型选择picker取消完成按钮
-(void)toolBarCanelClick{
    [self.pickerCarStyleView removeFromSuperview];
}
-(void)toolBarDoneClick{
    self.selectCarBrandState=YES;
    NSString *carBrandName=[[self.CarBrandArray objectAtIndex:self.selectComponent1 ]objectForKey:@"Name"];
    NSArray *array= [[self.CarBrandArray objectAtIndex:self.selectComponent1 ]objectForKey:@"T_DicCarModel"];
    NSString *carStyleName=[[array objectAtIndex:self.selectComponent2]objectForKey:@"Name" ];
    self.selectCarBrandLabel.text=[NSString stringWithFormat:@"%@%@",carBrandName,carStyleName];
    [self.pickerCarStyleView removeFromSuperview];
    
}


//返回按钮
-(IBAction)returnAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - UIPicker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
        return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.CarBrandArray.count;
    } else{
        NSArray *array= [[self.CarBrandArray objectAtIndex:self.selectComponent1 ]objectForKey:@"T_DicCarModel"];
        return array.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [[self.CarBrandArray objectAtIndex:row ]objectForKey:@"Name"];
    } else{
        NSArray *array= [[self.CarBrandArray objectAtIndex:self.selectComponent1 ]objectForKey:@"T_DicCarModel"];
        return [[array objectAtIndex:row]objectForKey:@"Name" ];
    }
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return self.view.frame.size.width/2;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.selectComponent1=row;
        [pickerView selectRow:self.selectComponent1 inComponent:0 animated:YES];
        [pickerView reloadComponent:1];
        
    }else{
        self.selectComponent2=row;
        [pickerView selectRow:self.selectComponent2 inComponent:1 animated:YES];
    }
}



@end

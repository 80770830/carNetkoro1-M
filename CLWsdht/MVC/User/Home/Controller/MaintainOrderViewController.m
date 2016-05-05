//
//  MaintainOrderViewController.m
//  CLWsdht
//
//  Created by koroysta1 on 16/4/12.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "MaintainOrderViewController.h"
#import "AFNetworking.h"//主要用于网络请求方法
#import "UIKit+AFNetworking.h"//里面有异步加载图片的方法
#import "MJExtension.h"
#import "OrderTableViewCell.h"
#import "BaseHeader.h"
#import "MaintainModel.h"
#import "SingleCase.h"
#import "PayController.h"

@interface MaintainOrderViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *orderTableView;
@property (nonatomic, strong) NSMutableArray *partlistArr;
@property (nonatomic, copy) NSString *userId;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;

@end

@implementation MaintainOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:@"我的维修订单"];
    _partlistArr = [[NSMutableArray alloc] initWithCapacity:0];
    SingleCase *singleCase = [SingleCase sharedSingleCase];
    _userId = singleCase.str;
    [self setUpView];
    [self changLabel];
    [self GetOrderListByNetwork];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpView{
    _orderTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 104, SCREEN_WIDTH, SCREEN_HEIGHT-104) style:UITableViewStyleGrouped];
    _orderTableView.delegate=self;
    _orderTableView.dataSource=self;
    [_orderTableView registerNib:[UINib nibWithNibName:@"OrderTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderCellIdentifer"];
    [self.view addSubview:_orderTableView];
}


- (void)changLabel{
    if ([_orderState  isEqual: @"0"]) {
        [_label1 setBackgroundColor:[UIColor redColor]];
        [_label2 setBackgroundColor:[UIColor whiteColor]];
        [_label3 setBackgroundColor:[UIColor whiteColor]];
        [_label4 setBackgroundColor:[UIColor whiteColor]];
        [_label5 setBackgroundColor:[UIColor whiteColor]];
    }else if ([_orderState  isEqual: @"2"]){
        [_label1 setBackgroundColor:[UIColor whiteColor]];
        [_label2 setBackgroundColor:[UIColor redColor]];
        [_label3 setBackgroundColor:[UIColor whiteColor]];
        [_label4 setBackgroundColor:[UIColor whiteColor]];
        [_label5 setBackgroundColor:[UIColor whiteColor]];
    }else if ([_orderState  isEqual: @"3"]){
        [_label1 setBackgroundColor:[UIColor whiteColor]];
        [_label2 setBackgroundColor:[UIColor whiteColor]];
        [_label3 setBackgroundColor:[UIColor redColor]];
        [_label4 setBackgroundColor:[UIColor whiteColor]];
        [_label5 setBackgroundColor:[UIColor whiteColor]];
    }else if ([_orderState  isEqual: @"100"]){
        [_label1 setBackgroundColor:[UIColor whiteColor]];
        [_label2 setBackgroundColor:[UIColor whiteColor]];
        [_label3 setBackgroundColor:[UIColor whiteColor]];
        [_label4 setBackgroundColor:[UIColor redColor]];
        [_label5 setBackgroundColor:[UIColor whiteColor]];
    }else if ([_orderState  isEqual: @"-1"]){
        [_label1 setBackgroundColor:[UIColor whiteColor]];
        [_label2 setBackgroundColor:[UIColor whiteColor]];
        [_label3 setBackgroundColor:[UIColor whiteColor]];
        [_label4 setBackgroundColor:[UIColor whiteColor]];
        [_label5 setBackgroundColor:[UIColor redColor]];
    }
}

//待确认
- (IBAction)confirmBtn:(UIButton *)sender {
    _orderState = @"0";
    [self changLabel];
    [self GetOrderListByNetwork];
}
//待付款
- (IBAction)payBtn:(UIButton *)sender {
    _orderState = @"2";
    [self changLabel];
    [self GetOrderListByNetwork];
}
//待评价
- (IBAction)dispatchBtn:(UIButton *)sender {
    _orderState = @"3";
    [self changLabel];
    [self GetOrderListByNetwork];
}
//已交易
- (IBAction)receiveBtn:(UIButton *)sender {
    _orderState = @"100";
    [self changLabel];
    [self GetOrderListByNetwork];
}
//已取消
- (IBAction)judgeBtn:(UIButton *)sender {
    _orderState = @"-1";
    [self changLabel];
    [self GetOrderListByNetwork];
}


//获取我的订单
- (void)GetOrderListByNetwork{
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"Usr.asmx/GetGarageOrdersList"];
    NSDictionary *paramDict = @{                                @"state":_orderState,
                                @"usrId":_userId,
                                @"garageId":@"",
                                @"storeId":@"",
                                @"start":[NSString stringWithFormat:@"%d",0],
                                @"limit":[NSString stringWithFormat:@"%d",10]
                                };
    
    
    [ApplicationDelegate.httpManager POST:urlStr
                               parameters:paramDict
                                 progress:^(NSProgress * _Nonnull uploadProgress) {}
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      //http请求状态
                                      if (task.state == NSURLSessionTaskStateCompleted) {
                                          //            NSDictionary *jsonDic = [JYJSON dictionaryOrArrayWithJSONSData:responseObject];
                                          NSError* error;
                                          NSDictionary* jsonDic = [NSJSONSerialization
                                                                   JSONObjectWithData:responseObject
                                                                   options:kNilOptions
                                                                   error:&error];
                                          if (jsonDic[@"Success"]) {
                                              //成功
                                              NSLog(@"------------------%@", jsonDic);
                                              MaintainModel *maintainModel = [[MaintainModel alloc] init];
                                              _partlistArr = [maintainModel maintainModelWithDict:jsonDic];
                                              [_orderTableView reloadData];
                                              if (_partlistArr.count == 0) {
                                                  [SVProgressHUD showErrorWithStatus:@"你还没有订单"];
                                              }else{
                                                  [SVProgressHUD showSuccessWithStatus:  k_Success_Load];
                                              }
                                              
                                          } else {
                                              //失败
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


#pragma mark -- UITableViewDataSource

/*设置标题头的宽度*/
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
/*设置标题尾的宽度*/
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    //根据当前页面的state设置按钮的显示和隐藏
    int i = 0;
    if ([_orderState isEqualToString:@"2"]) {
        i = 140;
    }
    else if ([_orderState isEqualToString:@"3"]){
        i = 140;
    }
    else if ([_orderState isEqualToString:@"0"]){
        i = 110;
    }
    else if ([_orderState isEqualToString:@"-1"]){
        i = 110;
    }
    else if ([_orderState isEqualToString:@"100"]){
        i = 110;
    }
    return i;
}
//设置cell头的UI
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    MaintainModel *MM = [[MaintainModel alloc] init];
    MM = _partlistArr[section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    //店铺图标
    UIImageView *storeImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
    [storeImg setImage:[UIImage imageNamed:@"NotificationBackgroundError.png"]];
    [headerView addSubview:storeImg];
    //店铺名字
    UILabel *storeName = [[UILabel alloc] initWithFrame:CGRectMake(storeImg.frame.origin.x+storeImg.frame.size.width+5, storeImg.frame.origin.y, 100, 20)];
    [storeName setBackgroundColor:[UIColor clearColor]];
    [storeName setText:MM.GarageName];
    [storeName setTextColor:[UIColor blackColor]];
    [storeName setFont:[UIFont systemFontOfSize:14]];
    [headerView addSubview:storeName];
    //图标
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-35, storeImg.frame.origin.y, 20, 20)];
    [img setImage:[UIImage imageNamed:@"等级砖石"]];
    [headerView addSubview:img];
    return headerView;
    
}
//设置cell尾的UI
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 140)];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    
    MaintainModel *MM = [[MaintainModel alloc] init];
    MM = _partlistArr[section];
    
    //支付按钮
    UIButton *payButton = [[UIButton alloc] initWithFrame:CGRectMake(footerView.frame.size.width-80, footerView.frame.size.height-35, 65, 30)];
    [payButton setBackgroundColor:[UIColor redColor]];
    [payButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [payButton setTitle:@"支付" forState:UIControlStateNormal];
    [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    payButton.tag=section;
    [payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //评价按钮
    UIButton *judgeBtn = [[UIButton alloc] initWithFrame:CGRectMake(footerView.frame.size.width-80, footerView.frame.size.height-35, 65, 30)];
    [judgeBtn setBackgroundColor:[UIColor redColor]];
    [judgeBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [judgeBtn setTitle:@"评价" forState:UIControlStateNormal];
    [judgeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [judgeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    //[button addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
    
    //根据当前页面的state设置按钮的显示和隐藏
    if ([_orderState isEqualToString:@"2"]) {
        [footerView addSubview:payButton];
    }else if ([_orderState isEqualToString:@"3"]){
        [footerView addSubview:judgeBtn];
    }
    
    //品牌车型
    UILabel *carBrand = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 15)];
    [carBrand setBackgroundColor:[UIColor clearColor]];
    [carBrand setText:@"品牌车型"];
    [carBrand setTextColor:[UIColor lightGrayColor]];
    [carBrand setTextAlignment:NSTextAlignmentCenter];
    [carBrand setFont:[UIFont systemFontOfSize:13]];
    [footerView addSubview:carBrand];
    //品牌车型CarBrandName
    UILabel *carBrandName = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-95, carBrand.frame.origin.y, 80, 15)];
    [carBrandName setBackgroundColor:[UIColor clearColor]];
    [carBrandName setText:MM.CarBrandName];
    [carBrandName setTextAlignment:NSTextAlignmentCenter];
    [carBrandName setTextColor:[UIColor lightGrayColor]];
    [carBrandName setFont:[UIFont systemFontOfSize:13]];
    [footerView addSubview:carBrandName];
    //分割线
    UILabel *carveCar = [[UILabel alloc] initWithFrame:CGRectMake(0, carBrand.frame.origin.y+carBrand.frame.size.height+6, SCREEN_WIDTH, 0.5)];
    [carveCar setBackgroundColor:[UIColor lightGrayColor]];
    [footerView addSubview:carveCar];

    //价格车辆问题描述
    UILabel *carMessage = [[UILabel alloc] initWithFrame:CGRectMake(carBrand.frame.origin.x, carveCar.frame.origin.y+carveCar.frame.size.height+3, 90, 15)];
    [carMessage setBackgroundColor:[UIColor clearColor]];
    [carMessage setText:@"车辆问题描述"];
    [carMessage setTextColor:[UIColor lightGrayColor]];
    [carMessage setFont:[UIFont systemFontOfSize:13]];
    [footerView addSubview:carMessage];
    //车辆问题描述Message
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(carMessage.frame.origin.x, carMessage.frame.origin.y+carMessage.frame.size.height+3, SCREEN_WIDTH-20, 15)];
    [message setBackgroundColor:[UIColor clearColor]];
    [message setText:MM.Message];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setTextColor:[UIColor redColor]];
    [message setFont:[UIFont systemFontOfSize:13]];
    [footerView addSubview:message];
    //分割线
    UILabel *carveMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, message.frame.origin.y+message.frame.size.height+6, SCREEN_WIDTH, 0.5)];
    [carveMessage setBackgroundColor:[UIColor lightGrayColor]];
    [footerView addSubview:carveMessage];
    
    //价格Label
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, carveMessage.frame.origin.y+carveMessage.frame.size.height+8, 50, 15)];
    [price setBackgroundColor:[UIColor clearColor]];
    [price setText:[NSString stringWithFormat:@"￥%@",MM.GaragePrice]];
    [price setTextAlignment:NSTextAlignmentCenter];
    [price setTextColor:[UIColor redColor]];
    [price setFont:[UIFont systemFontOfSize:13]];
    [footerView addSubview:price];
    //合计
    UILabel *add = [[UILabel alloc] initWithFrame:CGRectMake(price.frame.origin.x-40, price.frame.origin.y, 35, 15)];
    [add setBackgroundColor:[UIColor clearColor]];
    [add setText:@"合计"];
    [add setTextAlignment:NSTextAlignmentRight];
    [add setTextColor:[UIColor lightGrayColor]];
    [add setFont:[UIFont systemFontOfSize:13]];
    [footerView addSubview:add];
    //共计几件商品
    UILabel *manyGood = [[UILabel alloc] initWithFrame:CGRectMake(add.frame.origin.x-95, add.frame.origin.y, 90, 15)];
    [manyGood setBackgroundColor:[UIColor clearColor]];
    [manyGood setText:@"维修费用"];
    [manyGood setTextAlignment:NSTextAlignmentCenter];
    [manyGood setTextColor:[UIColor lightGrayColor]];
    [manyGood setFont:[UIFont systemFontOfSize:13]];
    [footerView addSubview:manyGood];
    //修理厂是否确认
    UILabel *repairState = [[UILabel alloc] initWithFrame:CGRectMake(carveMessage.frame.origin.x, add.frame.origin.y, 90, 15)];
    [repairState setBackgroundColor:[UIColor clearColor]];
    [repairState setText:@"修理厂未确认"];
    [repairState setTextAlignment:NSTextAlignmentCenter];
    [repairState setTextColor:[UIColor lightGrayColor]];
    [repairState setFont:[UIFont systemFontOfSize:13]];
    //根据返回的GarageOrdersState显示维修厂的确认状态
    NSString *state = [NSString stringWithFormat:@"%@",MM.GarageOrdersState];
    if ([state isEqualToString:@"0"]) {
        [repairState setText:@"修理厂未确认"];
        [footerView addSubview:repairState];
    }
    else if ([state isEqualToString:@"1"]){
        [repairState setText:@"修理厂已确认"];
        [footerView addSubview:repairState];
    }

    return footerView;
}

//返回某个section中rows的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    MaintainModel *MM = [[MaintainModel alloc] init];
    MM = _partlistArr[section];
    return MM.PartsList.count;
}


//这个方法是用来创建cell对象，并且给cell设置相关属性的
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置标识符
    static NSString *userStoreCellIdentifer = @"orderCellIdentifer";
    OrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCellIdentifer"];
    if (cell == nil) {
        cell = [[OrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userStoreCellIdentifer];
    }
    MaintainModel *MM=_partlistArr[indexPath.section];
    GoodModel *GM=MM.PartsList[indexPath.row];
    [cell setOrderWithModel:GM];
    
    return cell;
}

//返回section的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"zzzzzz%lu",(unsigned long)_partlistArr.count);
    return _partlistArr.count;
}

#pragma mark -- UITableViewDelegate
//返回cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}
//选中cell时调起的方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //选中cell要做的操作
    
}

#pragma mark -- Action

-(IBAction)payButtonAction:(UIButton*)sender
{
    PayController *contr=[[PayController alloc]init];
    MaintainModel *OM = [[MaintainModel alloc] init];
    OM = _partlistArr[sender.tag];
    contr.orderModal=OM;
    [self.navigationController pushViewController:contr animated:YES];
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

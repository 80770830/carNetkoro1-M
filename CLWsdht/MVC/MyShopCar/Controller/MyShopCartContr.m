//
//  MyShopCartContr.m
//  CLWsdht
//
//  Created by OYJ on 16/4/11.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "MyShopCartContr.h"
#import "CarTableViewCell.h"
#import "ShopCartReturnData.h"
#import "ShopCartData.h"
#import "ShopCartDetailData.h"
#import "ShopCartInfoPart.h"
#import "ShopCartDetailData.h"
#import "ShopCartInfoPart.h"
#import "CarTableSectionViewCell.h"
#import "SelectButton.h"
#import "SettleViewController.h"
#import "MJExtension.h"
#import "UserInfo.h"//用户模型信息


@interface MyShopCartContr ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL CartGoodsState[1000][1000];//存每个商品勾选状态
    BOOL CartSectionState[1000];//存每个店铺勾选状态
}
@property (weak, nonatomic) IBOutlet UITableView *carTableView;
@property (weak, nonatomic) IBOutlet SelectButton *selectAllButton;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
@property (weak, nonatomic) IBOutlet UIButton *settleAcountButton;

@property (strong,nonatomic) ShopCartReturnData *returnAllData;
@property (strong,nonatomic) NSMutableArray *ShopCartDataArray;

@end

@implementation MyShopCartContr

-(void)viewWillAppear:(BOOL)animated
{
    [self initData];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"购物车";
//    [self initData];
//    CartGoodsState[1][0]=true;
//    if (CartGoodsState[2][0]==false) {
//        NSLog(@"false");
//    }
//    if (CartGoodsState[1][0]==true) {
//        NSLog(@"true");
//    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)settleAcountAction:(id)sender {
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.ShopCartDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ShopCartDetailData *part=[self.ShopCartDataArray objectAtIndex:section];
    return part.Parts.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"carTableCell";
    
    ShopCartDetailData *part=[self.ShopCartDataArray objectAtIndex:indexPath.section];
    ShopCartInfoPart *infoPart=[part.Parts objectAtIndex:indexPath.row];
    CarTableViewCell *cell = [self.carTableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[CarTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.nameLabel.text=infoPart.Name;
    cell.priceLabel.text=[NSString stringWithFormat:@"￥%f",infoPart.Price];
    cell.countTextField.text=[NSString stringWithFormat:@"%d",infoPart.Cnt];
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:infoPart.Url]placeholderImage:[UIImage imageNamed:@"rc_ic_picture"]];
    
    cell.selectButton.section=cell.addButton.section=cell.reduceButton.section=indexPath.section;
    cell.selectButton.row=cell.addButton.row=cell.reduceButton.row=indexPath.row;
    cell.selectButton.selectState=CartGoodsState[indexPath.section][indexPath.row];
    [self setButtonSelectOrNo:cell.selectButton withState:CartGoodsState[indexPath.section][indexPath.row]];
    cell.addButton.countTextField= cell.countTextField;
    cell.reduceButton.countTextField= cell.countTextField;
    
    [cell.selectButton addTarget:self action:@selector(RowSelecButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.addButton addTarget:self action:@selector(AddButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.reduceButton addTarget:self action:@selector(reduceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    


    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    OrderEvaluateController *orderWaitEvluate=[[OrderEvaluateController alloc]initWithNibName:@"OrderEvaluateController" bundle:nil];
//    [self.navigationController pushViewController:orderWaitEvluate animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 42;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *cellID = @"carTableCellSection";
    CarTableSectionViewCell *cell = [self.carTableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[CarTableSectionViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    ShopCartDetailData *part=[self.ShopCartDataArray objectAtIndex:section];
    cell.nameLabel.text=part.StoreName;
    cell.selectButton.section=section;
    cell.selectButton.row=-1;
    if (CartSectionState[section]) {
        cell.selectButton.selectState=CartSectionState[section];
        [self setButtonSelectOrNo:cell.selectButton withState:true];
    }
    else
    {
        cell.selectButton.selectState=CartSectionState[section];
        [self setButtonSelectOrNo:cell.selectButton withState:false];

    }
    
    [cell.selectButton addTarget:self action:@selector(SectionSelecButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - tableview代理方法
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self delCartGoodsToNetwork:indexPath];
}

#pragma mark - Networking
/**
 *  @author oyj, 16-04-13
 *
 *  获取商品列表
 */

-(void)getCartGoodsInfoFromNetwork
{
    
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"Usr.asmx/GetCartList"];
    NSDictionary *paramDict = @{
                                @"usrId":ApplicationDelegate.userInfo.user_Id,
                                @"start":@"0",
                                @"limit":@"30"
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
                                          ShopCartReturnData *data=[ShopCartReturnData mj_objectWithKeyValues:jsonDic];
                                          if (data.Success) {
//                                              [self.ShopCartDataArray removeAllObjects];
                                              
                                              self.ShopCartDataArray=data.Data.Data;
                                              
                                              
                                              [SVProgressHUD dismiss];
                                              [self.carTableView reloadData];
                                              [self calculatePriceAndTotalCount];
                                              
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
 *  @author oyj, 16-04-13
 *
 *  修改商品数量
 */

-(void)getCartEditGoodsCountToNetwork:(SelectButton*)button withState:(BOOL)addState
{
    NSLog(@"%@",button.countTextField.text);
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"Usr.asmx/EditCart"];
    
       
    ShopCartDetailData *shopCartDetailData=[self.ShopCartDataArray objectAtIndex:button.section];
    ShopCartInfoPart *shopCartInfoPart=[shopCartDetailData.Parts objectAtIndex:button.row];
    
    int count;
    if(addState){
        count=[button.countTextField.text intValue]+1;
    }else
    {
        count=[button.countTextField.text intValue]-1;
    }

    NSDictionary *cartJson =@{
                                  @"Id":shopCartInfoPart.Id,
                                  @"UsrId":shopCartInfoPart.UsrId,
                                  @"PartsId":shopCartInfoPart.PartsId,
                                  @"AddDate":shopCartInfoPart.AddDate,
                                  @"Cnt":[NSString stringWithFormat:@"%d",count],
                                  
                                  };
    NSError *error;
    NSData *partsLstJsonArrayData = [NSJSONSerialization dataWithJSONObject:cartJson options:NSJSONWritingPrettyPrinted error:&error];
    NSString *partsLstJsonArrayDataJsonString = [[NSString alloc] initWithData:partsLstJsonArrayData encoding:NSUTF8StringEncoding];
    
    NSDictionary *paramDict = @{
                                @"cartJson":partsLstJsonArrayDataJsonString,
                                
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
                                          ShopCartReturnData *data=[ShopCartReturnData mj_objectWithKeyValues:jsonDic];
                                          if (data.Success) {
                                                                                           [SVProgressHUD dismiss];
                                              [self getCartGoodsInfoFromNetwork];
                                              
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
 *  @author oyj, 16-04-13
 *
 *  删除商品
 */

-(void)delCartGoodsToNetwork:(NSIndexPath *)indexPath
{
    
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"Usr.asmx/DelCart"];
    
    ShopCartDetailData *shopCartDetailData=[self.ShopCartDataArray objectAtIndex:indexPath.section];
    ShopCartInfoPart *shopCartInfoPart=[shopCartDetailData.Parts objectAtIndex:indexPath.row];
        NSArray *partsLstJsonArray=@[shopCartInfoPart.Id];
    
    NSError *error;
    NSData *partsLstJsonArrayData = [NSJSONSerialization dataWithJSONObject:partsLstJsonArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *partsLstJsonArrayDataJsonString = [[NSString alloc] initWithData:partsLstJsonArrayData encoding:NSUTF8StringEncoding];
    
    NSDictionary *paramDict = @{
                                @"guidLstJson":partsLstJsonArrayDataJsonString,
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
                                          ShopCartReturnData *data=[ShopCartReturnData mj_objectWithKeyValues:jsonDic];
                                          if (data.Success) {
                                              [self getCartGoodsInfoFromNetwork];
                                              
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


#pragma mark - Data & UI
//数据
-(void)initData
{
    [self getCartGoodsInfoFromNetwork];
}
#pragma mark - Action
-(void)AddButtonAction:(SelectButton*)addbutton
{
    [self getCartEditGoodsCountToNetwork:addbutton withState:true];
}

-(void)reduceButtonAction:(SelectButton*)addbutton
{
    [self getCartEditGoodsCountToNetwork:addbutton withState:false];
}
//店铺商品勾选按钮
-(void)RowSelecButtonAction:(SelectButton*)button
{
    if (CartGoodsState[button.section][button.row]) {
        CartGoodsState[button.section][button.row]=!CartGoodsState[button.section][button.row];
        //取消勾选商品，则全选按钮也被取消勾选
        self.selectAllButton.selectState=NO;
        [self setButtonSelectOrNo:self.selectAllButton withState:NO];
        //店铺头标题也被取消勾选
        CartSectionState[button.section]=NO;
        [self.carTableView reloadData];

    }
    else
    {
        CartGoodsState[button.section][button.row]=!CartGoodsState[button.section][button.row];
        [self.carTableView reloadData];

    }
    [self calculatePriceAndTotalCount];

}
//店铺全选按钮
-(void)SectionSelecButtonAction:(SelectButton*)button
{
    button.selectState=!button.selectState;
    ShopCartDetailData *data=[self.ShopCartDataArray objectAtIndex:button.section];
    if (button.selectState) {
        CartSectionState[button.section]=button.selectState;
        for (int i=0; i<data.Parts.count; i++) {
        CartGoodsState[button.section][i]=true;
        }
        [self.carTableView reloadData];//刷新所有被选中的店铺配件，店铺勾选态被置为空

    }
    else
    {
        CartSectionState[button.section]=button.selectState;
        for (int i=0; i<data.Parts.count; i++) {
            CartGoodsState[button.section][i]=false;
        }
        self.selectAllButton.selectState=false;
        [self setButtonSelectOrNo:self.selectAllButton withState:false];//取消全选按钮勾选态
        [self.carTableView reloadData];
    }
    [self calculatePriceAndTotalCount];

}
//根据按钮状态设置图标
-(void)setButtonSelectOrNo:(SelectButton *)button withState:(BOOL)state
{
    if (state) {
        [button setBackgroundImage:[UIImage imageNamed:@"select"] forState:UIControlStateNormal];
    }
    else{
        [button setBackgroundImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
    }
}
//全选按钮
- (IBAction)selectAllButtonAction:(id)sender {
    if(self.selectAllButton.selectState)
    {
        self.selectAllButton.selectState=false;
        [self setButtonSelectOrNo:self.selectAllButton withState:false];
        [self setCartGoodsState:false];
    }else
    {
        self.selectAllButton.selectState=true;
        [self setButtonSelectOrNo:self.selectAllButton withState:true];
        [self setCartGoodsState:true];
    }
    [self.carTableView reloadData];
    [self calculatePriceAndTotalCount];

}
//数组所有元素置为一个状态
-(void)setCartGoodsState:(BOOL)state
{
    for (int i=0; i<self.ShopCartDataArray.count; i++) {
        CartSectionState[i]=state;
        int j;
        ShopCartDetailData *data=[self.ShopCartDataArray objectAtIndex:i];
        for (j=0; j<data.Parts.count; j++) {
            CartGoodsState[i][j]=state;
        }
    }
}

//合计件数，计算总价
-(void)calculatePriceAndTotalCount
{
    int totalCount=0;
    float totalPrice=0;
    
    for (int i=0; i<self.ShopCartDataArray.count; i++) {
        ShopCartDetailData *data=[self.ShopCartDataArray objectAtIndex:i];
        for (int j=0; j<data.Parts.count; j++) {
            if(CartGoodsState[i][j])
            {
                totalCount++;
                ShopCartInfoPart *part=[data.Parts objectAtIndex:j];
                totalPrice=part.Price*part.Cnt+totalPrice;
                
            }
            
        }
    }
    self.totalPrice.text=[NSString stringWithFormat:@"%.2f",totalPrice];
    [self.settleAcountButton setTitle:[NSString stringWithFormat:@"结算(%d)",totalCount] forState:UIControlStateNormal];
    
}
- (IBAction)settleAccountActonTotal:(id)sender {
    NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<self.ShopCartDataArray.count; i++) {
        ShopCartDetailData *shopData=[[ShopCartDetailData alloc]init];
        shopData.Parts=[NSMutableArray array];
        ShopCartDetailData *data=[self.ShopCartDataArray objectAtIndex:i];
        for (int j=0; j<data.Parts.count; j++) {
            if (CartGoodsState[i][j]) {
                shopData.UsrStoreId=data.UsrStoreId;
                shopData.StoreName=data.StoreName;
                [shopData.Parts addObject: [data.Parts objectAtIndex:j]];
                
            }
            if( (j==data.Parts.count-1)&&(shopData.Parts.count!=0)) {
                [array addObject:shopData];
            }
        }
    }
    if (array.count>0) {
        UIStoryboard *MyShopCartContr = [UIStoryboard storyboardWithName:@"MyShopCartContr" bundle:nil];
        SettleViewController *settleViewContr = [MyShopCartContr instantiateViewControllerWithIdentifier:@"SettleViewController"];
        settleViewContr.settleArray=array;
         UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:settleViewContr];
        [self presentViewController:nav animated:YES completion:^{}];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请勾选物品后提交"];
    }
}

@end

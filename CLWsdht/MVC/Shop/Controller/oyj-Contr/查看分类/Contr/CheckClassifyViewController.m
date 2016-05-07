//
//  CheckClassifyViewController.m
//  CLWsdht
//
//  Created by OYJ on 16/4/15.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "CheckClassifyViewController.h"
#import "CheckClassifyCell1.h"
#import "CheckClassifyCell2.h"
#import "CheckClassifyCell3.h"
#import "returnData.h"
#import "MJExtension.h"
#import "PartsUse.h"
#import "PartsType.h"
#import "PartsListContr.h"



@interface CheckClassifyViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)NSMutableArray *array;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CheckClassifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"商品分类";
    [self addHearderView];
    [self getClassifyFromNetwork];
    // Do any additional setup after loading the view from its nib.
}
-(void)addHearderView
{
    static NSString *cellID = @"CheckClassifyCell1";
    
    CheckClassifyCell1 *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    [cell.allGoodsButton addTarget:self action:@selector(allGoodsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView=cell;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    PartsUse *data=[self.array objectAtIndex:section];
    if (data.Types.count%2==1) {
        return data.Types.count/2+1;
    }else
    return data.Types.count/2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"CheckClassifyCell3";

        CheckClassifyCell3 *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell==nil)
    {
        cell = [[CheckClassifyCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell.button1 addTarget:self action:@selector(ClassifybuttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.button2 addTarget:self action:@selector(ClassifybuttonAction:) forControlEvents:UIControlEventTouchUpInside];
    PartsUse *data=[self.array objectAtIndex:indexPath.section];
    PartsType *partsType=[data.Types objectAtIndex:indexPath.row*2];
    [cell.button1 setTitle:partsType.TypeName forState:UIControlStateNormal];
    cell.button1.PartsTypeId=partsType.PartsTypeId;
    cell.button1.PartsUseForId=data.PartsUseForId;
    if (indexPath.row*2+1>data.Types.count-1) {
        cell.button2.hidden=YES;
    }else
    {
        cell.button2.hidden=NO;
        PartsType *partsType=[data.Types objectAtIndex:indexPath.row*2+1];
        [cell.button2 setTitle:partsType.TypeName forState:UIControlStateNormal];
        cell.button2.PartsTypeId=partsType.PartsTypeId;
        cell.button2.PartsUseForId=data.PartsUseForId;

    }
        
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 27;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *cellID = @"CheckClassifyCell2";
    CheckClassifyCell2 *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[CheckClassifyCell2 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    PartsUse *part=[self.array objectAtIndex:section];
    [cell.titleButton setTitle:part.UseForName forState:UIControlStateNormal];
    cell.titleButton.PartsUseForId=part.PartsUseForId;
    [cell.titleButton addTarget:self action:@selector(titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - Networking
/**
 *  @author oyj, 16-04-15
 *
 *  获取商品分类
 */

 -(void)getClassifyFromNetwork
{
    
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"UsrStore.asmx/GetPartsUseForByStore"];
    
    NSDictionary *paramDict = @{
                                @"StoreId":self.StoreId,
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
                                          returnData *data=[returnData mj_objectWithKeyValues:jsonDic];
                                          if (data.Success) {
                                              self.array=data.Data;
                                              [SVProgressHUD dismiss];
                                              [self.tableView reloadData];
                                              
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
//全部商品
- (IBAction)allGoodsButtonAction:(UIButton*)button
{
    UIStoryboard *CheckClassify = [UIStoryboard storyboardWithName:@"CheckClassify" bundle:nil];
    PartsListContr *contr = (PartsListContr*)[CheckClassify instantiateViewControllerWithIdentifier:@"PartsListContr"];
    contr.UsrStoreId=self.StoreId;
    contr.state=0;
    [self.navigationController pushViewController:contr animated:YES];
}
//点击商品大类
- (IBAction)titleButtonAction:(CellRowButton*)sender {
    UIStoryboard *CheckClassify = [UIStoryboard storyboardWithName:@"CheckClassify" bundle:nil];
    PartsListContr *contr = (PartsListContr*)[CheckClassify instantiateViewControllerWithIdentifier:@"PartsListContr"];
    contr.UsrStoreId=self.StoreId;
    contr.PartsUseForId=sender.PartsUseForId;
    contr.state=1;
    [self.navigationController pushViewController:contr animated:YES];

}
//点击商品子类
- (IBAction)ClassifybuttonAction:(CellRowButton*)sender {
    UIStoryboard *CheckClassify = [UIStoryboard storyboardWithName:@"CheckClassify" bundle:nil];
    PartsListContr *contr = (PartsListContr*)[CheckClassify instantiateViewControllerWithIdentifier:@"PartsListContr"];
    contr.UsrStoreId=self.StoreId;
    contr.PartsTypeId=sender.PartsTypeId;
    contr.PartsUseForId=sender.PartsUseForId;
    contr.state=2;
    [self.navigationController pushViewController:contr animated:YES];
    
    
}


@end

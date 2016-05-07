//
//  PartsListContr.m
//  CLWsdht
//
//  Created by OYJ on 16/4/16.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "PartsListContr.h"
#import "CheckClassifyCell.h"
#import "returnDataPartsList.h"
#import "returnDataDetailPartsList.h"
#import "MJExtension.h"
#import "ProductInfoViewController.h"


@interface PartsListContr ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)NSMutableArray *array;
@end

@implementation PartsListContr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"商品列表";

    [self getGoodsClassifyFromNetwork];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.array.count%2==0) {
        return self.array.count/2;
    }else
    {
        return self.array.count/2+1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 189;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"PartsListCell";
    
    CheckClassifyCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[CheckClassifyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    returnDataDetailPartsList *data=[self.array objectAtIndex:indexPath.row*2];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager downloadImageWithURL:[NSURL URLWithString:data.Url] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [cell.imageButton1 setBackgroundImage:image forState:UIControlStateNormal];
    }];
    cell.nameTitle1.text=data.Name;
    cell.priceTitle1.text=[NSString stringWithFormat:@"¥%.2f",data.Price];
    cell.imageButton1.goodId=data.Id;
    cell.imageButton1.storeMobile=data.Mobile;

    [cell.imageButton1 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row*2+1>self.array.count-1) {
        cell.view2.hidden=YES;
    }else
    {
        data=[self.array objectAtIndex:indexPath.row*2+1];
        cell.view2.hidden=NO;
        [manager downloadImageWithURL:[NSURL URLWithString:data.Url] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [cell.imageButton2 setBackgroundImage:image forState:UIControlStateNormal];
        }];
        cell.nameTitle2.text=data.Name;
        cell.priceTitle2.text=[NSString stringWithFormat:@"¥%.2f",data.Price];
        cell.imageButton2.goodId=data.Id;
        cell.imageButton2.storeMobile=data.Mobile;
        [cell.imageButton2 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    
    
    
    return cell;
}


#pragma mark - Networking
/**
 *  @author oyj, 16-04-15
 *
 *  获取店铺商品列表
 */

-(void)getGoodsClassifyFromNetwork
{
    
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"UsrStore.asmx/GetPartsList"];
    NSDictionary *paramDict;
    switch (self.state) {
        case 0://全部商品
            NSLog(@"%@",self.UsrStoreId);
           paramDict = @{
                         @"UsrStoreId":self.UsrStoreId,
                         @"State":@"1"
                         };
            break;
        case 1://大类别商品
            paramDict = @{
                          @"UsrStoreId":self.UsrStoreId,
                          @"PartsUseForId":self.PartsUseForId,
                          @"State":@"1"
                          };
            break;
        case 2://小类别商品
            paramDict = @{
                          @"UsrStoreId":self.UsrStoreId,
                          @"PartsUseForId":self.PartsUseForId,
                          @"PartsTypeId":self.PartsTypeId,
                          @"State":@"1"
                          };
            break;
            
        default:
            break;
    }
    
    NSError *error;
    NSData *partsLstJsonArrayData = [NSJSONSerialization dataWithJSONObject:paramDict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *partsLstJsonArrayDataJsonString = [[NSString alloc] initWithData:partsLstJsonArrayData encoding:NSUTF8StringEncoding];
    
    NSDictionary *paramDictAll = @{
                                   @"limit":@"30",
                                   @"partsJson":partsLstJsonArrayDataJsonString,
                                   @"start":@"0",
                                   @"sortJson":@"",

                                
                                };
    [ApplicationDelegate.httpManager POST:urlStr
                               parameters:paramDictAll
                                 progress:^(NSProgress * _Nonnull uploadProgress) {}
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      if (task.state == NSURLSessionTaskStateCompleted) {
                                          NSError* error;
                                          NSDictionary* jsonDic = [NSJSONSerialization
                                                                   JSONObjectWithData:responseObject
                                                                   options:kNilOptions
                                                                   error:&error];
                                          returnDataPartsList *data=[returnDataPartsList mj_objectWithKeyValues:jsonDic];
                                          if (data.Success) {
                                              NSLog(@"%@",data.Data);
                                              self.array=data.Data.Data;
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
-(IBAction)buttonAction:(CellRowButton*)sender
{
    ProductInfoViewController *ScrollViewTestVC=[[ProductInfoViewController alloc]init];
    
    ScrollViewTestVC.goodID=sender.goodId;
    ScrollViewTestVC.storeMobile=sender.storeMobile;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:ScrollViewTestVC animated:YES];
}
@end

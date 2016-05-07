//
//  AddressSelectController.m
//  CLWsdht
//
//  Created by OYJ on 16/5/5.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "AddressSelectController.h"
#import "UserInfo.h"
#import "AddressSelectCell.h"

@interface AddressSelectController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong,nonatomic) NSMutableArray *addressList;
@end

@implementation AddressSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"地址选择";
    [self getData];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.addressList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AddressSelectCell";
    AddressSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[AddressSelectCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:cellIdentifier];
    }
    NSDictionary *data=[self.addressList objectAtIndex:indexPath.row];
    cell.name.text=[data objectForKey:@"Name"];
    cell.mobile.text=[data objectForKey:@"Telephone"];
    cell.address.text=[NSString stringWithFormat:@"%@%@%@%@",[data objectForKey:@"ProvincialName"],[data objectForKey:@"CityName"],[data objectForKey:@"DistrictName"],[data objectForKey:@"DetailAddress"]];
    if ([[data objectForKey:@"IsDefault"]boolValue]) {
    cell.select.hidden=NO;

    }


    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

/**
 *  获取我的地址列表信息接口数据
 */
- (void)getData
{
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,k_url_GetAddressList];
    
    NSDictionary *paramDict = @{
                                @"UsrId":ApplicationDelegate.userInfo.user_Id
                                };
    
    [ApplicationDelegate.httpManager POST:urlStr parameters:paramDict progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //http请求状态
        if (task.state == NSURLSessionTaskStateCompleted) {
            NSDictionary *jsonDic = [JYJSON dictionaryOrArrayWithJSONSData:responseObject];
            //NSLog(@"返回结果%@",jsonDic);
            NSString *status = [NSString stringWithFormat:@"%@",jsonDic[@"Success"]];
            if ([status isEqualToString:@"1"]) {
                //成功返回
                // NSArray *jsonDic2 = [JYJSON dictionaryOrArrayWithJSONSString:[jsonDic objectForKey:@"Data"]];
                
                //NSLog(@"ttt:%@",jsonDic2);
                self.addressList = [JYJSON dictionaryOrArrayWithJSONSString:[jsonDic objectForKey:@"Data"]];
                
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            } else {
                [SVProgressHUD showErrorWithStatus:jsonDic[@"Message"]];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:k_Error_Network];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //请求异常
        [SVProgressHUD showErrorWithStatus:k_Error_Network];
    }];
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selctDic=[self.addressList objectAtIndex:indexPath.row];
    self.buyNowContr.selectAddressDic=[[NSMutableDictionary alloc]initWithObjectsAndKeys://归到和修配厂信息一样格式
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
    [self.buyNowContr.selectAddressDic setValue:[selctDic objectForKey:@"Id"] forKey:@"Id"];
    [self.buyNowContr.selectAddressDic setValue:[selctDic objectForKey:@"Telephone"] forKey:@"Mobile"];
    [self.buyNowContr.selectAddressDic setValue:[selctDic objectForKey:@"Name"] forKey:@"Name"];
    [self.buyNowContr.selectAddressDic setValue:@"" forKey:@"ProvincialId"];
    [self.buyNowContr.selectAddressDic setValue:[selctDic objectForKey:@"ProvincialName"] forKey:@"ProvincialName"];
    [self.buyNowContr.selectAddressDic setValue:[selctDic objectForKey:@"CityName"] forKey:@"CityName"];
    [self.buyNowContr.selectAddressDic setValue:[selctDic objectForKey:@"Id"] forKey:@"CityId"];
    [self.buyNowContr.selectAddressDic setValue:[selctDic objectForKey:@"DetailAddress"] forKey:@"Address"];
    [self.buyNowContr.selectAddressDic setValue:@"" forKey:@"DistrictId"];
    self.buyNowContr.newUsrAdsressState=1;
    [self.navigationController popViewControllerAnimated:YES];
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

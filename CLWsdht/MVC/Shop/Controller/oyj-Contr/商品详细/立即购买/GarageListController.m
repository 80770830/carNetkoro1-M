//
//  GarageListController.m
//  CLWsdht
//
//  Created by OYJ on 16/5/5.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "GarageListController.h"
#import "GarageReturnData.h"
#import "GarageModal.h"
#import "GarageListCell.h"
#import "MJExtension.h"
#import "GarageDetailController.h"

@interface GarageListController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)GarageReturnData *returnAllData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GarageListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getGarageList];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)districtAction:(id)sender {
}
- (IBAction)sortAction:(id)sender {
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    

*/
    UIStoryboard *GarageListSB= [UIStoryboard storyboardWithName:@"GarageListStoryboard" bundle:nil];
    GarageDetailController *GarageDetailContr = [GarageListSB instantiateViewControllerWithIdentifier:@"GarageDetailController"];
    GarageModal *modal=[self.returnAllData.Data.Data objectAtIndex:indexPath.row];
    GarageDetailContr.storeMobile=modal.Mobile;
    GarageDetailContr.buyNowController=self.buyNowController;
    
    [self.navigationController pushViewController:GarageDetailContr animated:YES];


}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.returnAllData.Data.Data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"GarageListCell";
    GarageListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[GarageListCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:cellIdentifier];
    }
    GarageModal *modal=[self.returnAllData.Data.Data objectAtIndex:indexPath.row];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:modal.Url] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        cell.headImage.image=image;
    }];
    cell.repairFactoryName.text=modal.Name;
    cell.Province.text=modal.ProvincialName;
    cell.City.text=modal.CityName;

    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105;
}

-(void)getGarageList
{
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"UsrGarage.asmx/GetGarageList"];
    NSDictionary *paramDict = @{
                                @"garageJson":@"",
                                @"sortJson":@"",
                                @"brandSIG":@"",
                                @"useForSIG":@"",
                                @"start":@"0",
                                @"limit":@"30",
                                
                                };
    [ApplicationDelegate.httpManager POST:urlStr
                               parameters:paramDict
                                 progress:^(NSProgress * _Nonnull uploadProgress) {}
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      //http请求状态
                                      if (task.state == NSURLSessionTaskStateCompleted) {
                                          NSDictionary *jsonDic = [JYJSON dictionaryOrArrayWithJSONSData:responseObject];
                                          self.returnAllData=[GarageReturnData mj_objectWithKeyValues:jsonDic];
                                          [SVProgressHUD showSuccessWithStatus:@"加载成功！"];

                                          [self.tableView reloadData];
                                         
                                          
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

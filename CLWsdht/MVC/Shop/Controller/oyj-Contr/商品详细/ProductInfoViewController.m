//
//  ProductInfoViewController.m
//  PagingDemo
//
//  Created by Liu jinyong on 15/8/6.
//  Copyright (c) 2015年 Baidu 91. All rights reserved.
//

#import "ProductInfoViewController.h"
//#import "UIScrollView+JYPaging.h"
#import "GoodInfoReturn.h"
#import "MJExtension.h"
#import "ImgModal.h"
#import "StoreReturnData.h"
#import "CheckClassifyViewController.h"
#import "PartsListContr.h"
#import "BuyNowController.h"
#import "ProductDetailContr.h"

#import "PictureInfController.h"
#import "GoodsDescriptionViewController.h"
#import "GoodsEvaluateController.h"


#define IPHONE_W ([UIScreen mainScreen].bounds.size.width)
#define IPHONE_H ([UIScreen mainScreen].bounds.size.height)

@interface ProductInfoViewController (){
    StoreReturnData *storeInfoReturn;//配件商详情数据
    NSString *UsrStoreId;
    
    UIScrollView *detailScrollView;
}

/**
 * 整体scrollWholeView.tag=0；
 * 商品详情scrollView.tag=1；
 * 商品详情切换scrollV2.tag=2
 * 图文详情scrollview.tag=3
 *
 *
 */
//界面元素
@property (weak, nonatomic) IBOutlet UIScrollView *scrollWholeView;//最大scrollView tag=0



@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;//商品详细 tag=1

@property (weak, nonatomic) IBOutlet UIScrollView *pictureScrollView;//商品详细中轮播图片scrollview

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UIButton *collection;

@property (weak, nonatomic) IBOutlet UIImageView *headPicture;
@property (weak, nonatomic) IBOutlet UILabel *shopName;
@property (weak, nonatomic) IBOutlet UIImageView *shopStar;

@property (weak, nonatomic) IBOutlet UILabel *allGoodsNumber;
@property (weak, nonatomic) IBOutlet UILabel *allAttentionPeople;

@property (weak, nonatomic) IBOutlet UIButton *classButton;
@property (weak, nonatomic) IBOutlet UIButton *gotoShopButton;

@property (weak, nonatomic) IBOutlet UIButton *consultButton;


//数据
@property (strong,nonatomic)NSMutableArray *imageArray;//轮播图片
@property (strong,nonatomic)GoodInfoReturn *goodInfoReturn;//商品详情总体数据

@property(strong,nonatomic)BuyNowController *contr;//立即购买Contr
@property(strong,nonatomic)UIScrollView *scrollV2;//商品详情切换 tag=2

@property(strong,nonatomic)ProductDetailContr *detailVC;//商品更多信息


@property(strong,nonatomic)PictureInfController *pictureInfContr;//图文详情
@property(strong,nonatomic)GoodsDescriptionViewController *goodsDescriptionViewContr;//产品参数
@property(strong,nonatomic)GoodsEvaluateController *goodsEvaluateContr;//商品评价

@end

@implementation ProductInfoViewController
-(PictureInfController *)pictureInfContr
{
    if (!_pictureInfContr) {
        self.pictureInfContr=[[PictureInfController alloc]init];
         self.pictureInfContr.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//        self.pictureInfContr.scrollView.delegate=self;
//        self.pictureInfContr.scrollView.tag=3;//图文详情
    }
    return _pictureInfContr;
}

-(GoodsDescriptionViewController *)goodsDescriptionViewContr
{
    if (!_goodsDescriptionViewContr) {
        self.goodsDescriptionViewContr=[[GoodsDescriptionViewController alloc]init];
        self.goodsDescriptionViewContr.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
    }
    return _goodsDescriptionViewContr;
}

-(GoodsEvaluateController *)goodsEvaluateContr
{
    if (!_goodsEvaluateContr) {
        self.goodsEvaluateContr=[[GoodsEvaluateController alloc]init];
        self.goodsEvaluateContr.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    }
    return _goodsEvaluateContr;
}


-(UIScrollView *)scrollV2
{
    if (!_scrollV2) {
        self.scrollV2=[[UIScrollView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, SCREEN_HEIGHT-50)];
        self.scrollV2.tag=2;
        self.detailVC = [[ProductDetailContr alloc]init];
        [self.detailVC loadView];
        self.detailVC.scrollView.delegate=self;
        [self.detailVC.segmentControl addTarget:self action:@selector(segmentValueChange:) forControlEvents:UIControlEventValueChanged];
        [self segmentValueChange:self.detailVC.segmentControl];
        [self.scrollV2 addSubview:self.detailVC.view];
        [self.scrollWholeView addSubview:self.scrollV2];
        self.scrollV2.delegate=self;
        self.scrollV2.showsVerticalScrollIndicator = FALSE;
        
        
    }
    return _scrollV2;
}


-(BuyNowController *)contr
{
    if (!_contr) {
        self.contr=[[BuyNowController alloc]init];
    }
    return _contr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollWholeView.contentSize=CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT*2-50);
    self.scrollWholeView.pagingEnabled = YES;
    self.scrollWholeView.scrollEnabled = NO;
    self.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.scrollWholeView.contentOffset = CGPointMake(0, SCREEN_HEIGHT-50);
            [self.pictureInfContr viewWillAppear:YES];
        } completion:^(BOOL finished) {
            [self.scrollView.mj_footer endRefreshing];
        }];
    }];
    self.scrollV2.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.scrollWholeView.contentOffset = CGPointMake(0, 0);
        } completion:^(BOOL finished) {
            [self.scrollV2.mj_header endRefreshing];
        }];
    }];

    

    self.title=@"商品详情";
    
    [self initData];

}

-(NSMutableArray *)imageArray
{
    if (!_imageArray) {
        self.imageArray=[NSMutableArray array];
    }
    return _imageArray;
}

#pragma mark - Data & UI
//数据
-(void)initData{
    [self getGoodsDetailInfoFromNetwork];
    [self getStoreDetailInfoFromNetwork];
}
//加图片
-(void)setScrollImage
{
    [self.imageArray removeAllObjects];
    for(NSDictionary *imgModal in self.goodInfoReturn.Data.Imgs)
    {
        NSLog(@"%@",[imgModal objectForKey:@"Url"]);
        [self.imageArray addObject:[imgModal objectForKey:@"Url"]];
    }
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:self.pictureScrollView.frame delegate:self placeholderImage:[UIImage imageNamed:@"shangchuanzhaopian_mg_zuoqian"]];
    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    cycleScrollView.currentPageDotColor = [UIColor whiteColor];
    cycleScrollView.imageURLStringsGroup = self.imageArray;
    [self.pictureScrollView addSubview:cycleScrollView];
    //图文详情添加数据
    self.pictureInfContr.imageArray=self.imageArray;

}
//更新商品基本数据
-(void)updateGoodsBasicInfoUI{
    [self setScrollImage];
    self.titleLabel.text=self.goodInfoReturn.Data.Name;
    self.price.text=[NSString stringWithFormat:@"￥%.2f",self.goodInfoReturn.Data.Price];
}

//更新配件商数据
-(void)updateStoreInfoUI{
    self.headPicture.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:storeInfoReturn.Data.Url]]];
    self.shopName.text=storeInfoReturn.Data.Name;
    //星级评价占位
    //全部宝贝数占位
    //关注人数占位
    
    
    
}

#pragma mark - Networking
/**
 *  @author oyj, 16-04-09
 *
 *  获取商品详情
 */

-(void)getGoodsDetailInfoFromNetwork
{
    
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"UsrStore.asmx/GetPartsDetail"];
    
    NSDictionary *paramDict = @{
                                @"id":self.goodID,
                                
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
                                          self.goodInfoReturn=[GoodInfoReturn mj_objectWithKeyValues:jsonDic];
                                          if (self.goodInfoReturn.Success) {
                                              UsrStoreId=self.goodInfoReturn.Data.UsrStoreId;
                                              [self updateGoodsBasicInfoUI];
                                              [self segmentValueChange:self.detailVC.segmentControl];
                                              self.contr.goodInfo=self.goodInfoReturn.Data;
                                              [SVProgressHUD dismiss];
                                              
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
 *  @author oyj, 16-04-09
 *
 *  获取配件商信息
 */

-(void)getStoreDetailInfoFromNetwork
{
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"auth.asmx/StoreByMobile"];
    
    NSDictionary *paramDict = @{
                                @"mobile":self.storeMobile,
                                
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
                                          storeInfoReturn=[StoreReturnData mj_objectWithKeyValues:jsonDic];
                                          if (storeInfoReturn.Success) {
                                              [self updateStoreInfoUI];
                                              [SVProgressHUD dismiss];
                                              
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
 *  @author oyj, 16-04-15
 *
 *  加入购物车
 */


-(void)addCartToNetwork
{
    [SVProgressHUD showWithStatus:k_Status_Load];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,@"Usr.asmx/AddCart"];
    AppDelegate * delegate=((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    NSDictionary *cartJson =@{
                              @"Cnt":@"1",
                              @"UsrId":ApplicationDelegate.userInfo.user_Id,
                              @"PartsId":self.goodID,
                              @"Id":[MJYUtils mjy_uuid],

                              
                              
                              };
    NSError *error;
    NSData *partsLstJsonArrayData = [NSJSONSerialization dataWithJSONObject:cartJson options:NSJSONWritingPrettyPrinted error:&error];
    NSString *partsLstJsonArrayDataJsonString = [[NSString alloc] initWithData:partsLstJsonArrayData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",partsLstJsonArrayDataJsonString);
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
                                          storeInfoReturn=[StoreReturnData mj_objectWithKeyValues:jsonDic];
                                          if (storeInfoReturn.Success) {
                                              
//                                              [SVProgressHUD dismiss];
                                              [SVProgressHUD showSuccessWithStatus:@"加入成功"];
                                              
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
#pragma mark - 进店逛逛
- (IBAction)gotoShopAction:(id)sender {
    UIStoryboard *CheckClassify = [UIStoryboard storyboardWithName:@"CheckClassify" bundle:nil];
    PartsListContr *contr = (PartsListContr*)[CheckClassify instantiateViewControllerWithIdentifier:@"PartsListContr"];
    contr.UsrStoreId=UsrStoreId;
    contr.state=0;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:contr animated:YES];
   
}
#pragma mark - 查看分类
- (IBAction)CheckClassifyAction:(id)sender {
    
    UIStoryboard *CheckClassify = [UIStoryboard storyboardWithName:@"CheckClassify" bundle:nil];
    CheckClassifyViewController *contr = (CheckClassifyViewController*)[CheckClassify instantiateViewControllerWithIdentifier:@"CheckClassifyViewController"];
    contr.StoreId=UsrStoreId;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:contr animated:YES];
}
#pragma mark - 加入购物车
- (IBAction)addCartAction:(id)sender {
    [self addCartToNetwork];
}
#pragma mark - 立即购买
- (IBAction)buyNowAction:(id)sender {
//    [self.navigationController pushViewController:self.contr animated:YES];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:self.contr];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}
#pragma mark - 商品详情 信息切换

- (IBAction)segmentValueChange:(UISegmentedControl*)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            float height=self.imageArray.count*260+100;
            self.detailVC.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, height);
            self.scrollV2.contentSize=CGSizeMake(SCREEN_WIDTH, height);

            [self.goodsDescriptionViewContr.view removeFromSuperview];
            [self.goodsEvaluateContr.view removeFromSuperview];
            [self.detailVC.scrollView addSubview:self.pictureInfContr.view];
            
        }
            break;
        case 1:
        {
            self.detailVC.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            self.scrollV2.contentSize=CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.pictureInfContr.view removeFromSuperview];
            [self.goodsEvaluateContr.view removeFromSuperview];
            self.goodsDescriptionViewContr.name.text=self.goodInfoReturn.Data.Name;
            self.goodsDescriptionViewContr.style.text=self.goodInfoReturn.Data.TypeName;
            self.goodsDescriptionViewContr.kind.text=self.goodInfoReturn.Data.UseForName;
            self.goodsDescriptionViewContr.color.text=self.goodInfoReturn.Data.PurityName;
            self.goodsDescriptionViewContr.origin.text=self.goodInfoReturn.Data.PartsSrcName;
            self.goodsDescriptionViewContr.descriptionLabel.text=self.goodInfoReturn.Data.Description;
            [self.detailVC.scrollView addSubview:self.goodsDescriptionViewContr.view];
            
            
        }
            break;
        case 2:
        {
            self.detailVC.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            self.scrollV2.contentSize=CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.pictureInfContr.view removeFromSuperview];
            [self.goodsDescriptionViewContr.view removeFromSuperview];
            [self.detailVC.scrollView addSubview:self.goodsEvaluateContr.view];
            
        }
            break;
            
        default:
            break;
    }
    
    
}
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//    if (scrollView.tag == kInnerScrollViewTag) {
//        [scrollView resignFirstResponder];
//    }
//}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (scrollView.tag == 2) {
//        NSLog(@"%f,%f",scrollView.contentOffset.y,SCREEN_HEIGHT-50);
//        if (scrollView.contentOffset.y>0) {
//            [scrollView resignFirstResponder];
//            [self.pictureInfContr.scrollView becomeFirstResponder];
//        }
//        
//    }
//}
//-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//    if (scrollView.tag == 3) {//当前图文详情scrollview滚动到顶
//        [scrollView resignFirstResponder];
//        [self.scrollV2 becomeFirstResponder];
//    }
//}

@end

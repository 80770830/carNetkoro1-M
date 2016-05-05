//
//  OrderModel.m
//  CLWsdht
//
//  Created by koroysta1 on 16/4/12.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import "OrderModel.h"
#import "GoodModel.h"

@implementation OrderModel

- (NSMutableArray *)assignModelWithDict: (NSDictionary *) dataDict{
    NSDictionary *dic1 = [[NSDictionary alloc] init];
    dic1 = [dataDict objectForKey:@"Data"];
    NSArray *arr1 = [[NSArray alloc] init];
    arr1 = [dic1 objectForKey:@"Data"];
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dic2 in arr1) {
        OrderModel *orderModel = [[OrderModel alloc] init];
        orderModel.StoreImg = [dic2 objectForKey:@"StoreImg"];
        orderModel.StoreUrl = [dic2 objectForKey:@"StoreUrl"];
        orderModel.Price = [dic2 objectForKey:@"Price"];
        orderModel.Id = [dic2 objectForKey:@"Id"];
        orderModel.StoreName = [dic2 objectForKey:@"StoreName"];
        orderModel.PartsMobile = [dic2 objectForKey:@"PartsMobile"];
        orderModel.StoreId = [dic2 objectForKey:@"StoreId"];
        orderModel.PartsList = [dic2 objectForKey:@"PartsLst"];
        orderModel.State = [dic2 objectForKey:@"State"];
        orderModel.GarageState = [dic2 objectForKey:@"GarageState"];
        NSMutableArray *subarr = [[NSMutableArray alloc]init];
        /*这个for循环把当前这个订单的商品装到subarr里，最后赋值给	ListModel.PartsList*/
        for (NSDictionary *dic3 in orderModel.PartsList){
            GoodModel *goodModel = [[GoodModel alloc] init];
            goodModel.Cnt=[dic3 objectForKey:@"Cnt"];
            goodModel.Url=[dic3 objectForKey:@"Url"];
            goodModel.Name = [dic3 objectForKey:@"Name"];
            goodModel.Id = [dic3 objectForKey:@"Id"];
            goodModel.Img = [dic3 objectForKey:@"Img"];
            goodModel.StoreId = [dic3 objectForKey:@"StoreId"];
            goodModel.StoreName = [dic3 objectForKey:@"StoreName"];
            goodModel.PartsId = [dic3 objectForKey:@"PartsId"];
            goodModel.Price = [dic3 objectForKey:@"Price"];
            goodModel.CurrentPrice = [dic3 objectForKey:@"CurrentPrice"];
            [subarr addObject:goodModel];
        }
        orderModel.PartsList=subarr;
        /*这里把ListModel装到最后要返回的数组mutableArr*/
        [mutableArr addObject:orderModel];        
    }
    
    return mutableArr;
}
@end

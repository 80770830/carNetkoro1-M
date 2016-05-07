//
//  GarageListCell.h
//  CLWsdht
//
//  Created by OYJ on 16/5/5.
//  Copyright © 2016年 时代宏图. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GarageListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *repairFactoryName;
@property (weak, nonatomic) IBOutlet UILabel *repairFactoryDes;
@property (weak, nonatomic) IBOutlet UILabel *StateDes;
@property (weak, nonatomic) IBOutlet UILabel *Province;
@property (weak, nonatomic) IBOutlet UILabel *City;

@end

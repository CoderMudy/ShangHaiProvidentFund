//
//  CDNetWorkPointCell.h
//  ShangHaiProvidentFund
//
//  Created by Cheng on 16/5/7.
//  Copyright © 2016年 cheng dong. All rights reserved.
//

#import "CDBaseTableViewCell.h"

@class CDNetworkPointItem;

@interface CDNetWorkPointCell : CDBaseTableViewCell

+ (instancetype)netWorkPointCell;

- (void)setupCellItem:(CDNetworkPointItem *)item;

@end

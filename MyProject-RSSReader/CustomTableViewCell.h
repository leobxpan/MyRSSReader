//
//  CustomTableViewCell.h
//  MyProject-RSSReader
//
//  Created by Caesar on 15/3/5.
//  Copyright (c) 2015年 Caesar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>

@interface CustomTableViewCell : SWTableViewCell

@property (weak, nonatomic) UILabel *customLabel;
@property (weak, nonatomic) UIImageView *customImageView;

@end

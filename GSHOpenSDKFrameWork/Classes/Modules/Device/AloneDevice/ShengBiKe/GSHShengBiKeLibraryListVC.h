//
//  GSHShengBiKeLibraryListVC.h
//  SmartHome
//
//  Created by gemdale on 2019/12/13.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JdPlaySdk/JdPlaySdk.h>

@interface GSHShengBiKeSongListVCCell : UITableViewCell

@end

@interface GSHShengBiKeLibraryListVCCell : UITableViewCell

@end

@interface GSHShengBiKeLibraryListVC : UIViewController
+(instancetype)shengBiKeLibraryListVCWithDevice:(GSHDeviceM*)device jdCategoryModel:(JdCategoryModel*)model;
- (void)playWithCell:(GSHShengBiKeSongListVCCell*)cell;
- (void)addWithCell:(GSHShengBiKeSongListVCCell*)cell;
@end


//
//  GSHHomeRoomVC.h
//  SmartHome
//
//  Created by gemdale on 2018/11/1.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZMRefreshView.h"

@interface GSHHomeRoomVCErrorCell : UICollectionViewCell
@end

@interface GSHHomeRoomVCDeviceCell : UICollectionViewCell
@end

@interface GSHHomeRoomVCAddDeviceCell1 : UICollectionViewCell
@end

@interface GSHHomeRoomVCAddDeviceCell2 : UICollectionViewCell
@end

@interface GSHHomeRoomVCBannerCell : UICollectionViewCell
@end

@interface GSHHomeRoomVC : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
+(instancetype)homeRoomVCWithFamilyId:(NSString*)familyId room:(GSHRoomM*)room floor:(GSHFloorM*)floor;
-(void)refreshYingShiDeviceOnlineStatus;
-(void)refreshAdList:(NSArray<GSHBannerM*>*)adList;
@end

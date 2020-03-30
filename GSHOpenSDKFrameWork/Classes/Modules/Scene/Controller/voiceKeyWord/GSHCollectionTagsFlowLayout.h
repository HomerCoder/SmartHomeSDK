//
//  GSHCollectionTagsFlowLayout.h
//  SmartHome
//
//  Created by zhanghong on 2018/5/25.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TagsType){
    TagsTypeWithLeft,
    TagsTypeWithCenter,
    TagsTypeWithRight
};

@interface GSHCollectionTagsFlowLayout : UICollectionViewFlowLayout

//两个Cell之间的距离
@property (nonatomic,assign) CGFloat betweenOfCell;
//cell对齐方式
@property (nonatomic,assign) TagsType cellType;

- (instancetype)initWthType:(TagsType)cellType;

@end

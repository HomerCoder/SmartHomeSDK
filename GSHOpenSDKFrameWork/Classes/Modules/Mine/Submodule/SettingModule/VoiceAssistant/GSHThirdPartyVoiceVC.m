//
//  GSHThirdPartyVoiceVC.m
//  SmartHome
//
//  Created by gemdale on 2019/11/20.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHThirdPartyVoiceVC.h"
#import "GSHWebViewController.h"

@interface GSHThirdPartyVoiceVCCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lable;
@end

@implementation GSHThirdPartyVoiceVCCell
@end

@interface GSHThirdPartyVoiceVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *list;
@end

@implementation GSHThirdPartyVoiceVC

+(instancetype)thirdPartyVoiceVC{
    GSHThirdPartyVoiceVC *vc = [GSHPageManager viewControllerWithSB:@"VoiceAssistantSB" andID:@"GSHThirdPartyVoiceVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [TZMProgressHUDManager showWithStatus:@"获取信息中" inView:self.view];
    __weak typeof(self)weakSelf = self;
    [GSHRequestManager getWithPath:@"general/getVoiceDeviceList" parameters:nil block:^(id responseObjec, NSError *error) {
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if ([responseObjec isKindOfClass:NSDictionary.class]) {
                NSArray *list = [(NSDictionary*)responseObjec objectForKey:@"list"];
                if ([list isKindOfClass:NSArray.class]) {
                    weakSelf.list = list;
                    [weakSelf.collectionView reloadData];
                }
            }
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.list.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GSHThirdPartyVoiceVCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (self.list.count > indexPath.row) {
        NSDictionary *dic = self.list[indexPath.row];
        if ([dic isKindOfClass:NSDictionary.class]) {
            cell.lable.text = [dic stringValueForKey:@"title" default:nil];
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[dic stringValueForKey:@"picUrl" default:@""]]];
        }
    }
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((collectionView.width - 47) / 2, 200);
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.list.count > indexPath.row) {
        NSDictionary *dic = self.list[indexPath.row];
        if ([dic isKindOfClass:NSDictionary.class]) {
            NSString *content = [dic stringValueForKey:@"content" default:nil];
            if (content && [content rangeOfString:@"http"].location != NSNotFound) {
                GSHWebViewController *vc = [[GSHWebViewController alloc] initWithURL:[NSURL URLWithString:content]];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    return NO;
}

@end

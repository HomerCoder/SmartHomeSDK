//
//  GSHFamilyMemberListVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/21.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHFamilyMemberListVC.h"
#import "GSHQRCodeScanningVC.h"
#import "GSHFamilyMemberInfoVC.h"
#import "UIViewController+TZMPageStatusViewEx.h"
#import "UIImageView+WebCache.h"

@interface GSHFamilyMemberListCell()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewHead;
@end

@implementation GSHFamilyMemberListCell
-(void)setMember:(GSHFamilyMemberM *)member{
    _member = member;
    [self.imageViewHead sd_setImageWithURL:[NSURL URLWithString:member.childUserPicPath] placeholderImage:[UIImage ZHImageNamed:@"app_headImage_default_icon"]];
    self.lblName.text = member.childUserName;
}
@end

@interface GSHFamilyMemberListVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)GSHFamilyM *family;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)touchRightNavBut:(UIButton *)sender;
@end

@implementation GSHFamilyMemberListVC

+(instancetype)familyMemberListVCWithFamily:(GSHFamilyM*)family;{
    GSHFamilyMemberListVC *vc = [GSHPageManager viewControllerWithSB:@"GSHMemberManagerSB" andID:@"GSHFamilyMemberListVC"];
    vc.family = family;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
}

-(void)dealloc{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.family.members.count > 0) {
        [self dismissPageStatusView];
    }
    [self.collectionView reloadData];
}

- (void)reloadData{
    __weak typeof(self) weakSelf = self;
    [TZMProgressHUDManager showWithStatus:@"加载中" inView:self.view];
    [GSHFamilyMemberManager getFamilyMemberListWithFamilyId:self.family.familyId block:^(NSArray<GSHFamilyMemberM *> *list, NSError *error) {
        [weakSelf dismissPageStatusView];
        if (error) {
            [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:weakSelf.view];
        }else{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            if (list.count == 0) {
                TZMPageStatusView *statusView = [weakSelf showPageStatus:TZMPageStatusNormal
                               image:[UIImage ZHImageNamed:@"familyMemberListVC_nodata_icon"]
                               title:@"暂无成员"
                                desc:nil
                          buttonText:nil
              didClickButtonCallback:nil];
                statusView.backgroundColor = [UIColor whiteColor];
            }
            weakSelf.family.members = [NSMutableArray arrayWithArray:list];
            [weakSelf.collectionView reloadData];
        }
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.family.members.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (collectionView.frame.size.width - 30 - 15) / 2;
    return CGSizeMake(width, width / 165 * 90);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GSHFamilyMemberListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.family.members.count) {
        cell.member = self.family.members[indexPath.row];
    }
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.family.members.count) {
        GSHFamilyMemberInfoVC *vc = [GSHFamilyMemberInfoVC familyMemberInfoVCWithFamily:self.family member:self.family.members[indexPath.row] creation:NO];
        [self.navigationController pushViewController:vc animated:YES];
    }
    return NO;
}

- (IBAction)touchRightNavBut:(UIButton *)sender {
    __weak typeof(self)weakSelf = self;
    UINavigationController *nav = [GSHQRCodeScanningVC qrCodeScanningNavWithText:@"将成员二维码放入框内，即可扫描" title:@"添加成员" block:^BOOL(NSString *code, GSHQRCodeScanningVC *vc) {
        NSString *jsonString = [NSString stringWithBase64EncodedString:code];
        GSHFamilyMemberM *member = [GSHFamilyMemberM yy_modelWithJSON:jsonString];
        if (member) {
            GSHFamilyMemberInfoVC *vc = [GSHFamilyMemberInfoVC familyMemberInfoVCWithFamily:weakSelf.family member:member creation:YES];
            [weakSelf.navigationController pushViewController:vc animated:NO];
            [weakSelf dismissViewControllerAnimated:NO completion:NULL];
            return NO;
        }
        return YES;
    }];
    [self presentViewController:nav animated:YES completion:NULL];
}
@end

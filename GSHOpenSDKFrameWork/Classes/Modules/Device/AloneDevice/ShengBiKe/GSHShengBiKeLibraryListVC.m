//
//  GSHShengBiKeLibraryListVC.m
//  SmartHome
//
//  Created by gemdale on 2019/12/13.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHShengBiKeLibraryListVC.h"
#import <JdPlaySdk/JdPlaySdk.h>
#import <UIScrollView+TZMRefreshAndLoadMore.h>
#import <UIViewController+TZMPageStatusViewEx.h>
#import "TZMProgressHUDManager.h"
#import <Lottie/LOTAnimationView.h>

@interface GSHShengBiKeSongListVCCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblSongName;
@property (weak, nonatomic) IBOutlet UILabel *lblSongerName;
@property (weak, nonatomic) IBOutlet LOTAnimationView *playView;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
- (IBAction)touchPlay:(UIButton *)sender;
- (IBAction)touchAdd:(UIButton *)sender;
@end

@implementation GSHShengBiKeSongListVCCell
- (IBAction)touchPlay:(UIButton *)sender {
    if ([self.viewController isKindOfClass:GSHShengBiKeLibraryListVC.class]) {
        [((GSHShengBiKeLibraryListVC*)self.viewController) playWithCell:self];
    }
}

- (IBAction)touchAdd:(UIButton *)sender {
    if ([self.viewController isKindOfClass:GSHShengBiKeLibraryListVC.class]) {
        [((GSHShengBiKeLibraryListVC*)self.viewController) addWithCell:self];
    }
}
@end

@interface GSHShengBiKeLibraryListVCCell()
@property (weak, nonatomic) IBOutlet UIImageView *libImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end

@implementation GSHShengBiKeLibraryListVCCell
@end

@interface GSHShengBiKeLibraryListVC ()<UITableViewDelegate,UITableViewDataSource,MusicResourceView>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)back:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *topView;
- (IBAction)playAll:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcTopHeight;
@property (nonatomic,strong) GSHDeviceM *deviceM;
@property (nonatomic,strong) JdCategoryModel * model;
@property (nonatomic,strong) JdMusicResourcePresenter *jdMusicResourcePresenter;
@property (nonatomic,strong) JdPlayControlPresenter *jdPlayControlPresenter;
@property (nonatomic,strong) JdShareClass *jdShareClass;
@property (nonatomic,strong) NSString *songId;
@property (nonatomic,strong) NSMutableArray *list;
@property (nonatomic,assign) BOOL isLastLevel;
@end

@implementation GSHShengBiKeLibraryListVC
+(instancetype)shengBiKeLibraryListVCWithDevice:(GSHDeviceM*)device jdCategoryModel:(JdCategoryModel*)model{
    GSHShengBiKeLibraryListVC *vc = [GSHPageManager viewControllerWithSB:@"ShengBiKeSB" andID:@"GSHShengBiKeLibraryListVC"];
    vc.deviceM = device;
    vc.model = model;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.list = [NSMutableArray array];
    self.jdMusicResourcePresenter = [[JdMusicResourcePresenter alloc] initWithDelegate:self];
    self.jdPlayControlPresenter = [JdPlayControlPresenter sharedManager];
    self.jdShareClass = [JdShareClass sharedInstance];
    self.songId = self.jdShareClass.currentPlaySongId;
    [TZMProgressHUDManager showWithStatus:@"加载数据中" inView:self.view];
    [self.jdMusicResourcePresenter getMusicResource:self.model];
}

-(void)dealloc{
    
}

- (void)playWithCell:(GSHShengBiKeSongListVCCell*)cell{
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    if (self.list.count > index.row && [self.list[index.row] isKindOfClass:EglSong.class]) {
        EglSong *song = self.list[index.row];
        [self.jdMusicResourcePresenter playWithEglSongs:self.list pos:(int)(index.row)];
        self.songId = song.songId;
        [self.tableView reloadData];
    }
}

- (void)addWithCell:(GSHShengBiKeSongListVCCell*)cell{
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    if (self.list.count > index.row) {
        EglSong *song = self.list[index.row];
        if ([song isKindOfClass:EglSong.class]) {
            @synchronized (self.jdShareClass.playListModel.songsArr) {
                for (JdSongsModel *model in self.jdShareClass.playListModel.songsArr) {
                    if ([model isKindOfClass:JdSongsModel.class]) {
                        if (song.songId && [model.song_id isEqualToString:song.songId]) {
                            [TZMProgressHUDManager showErrorWithStatus:@"歌曲已经在播放列表中" inView:self.view];
                            return;
                        }
                    }
                }
            }
            
            [self.jdPlayControlPresenter addSongToNextPlay:song];
            [TZMProgressHUDManager showSuccessWithStatus:@"已添加至下一首播放" inView:self.view];
        }
    }
}

- (void)onGetMusicResourceFail:(int)erroCode errMsg:(NSString *)errMsg{
    if (self.list.count == 0) {
        __weak typeof(self)weakSelf = self;
        dispatch_async_on_main_queue(^{
            [TZMProgressHUDManager dismissInView:weakSelf.view];
            [weakSelf showPageStatus:TZMPageStatusNormal image:[UIImage ZHImageNamed:@"blankpage_icon_equipment"] title:errMsg desc:nil buttonText:@"重新获取" didClickButtonCallback:^(TZMPageStatus status) {
                [TZMProgressHUDManager showWithStatus:@"加载数据中" inView:weakSelf.view];
                [weakSelf.jdMusicResourcePresenter getMusicResource:weakSelf.model];
            }];
        });
    }
}

- (void)setMusicResource:(NSMutableArray *)infos isLast:(BOOL)last loadMore:(BOOL)loadMore{
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        [TZMProgressHUDManager dismissInView:weakSelf.view];
        [weakSelf.tableView.tzm_loadMoreControl endRefreshing];
        [weakSelf.list addObjectsFromArray:infos];
        [weakSelf.tableView reloadData];
        weakSelf.tableView.tzm_loadMoreControl.enabled = loadMore;
        weakSelf.isLastLevel = last;
        if (weakSelf.isLastLevel) {
            weakSelf.topView.hidden = NO;
            weakSelf.lcTopHeight.constant = 50;
            weakSelf.tableView.tableHeaderView = nil;
        }else{
            weakSelf.topView.hidden = YES;
            weakSelf.lcTopHeight.constant = 0;
        }
    });
}

- (void)tzm_scrollViewLoadMore:(UIScrollView *)scrollView LoadMoreControl:(TZMLoadMoreRefreshControl *)loadMoreControl{
    [self.jdMusicResourcePresenter getMusicResourceMore];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.list.count) {
        id obj = self.list[indexPath.row];
        if ([obj isKindOfClass:JdCategoryModel.class]) {
            GSHShengBiKeLibraryListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
            JdCategoryModel *model = obj;
            [cell.libImageView sd_setImageWithURL:[NSURL URLWithString:model.imagePath] placeholderImage:[UIImage ZHImageNamed:@"shengBiKeSongListVC_library"]];
            cell.lblName.text = model.name;
            return cell;
        }
        
        if ([obj isKindOfClass:EglSong.class]) {
            GSHShengBiKeSongListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
            EglSong *model = obj;;
            cell.lblSongName.text = model.Name;
            cell.lblSongerName.text = model.Name;
            if (model.songId && [self.songId isEqualToString:model.songId]) {
                cell.playView.hidden = NO;
                cell.btnPlay.hidden = YES;
                cell.lblSongName.textColor = [UIColor colorWithRGB:0x2EB0FF];
                cell.lblSongerName.textColor = [UIColor colorWithRGB:0x2EB0FF];
                [cell.playView setAnimation:@"shengbike_paly"];
                cell.playView.loopAnimation = YES;
                [cell.playView playFromProgress:0 toProgress:1 withCompletion:^(BOOL animationFinished) {
                }];
            }else{
                cell.playView.hidden = YES;
                [cell.playView stop];
                cell.btnPlay.hidden = NO;
                cell.lblSongName.textColor = [UIColor colorWithRGB:0x222222];
                cell.lblSongerName.textColor = [UIColor colorWithRGB:0x999999];
            }
            return cell;
        }
    }
    return [UITableViewCell new];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.row < self.list.count) {
        id obj = self.list[indexPath.row];
        if ([obj isKindOfClass:JdCategoryModel.class]) {
            JdCategoryModel *model = obj;
            GSHShengBiKeLibraryListVC *vc = [GSHShengBiKeLibraryListVC shengBiKeLibraryListVCWithDevice:self.deviceM jdCategoryModel:model];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    return NO;
}

- (IBAction)back:(UIButton *)sender {
    if (self.navigationController.viewControllers.firstObject && self == self.navigationController.viewControllers.firstObject) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)playAll:(UIButton *)sender {
    if (self.list.count > 0 && [self.list.firstObject isKindOfClass:EglSong.class]) {
        [self.jdMusicResourcePresenter playWithEglSongs:self.list pos:0];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}
@end

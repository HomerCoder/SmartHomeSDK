//
//  GSHShengBiKePlayVC.m
//  SmartHome
//
//  Created by gemdale on 2019/12/12.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHShengBiKePlayVC.h"
#import "GSHShengBiKeLibraryListVC.h"
#import "JKCircleView.h"
#import <JdPlaySdk/JdPlaySdk.h>
#import "GSHShengBiKeAddVC.h"
#import <Lottie/LOTAnimationView.h>

@interface GSHShengBiKePlayVCCell()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSanger;
@property (weak, nonatomic) IBOutlet LOTAnimationView *playerImage;
- (IBAction)touchDelete:(UIButton *)sender;
@end

@implementation GSHShengBiKePlayVCCell
- (IBAction)touchDelete:(UIButton *)sender {
    [self.viewController isKindOfClass:GSHShengBiKePlayVC.class];
    [((GSHShengBiKePlayVC*)self.viewController) deleteSongWithCell:self];
}
@end

@interface GSHShengBiKePlayVC ()<UITableViewDelegate,UITableViewDataSource,DeviceListView,PlayCtrlView,PlayCtrlDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *listXunHuangImageView;
@property (weak, nonatomic) IBOutlet UILabel *listTitle;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UIView *listNodata;
@property (weak, nonatomic) IBOutlet UIView *viewList;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *musicBgImageView;
@property (weak, nonatomic) IBOutlet UIView *musicBgView;
@property (weak, nonatomic) IBOutlet UILabel *lblPlayTime;
@property (weak, nonatomic) IBOutlet UILabel *lblAllTime;
@property (weak, nonatomic) IBOutlet UILabel *lblMusicName;
@property (weak, nonatomic) IBOutlet UILabel *lblMusicRinger;
@property (weak, nonatomic) IBOutlet UISlider *yingLiangSlider;
@property (weak, nonatomic) IBOutlet UIButton *btnXunHuan;
@property (weak, nonatomic) IBOutlet UIButton *btnPaly;
@property (weak, nonatomic) IBOutlet UIView *nodata;
@property (weak, nonatomic) IBOutlet UIView *nowifi;
@property (weak, nonatomic) IBOutlet UIView *viewLiXian;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet UIButton *btnKu;

- (IBAction)yingLiangChange:(UISlider *)sender;
- (IBAction)touchSetting:(UIButton *)sender;
- (IBAction)touchQuZiYuanKu:(UIButton *)sender;
- (IBAction)listBack:(UIButton *)sender;
- (IBAction)liXianBack:(UIButton *)sender;
- (IBAction)touchXunHuan:(UIButton *)sender;
- (IBAction)touchShangYiQu:(UIButton *)sender;
- (IBAction)touchPlay:(UIButton *)sender;
- (IBAction)touchXiaYiQu:(UIButton *)sender;
- (IBAction)touchList:(UIButton *)sender;
- (IBAction)touchLixian:(UIButton *)sender;

@property (nonatomic,strong) JKCircleView *circleView;
@property (nonatomic,strong) CABasicAnimation *rotationAnimation;

@property (nonatomic,strong)JdShareClass *jdShareClass;
@property (nonatomic,strong)JdDeviceListPresenter *jdDeviceListPresenter;
@property (nonatomic,strong)JdPlayControlPresenter *jdPlayControlPresenter;
@property (nonatomic,strong)JdDeviceInfo *seleDeviceInfo;

@property (nonatomic,strong)NSMutableArray *jdPlayList;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wprotocol"
@implementation GSHShengBiKePlayVC
#pragma clang diagnostic pop

-(void)deleteSongWithCell:(GSHShengBiKePlayVCCell *)cell{
    NSIndexPath *index = [self.listTableView indexPathForCell:cell];
    if (self.jdPlayList.count > index.row) {
        [self.jdPlayList removeObjectAtIndex:index.row];
        [self.jdPlayControlPresenter deletePlayListByPos:(int)(index.row)];
        [self.listTableView reloadData];
        [self refreshListTitle];
        self.listNodata.hidden = self.jdPlayList.count > 0;
        self.nodata.hidden = self.jdPlayList.count > 0;
    }
}

+(instancetype)shengBiKePlayVCWithDevice:(GSHDeviceM*)device{
    GSHShengBiKePlayVC *vc = [GSHPageManager viewControllerWithSB:@"ShengBiKeSB" andID:@"GSHShengBiKePlayVC"];
    vc.deviceM = device;
    vc.deviceEditType = GSHDeviceVCTypeControl;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.yingLiangSlider setThumbImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_huaKuai"] forState:UIControlStateNormal];
    self.lblTitle.text = self.deviceM.deviceName;
    
    self.rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    self.rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    self.rotationAnimation.duration = 10;
    self.rotationAnimation.cumulative = YES;
    self.rotationAnimation.repeatCount = MAXFLOAT;
    
    self.jdShareClass = [JdShareClass sharedInstance];
    self.jdDeviceListPresenter = [JdDeviceListPresenter sharedManager];
    self.jdDeviceListPresenter.delegate = self;
    self.jdPlayControlPresenter = [JdPlayControlPresenter sharedManager];
    self.jdPlayControlPresenter.delegate = self;
    self.jdPlayControlPresenter.ctrlDelgate = self;
    [self.jdPlayControlPresenter getPlayList];
    [self updateDeviceInfo:self.jdDeviceListPresenter.deviceListArr];
    
    self.circleView = [[JKCircleView alloc] initShengBiKeWithFrame:CGRectMake(0, 0, 200, 200) startAngle:90 endAngle:90.01];
    self.circleView.enableCustom = YES;
    [self.circleView setIsCanSlideTemperature:YES];
    __weak typeof(self)weakSelf = self;
    [self.circleView setProgressChange:^(NSString *result, BOOL isSendRequest) {
        if (isSendRequest) {
            [weakSelf.jdPlayControlPresenter seekTo:result.intValue * 1.0 / 100];
        }
    }];
    [self.musicBgView addSubview:self.circleView];
    self.btnSetting.hidden = [GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember;
}

-(void)refrshData{
    if (self.jdShareClass.songInfo) {
        self.lblMusicName.text = self.jdShareClass.songInfo.title;
        self.lblMusicRinger.text = self.jdShareClass.songInfo.creator;
        [self.musicBgImageView sd_setImageWithURL:[NSURL URLWithString:self.jdShareClass.songInfo.albumurl] placeholderImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_yuan_bg"]];
    }else{
        self.lblMusicName.text = @"未知歌曲";
        self.lblMusicRinger.text = @"未知来源";
        self.musicBgImageView.image = [UIImage ZHImageNamed:@"shengBiKePlayVC_yuan_bg"];
    }
    self.lblAllTime.text = [self FormatTime:self.jdShareClass.totalTime];
    self.lblPlayTime.text = [self FormatTime:self.jdShareClass.position];
    if (self.jdShareClass.totalTime > 0 && self.jdShareClass.totalTime > self.jdShareClass.position) {
        [self.circleView setProgressWithProgress:(self.jdShareClass.position * 1.0 / self.jdShareClass.totalTime) isSendRequest:NO];
    }
    
    self.yingLiangSlider.value = self.jdShareClass.volume / 100.0;
    //当前播放模式 0：顺序播放 1：单曲循环 2：随机播放
    switch (self.jdShareClass.playOrder) {
        case 0:
            self.listXunHuangImageView.image = [UIImage ZHImageNamed:@"shengBiKePlayVC_xunHuan"];
            [self.btnXunHuan setImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_xunHuan"] forState:UIControlStateNormal];
            break;
        case 1:
            [self.btnXunHuan setImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_danQuXunHuan"] forState:UIControlStateNormal];
            self.listXunHuangImageView.image = [UIImage ZHImageNamed:@"shengBiKePlayVC_danQuXunHuan"];
            break;
        default:
            [self.btnXunHuan setImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_shuiJiXunHuan"] forState:UIControlStateNormal];
            self.listXunHuangImageView.image = [UIImage ZHImageNamed:@"shengBiKePlayVC_shuiJiXunHuan"];
            break;
    }
    
    self.btnPaly.selected = self.jdShareClass.playState;
    if (self.jdShareClass.playState) {
        [self.btnPaly setImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_zanTing"] forState:UIControlStateNormal];
        [self.musicBgImageView.layer addAnimation:self.rotationAnimation forKey:@"rotationAnimation"];
    }else{
        [self.btnPaly setImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_boFang"] forState:UIControlStateNormal];
        [self.musicBgImageView.layer removeAnimationForKey:@"rotationAnimation"];
    }
}

- (NSString *)FormatTime:(int)timeMS{
    int tmp = (int) timeMS / 1000;
    int m = tmp / 60;
    int s = tmp % 60;
    return [NSString stringWithFormat:@"%02d : %02d",m,s];
}

-(void)dealloc{
    self.jdDeviceListPresenter.delegate = nil;
}

-(void)updateDeviceInfo:(NSArray *)infos{
    for (JdDeviceInfo *obj in infos) {
        if ([obj isKindOfClass:JdDeviceInfo.class]) {
            if (obj.uuid && [self.deviceM.deviceSn isEqualToString:obj.uuid]) {
//            if (obj.uuid && [@"10000024764" isEqualToString:obj.uuid]) {
                self.seleDeviceInfo = obj;
                if (![obj.uuid isEqualToString:self.jdShareClass.currentDeviceID]) {
                    [self.jdDeviceListPresenter selectDevice:obj];
                    self.deviceM.firmwareVersion = obj.softwareVersion.releaseV;
                }
                break;
            }
        }
    }
    if (self.seleDeviceInfo.onlineStatus == 0) {
        self.btnKu.enabled = NO;
        self.nowifi.hidden = NO;
    }else{
        self.nowifi.hidden = YES;
        self.btnKu.enabled = YES;
        [self refrshData];
    }
}

- (IBAction)yingLiangChange:(UISlider *)sender {
    [self.jdPlayControlPresenter changeVolume:sender.value * 100];
}

- (IBAction)touchSetting:(UIButton *)sender {
    GSHShengBiKeAddVC *vc = [GSHShengBiKeAddVC shengBiKeAddVCWithDevice:self.deviceM];
    vc.hidesBottomBarWhenPushed = YES;
    [self closeWithComplete:^{
        [[UIViewController visibleTopViewController].navigationController pushViewController:vc animated:YES];
    }];
}

- (IBAction)touchQuZiYuanKu:(UIButton *)sender {
    GSHShengBiKeLibraryListVC *vc = [GSHShengBiKeLibraryListVC shengBiKeLibraryListVCWithDevice:self.deviceM jdCategoryModel:nil];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [nav.navigationBar setBarStyle:UIBarStyleDefault];
    [self presentViewController:nav animated:YES completion:NULL];
}

- (IBAction)listBack:(UIButton *)sender {
    self.viewList.hidden = YES;
    [self hideTopView:NO];
}

- (IBAction)liXianBack:(UIButton *)sender {
    self.viewLiXian.hidden = YES;
}

- (IBAction)touchXunHuan:(UIButton *)sender {
    [self.jdPlayControlPresenter changePlayMode];
}

- (IBAction)touchShangYiQu:(UIButton *)sender {
    [self.jdPlayControlPresenter prev];
}

- (IBAction)touchPlay:(UIButton *)sender {
    [self.jdPlayControlPresenter togglePlay];
}

- (IBAction)touchXiaYiQu:(UIButton *)sender {
    [self.jdPlayControlPresenter next];
}

- (IBAction)touchList:(UIButton *)sender {
    [self.jdPlayControlPresenter getPlayList];
    self.viewList.hidden = NO;
    [self hideTopView:YES];
}

- (IBAction)touchLixian:(id)sender {
    self.viewLiXian.hidden = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.jdPlayList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GSHShengBiKePlayVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.jdPlayList.count) {
        JdSongsModel *model = self.jdPlayList[indexPath.row];
        if ([model isKindOfClass:JdSongsModel.class]) {
            cell.lblSanger.text = [NSString stringWithFormat:@"-%@",model.singers.length > 0 ? model.singers : @"未知歌手"];
            cell.lblName.text = model.song_name;
            if (model.song_id && [self.jdShareClass.songInfo.songID isEqualToString:model.song_id]) {
                cell.playerImage.hidden = NO;
                cell.lblName.textColor = [UIColor colorWithRGB:0x2EB0FF];
                cell.lblSanger.textColor = [UIColor colorWithRGB:0x2EB0FF];
                [cell.playerImage setAnimation:@"shengbike_paly"];
                cell.playerImage.loopAnimation = YES;
                [cell.playerImage playFromProgress:0 toProgress:1 withCompletion:^(BOOL animationFinished) {

                }];
            }else{
                cell.playerImage.hidden = YES;
                [cell.playerImage stop];
                cell.lblName.textColor = [UIColor colorWithRGB:0x222222];
                cell.lblSanger.textColor = [UIColor colorWithRGB:0x999999];
            }
        }
        
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.jdPlayList.count) {
        JdSongsModel *model = self.jdPlayList[indexPath.row];
        if ([model isKindOfClass:JdSongsModel.class]) {
            [self.jdPlayControlPresenter playPlaylistWithPos:(int)indexPath.row];
        }
    }
    return NO;
}

-(void)onJdDeviceInfoChange:(NSArray *)infos{
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        [weakSelf updateDeviceInfo:infos];
    });
}

-(void)setSongName:(NSString *)name{
    //歌名
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        if (!weakSelf.viewList.hidden) {
            [weakSelf.listTableView reloadData];
        }
        weakSelf.lblMusicName.text = name.length > 0 ? name : @"未知歌曲";
    });
}

-(void)setSingerName:(NSString *)name{
    //歌手名
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        weakSelf.lblMusicRinger.text = name.length > 0 ? name : @"未知来源";
    });
}

-(void)setAlbumPic:(NSString *)url{
    //专辑图片
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        if (url.length > 0) {
            [weakSelf.musicBgImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_yuan_bg"]];
        }else{
            weakSelf.musicBgImageView.image = [UIImage ZHImageNamed:@"shengBiKePlayVC_yuan_bg"];
        }
    });
}

-(void)setPosition:(int)position{
    //设置当前播放时间 position 时间，单位秒
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        weakSelf.lblPlayTime.text = [weakSelf FormatTime:weakSelf.jdShareClass.position];
        int totalTime = weakSelf.jdShareClass.totalTime;
        int position = weakSelf.jdShareClass.position;
        if (totalTime > 0 && totalTime > position) {
            [weakSelf.circleView setProgressWithProgress:(position * 1.0 / totalTime) isSendRequest:NO];
        }
    });

}

-(void)setDuration:(int)duration{
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        weakSelf.lblAllTime.text = [weakSelf FormatTime:weakSelf.jdShareClass.totalTime];
    });
}

-(void)setVolume:(int)percent{
    //设置音量百分比 percent 0-100 音量百分比
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        weakSelf.yingLiangSlider.value = weakSelf.jdShareClass.volume * 1.0 / 100.0;
    });

}

-(void)setPlayMode:(int)order{
    //播放模式 @param order 0：顺序播放 1：单曲循环 2：随机播放
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        switch (order) {
            case 0:
                weakSelf.listXunHuangImageView.image = [UIImage ZHImageNamed:@"shengBiKePlayVC_xunHuan"];
                [weakSelf.btnXunHuan setImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_xunHuan"] forState:UIControlStateNormal];
                break;
            case 1:
                [weakSelf.btnXunHuan setImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_danQuXunHuan"] forState:UIControlStateNormal];
                weakSelf.listXunHuangImageView.image = [UIImage ZHImageNamed:@"shengBiKePlayVC_danQuXunHuan"];
                break;
            default:
                [weakSelf.btnXunHuan setImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_shuiJiXunHuan"] forState:UIControlStateNormal];
                weakSelf.listXunHuangImageView.image = [UIImage ZHImageNamed:@"shengBiKePlayVC_shuiJiXunHuan"];
                break;
        }
    });

}

- (void)onCurrentPlayStatusChange:(BOOL)state {
    //播放状态
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        weakSelf.btnPaly.selected = weakSelf.jdShareClass.playState;
        if (weakSelf.jdShareClass.playState) {
            [weakSelf.btnPaly setImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_zanTing"] forState:UIControlStateNormal];
            [weakSelf.musicBgImageView.layer addAnimation:self.rotationAnimation forKey:@"rotationAnimation"];
        }else{
            [weakSelf.btnPaly setImage:[UIImage ZHImageNamed:@"shengBiKePlayVC_boFang"] forState:UIControlStateNormal];
            [weakSelf.musicBgImageView.layer removeAnimationForKey:@"rotationAnimation"];
        }
    });

}

-(void)setPlaylist:(NSArray *)songs{
    //播放列表
    __weak typeof(self)weakSelf = self;
    dispatch_async_on_main_queue(^{
        weakSelf.jdPlayList = [NSMutableArray arrayWithArray:songs];
        [weakSelf.listTableView reloadData];
        [weakSelf refreshListTitle];
        weakSelf.nodata.hidden = self.jdPlayList.count > 0;
        weakSelf.listNodata.hidden = self.jdPlayList.count > 0;
    });
}

-(void)refreshListTitle{
    switch (self.jdShareClass.playOrder) {
        case 0:
            self.listTitle.text = [NSString stringWithFormat:@"列表循环播放(%d)",(int)self.jdPlayList.count];
            break;
        case 1:
            self.listTitle.text = [NSString stringWithFormat:@"单曲循环播放(%d)",(int)self.jdPlayList.count];
            break;
        default:
            self.listTitle.text = [NSString stringWithFormat:@"随机播放(%d)",(int)self.jdPlayList.count];
            break;
    }
}

@end

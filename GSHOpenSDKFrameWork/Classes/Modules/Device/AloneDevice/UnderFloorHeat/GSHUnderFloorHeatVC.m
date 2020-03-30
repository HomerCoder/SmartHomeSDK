//
//  GSHUnderFloorHeatVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/10/19.
//  Copyright © 2018 gemdale. All rights reserved.
//

#import "GSHUnderFloorHeatVC.h"
#import "UINavigationController+TZM.h"
#import "TZMButton.h"
#import "GSHDeviceEditVC.h"
#import "NSObject+TZM.h"

@interface GSHUnderFloorHeatVC ()

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *underFloorHeatNameLabel;
@property (weak, nonatomic) IBOutlet UIView *temperatureView;

@property (weak, nonatomic) IBOutlet TZMButton *switchButton;
@property (weak, nonatomic) IBOutlet UIButton *rightNaviButton;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UIButton *switchBigButton;


@property (nonatomic,assign) __block int currentTemperatureValue;
@property (nonatomic,strong) NSMutableDictionary *meteIdDic;

@property (nonatomic,strong) NSArray *exts;
@property (nonatomic,assign) BOOL isDrawLine;

@end

@implementation GSHUnderFloorHeatVC

+ (instancetype)underFloorHeatHandleVCDeviceM:(GSHDeviceM *)deviceM deviceEditType:(GSHDeviceVCType)deviceEditType {
    GSHUnderFloorHeatVC *vc = [GSHPageManager viewControllerWithSB:@"GSHUnderFloorHeatSB" andID:@"GSHUnderFloorHeatVC"];
    vc.deviceEditType = deviceEditType;
    vc.deviceM = deviceM;
    vc.exts = deviceM.exts;
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tzm_prefersNavigationBarHidden = YES;
    
    NSString *rightNaviButtonTitle = self.deviceEditType == GSHDeviceVCTypeControl ? @"" : @"确定";
    NSString *buttonImageName = self.deviceEditType == GSHDeviceVCTypeControl ? @"device_set_btn" : @"";
    [self.rightNaviButton setTitle:rightNaviButtonTitle forState:UIControlStateNormal];
    [self.rightNaviButton setImage:[UIImage ZHImageNamed:buttonImageName] forState:UIControlStateNormal];
    self.rightNaviButton.hidden = ([GSHOpenSDKShare share].currentFamily.permissions == GSHFamilyMPermissionsMember && self.deviceEditType == GSHDeviceVCTypeControl);
    
    self.currentTemperatureValue = 16;
    
    [self getDeviceDetailInfo];
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        [self observerNotifications];
    }
    [self refreshUI];
}

-(void)observerNotifications {
    [self observerNotification:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification];
}

-(void)handleNotifications:(NSNotification *)notification {
    if ([notification.name isEqualToString:GSHChangeNetworkManagerWebSocketRealDataUpdateNotification]) {
        [self refreshUI];
    }
}

-(void)dealloc{
    [self removeNotifications];
}

#pragma mark - Lazy
- (NSMutableDictionary *)meteIdDic {
    if (!_meteIdDic) {
        _meteIdDic = [NSMutableDictionary dictionary];
    }
    return _meteIdDic;
}

#pragma mark - method
- (IBAction)enterDeviceButtonClick:(id)sender {
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        // 设备控制 -- 进入设备
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            [TZMProgressHUDManager showInfoWithStatus:@"离线环境无法查看" inView:self.view];
            return;
        }
        if (!self.deviceM) {
            [TZMProgressHUDManager showErrorWithStatus:@"设备数据出错" inView:self.view];
            return;
        }
        GSHDeviceEditVC *deviceEditVC = [GSHDeviceEditVC deviceEditVCWithDevice:self.deviceM type:GSHDeviceEditVCTypeEdit];
        @weakify(self)
        deviceEditVC.deviceEditSuccessBlock = ^(GSHDeviceM *deviceM) {
            @strongify(self)
            self.deviceM = deviceM;
            [self refreshUI];
        };
        [self closeWithComplete:^{
            [[UIViewController visibleTopViewController].navigationController pushViewController:deviceEditVC animated:YES];
        }];
    } else {
        // 确定
        NSMutableArray *exts = [NSMutableArray array];
        GSHDeviceExtM *extM = [[GSHDeviceExtM alloc] init];
        extM.basMeteId = GSHUnderFloor_SwitchMeteId;
        extM.conditionOperator = @"==";
        if (self.switchButton.selected) {
            // 关
            extM.rightValue = @"0";
            [exts addObject:extM];
        } else {
            // 开 v3.1.1 开的状态时只传温度的属性
            GSHDeviceExtM *temperatureExtM = [[GSHDeviceExtM alloc] init];
            temperatureExtM.basMeteId = GSHUnderFloor_TemperatureMeteId;
            temperatureExtM.conditionOperator = @"==";
            temperatureExtM.rightValue = [NSString stringWithFormat:@"%d",self.currentTemperatureValue];
            [exts addObject:temperatureExtM];
        }
        
        if (self.deviceSetCompleteBlock) {
            self.deviceSetCompleteBlock(exts);
        }
        [self closeWithComplete:^{
        }];
    }
}

- (IBAction)switchButtonClick:(UIButton *)button {
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        NSString *value;
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeLAN) {
            self.switchButton.selected = !self.switchButton.selected;
            value = self.switchButton.selected ? @"0" : @"10";
        } else {
            value = self.switchButton.selected ? @"10" : @"0";
        }
        @weakify(self)
        __weak typeof(self.switchButton) weakButton = self.switchButton;
        [self controlUnderFloorHeatWithBasMeteId:GSHUnderFloor_SwitchMeteId value:value failBlock:^(NSError *error) {

        } successBlock:^{
            @strongify(self)
            __strong typeof(weakButton) strongButton = weakButton;
            strongButton.selected = !strongButton.selected;
            [self refreshTemperatureView];
        }];
        
    } else {
        self.switchButton.selected = !self.switchButton.selected;
        [self refreshTemperatureView];
        if (self.switchButton.selected) {
            // 地暖 关
            self.switchButton.hidden = YES;
            self.switchBigButton.hidden = NO;
            self.controlView.hidden = YES;
        } else{
            // 地暖 开
            self.switchButton.hidden = NO;
            self.switchBigButton.hidden = YES;
            self.controlView.hidden = NO;
        }
    }
}

- (void)refreshTemperatureView {
    CGFloat viewWidth = self.temperatureView.frame.size.width;
    CGFloat viewHeight = self.temperatureView.frame.size.height;
    if (self.switchButton.selected) {
        // 关闭
        [self.temperatureView.layer addSublayer:[self drawLineWithEndPoint:CGPointMake(viewWidth/2.0, 0) lineColor:[UIColor colorWithHexString:@"#F8F9FC"]]];
    } else {
        // 开启
        CGFloat endPointY = viewHeight - (self.currentTemperatureValue - 16) / 16.0 * viewHeight;
        CGPoint endPoint = CGPointMake(viewWidth/2.0, endPointY);
        [self drawLineWithEndPoint:endPoint];
    }
}

#pragma mark - request
// 获取设备详细信息
- (void)getDeviceDetailInfo {
    @weakify(self)
    [GSHDeviceManager getDeviceInfoWithFamilyId:[GSHOpenSDKShare share].currentFamily.familyId deviceId:self.deviceM.deviceId.stringValue deviceSign:nil block:^(GSHDeviceM *device, NSError *error) {
        @strongify(self)
        if (!error) {
            self.deviceM = device;
            for (GSHDeviceAttributeM *attributeM in self.deviceM.attribute) {
                NSString *key = [NSString stringWithFormat:@"%@%@",attributeM.meteType,attributeM.meteIndex];
                [self.meteIdDic setObject:attributeM.basMeteId forKey:key];
            }
            if (self.exts.count > 0) {
                self.deviceM.exts = [self.exts mutableCopy];
            }
            [self refreshUI];
        }
    }];
}

// 设备控制
- (void)controlUnderFloorHeatWithBasMeteId:(NSString *)basMeteId
                                     value:(NSString *)value
                                 failBlock:(void(^)(NSError *error))failBlock
                              successBlock:(void(^)(void))successBlock {
    
    [GSHDeviceManager deviceControlWithDeviceId:self.deviceM.deviceId.stringValue
                                               deviceSN:self.deviceM.deviceSn
                                               familyId:[GSHOpenSDKShare share].currentFamily.familyId
                                              basMeteId:basMeteId
                                                  value:value
                                                  block:^(NSError *error) {
        if ([GSHWebSocketClient shared].networkType == GSHNetworkTypeWAN) {
            if (error) {
                [TZMProgressHUDManager showErrorWithStatus:error.localizedDescription inView:self.view];
                if (failBlock) {
                    failBlock(error);
                }
            } else {
                if (successBlock) {
                    successBlock();
                }
            }
        }
    }];
}

#pragma mark -  刷新UI
- (void)refreshUI {
    
    self.underFloorHeatNameLabel.text = self.deviceM.deviceName;
    
    if (self.deviceEditType == GSHDeviceVCTypeControl) {
        NSDictionary *dic = [self.deviceM realTimeDic];
        id value = [dic objectForKey:GSHUnderFloor_SwitchMeteId];
        if (value) {
            // 开关状态有值
            if ([value intValue] == 0) {
                // 地暖 关
                self.switchButton.selected = YES;
            } else if ([value intValue] == 10) {
                // 地暖 开
                self.switchButton.selected = NO;
            }
            id temperatureValue = [dic objectForKey:GSHUnderFloor_TemperatureMeteId];
            if (temperatureValue) {
                self.currentTemperatureValue = [temperatureValue intValue];
                self.temperatureLabel.text = [NSString stringWithFormat:@"%d",[temperatureValue intValue]];
            }
        } else {
            self.currentTemperatureValue = 16.0;
            self.temperatureLabel.text = @"16";
        }
        [self refreshTemperatureView];
    } else {
        if (self.deviceM.exts.count > 0) {
            NSString *switchValue = @"";
            for (GSHDeviceExtM *extM in self.deviceM.exts) {
                if ([extM.basMeteId isEqualToString:GSHUnderFloor_SwitchMeteId]) {
                    if (extM.rightValue) {
                        switchValue = extM.rightValue;
                    }
                    if (self.deviceEditType != GSHDeviceVCTypeSceneSet && extM.param) {
                        switchValue = extM.param;
                    }
                }
            }
            // v3.1.1 地暖选了温度,开关不作为条件 因此判断有开关属性且为0即表示关的状态,反之则为开的状态
            if (switchValue.length > 0 && switchValue.integerValue == 0) {
                // 关
                self.switchButton.selected = YES;
            } else {
                // 开
                self.switchButton.selected = NO;
                for (GSHDeviceExtM *extM in self.deviceM.exts) {
                    if ([extM.basMeteId isEqualToString:GSHUnderFloor_TemperatureMeteId]) {
                        NSString *value = extM.rightValue?extM.rightValue:(extM.param?extM.param:@"");
                        if (value.length>0) {
                            self.currentTemperatureValue = [value intValue];
                            self.temperatureLabel.text = [NSString stringWithFormat:@"%d",[value intValue]];
                        }
                    }
                }
            }
        } else {
            self.currentTemperatureValue = 16.0;
            self.temperatureLabel.text = @"16";
        }
        [self refreshTemperatureView];
    }
    // 开关状态有值
    if (self.switchButton.selected) {
        // 地暖 关
        self.switchButton.hidden = YES;
        self.switchBigButton.hidden = NO;
        self.controlView.hidden = YES;
    } else{
        // 地暖 开
        self.switchButton.hidden = NO;
        self.switchBigButton.hidden = YES;
        self.controlView.hidden = NO;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CALayer *layer = self.temperatureView.layer.presentationLayer;
    CGPoint touchPoint = [[touches anyObject] locationInView:self.controlView];
    if (CGRectContainsPoint(CGRectMake(layer.frame.origin.x, layer.frame.origin.y-10, layer.frame.size.width, layer.frame.size.height + 20), touchPoint) && !self.switchButton.selected) {
        // 触摸点在温度视图内
        CGFloat viewWidth = self.temperatureView.frame.size.width;
        CGFloat viewHeight = self.temperatureView.frame.size.height;
        CGFloat viewMinY = CGRectGetMinY(self.temperatureView.frame);
        
        CGFloat y ;
        if (touchPoint.y - viewMinY > 0 && touchPoint.y - viewMinY < 1) {
            y = 0.0;
        } else if (touchPoint.y - viewMinY < viewHeight && touchPoint.y - viewMinY > viewHeight - 1) {
            y = viewHeight;
        } else {
            y = touchPoint.y-viewMinY;
        }
        CGPoint endPoint = CGPointMake(viewWidth/2.0, (int)y);
        
        int temperatureValue = (int)(((viewHeight - y) / viewHeight) * 16) + 16;
        self.currentTemperatureValue = temperatureValue;
        self.temperatureLabel.text = [NSString stringWithFormat:@"%d",temperatureValue];
        
        [self drawLineWithEndPoint:endPoint];
        self.isDrawLine = YES;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
//    CALayer *layer = self.temperatureView.layer.presentationLayer;
//    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
//    if (CGRectContainsPoint(CGRectMake(layer.frame.origin.x, layer.frame.origin.y-10, layer.frame.size.width, layer.frame.size.height + 20), touchPoint) && !self.switchButton.selected) {
        if (self.deviceEditType == GSHDeviceVCTypeControl && self.isDrawLine) {
            if (self.currentTemperatureValue <= 32) {
                NSString *meteId = GSHUnderFloor_TemperatureMeteId;
                NSString *value = [NSString stringWithFormat:@"%d",(int)self.currentTemperatureValue];
                self.isDrawLine = NO;
                [self controlUnderFloorHeatWithBasMeteId:meteId value:value failBlock:^(NSError *error) {
                } successBlock:^() {
                }];
            }
        }
//    }
}

- (void)drawLineWithEndPoint:(CGPoint)endPoint {
    [self.temperatureView.layer addSublayer:[self drawLineWithEndPoint:CGPointMake(self.temperatureView.frame.size.width/2.0, 0) lineColor:[UIColor colorWithHexString:@"#F8F9FC"]]];
    CAShapeLayer *layer = [self drawLineWithEndPoint:endPoint lineColor:[UIColor colorWithHexString:@"#FD9B07"]];
    [self.temperatureView.layer addSublayer:layer];
}

- (CAShapeLayer *)drawLineWithEndPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor {
    //创建出CAShapeLayer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色为ClearColor
    
    //设置线条的宽度和颜色
    shapeLayer.lineWidth = self.temperatureView.frame.size.width;
    shapeLayer.strokeColor = lineColor.CGColor;
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(self.temperatureView.frame.size.width/2.0, self.temperatureView.frame.size.height)];
    [linePath addLineToPoint:endPoint];
    [linePath setLineWidth:self.temperatureView.frame.size.width];
    [linePath setLineJoinStyle:kCGLineJoinRound];
    [linePath setLineCapStyle:kCGLineCapRound];
    UIGraphicsBeginImageContext(self.temperatureView.bounds.size);
    [linePath stroke];
    [linePath fill];
    UIGraphicsEndImageContext();
    //让贝塞尔曲线与CAShapeLayer产生联系
    shapeLayer.path = linePath.CGPath;
    //添加并显示
    return shapeLayer;
}

@end

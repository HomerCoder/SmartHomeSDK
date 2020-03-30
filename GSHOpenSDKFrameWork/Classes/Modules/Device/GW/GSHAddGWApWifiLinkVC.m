//
//  GSHAddGWApWifiLinkVC.m
//  SmartHome
//
//  Created by gemdale on 2019/12/18.
//  Copyright © 2019 gemdale. All rights reserved.
//

#import "GSHAddGWApWifiLinkVC.h"
#import "SRWebSocket.h"
#import "GSHAddGWDetailVC.h"

@interface GSHAddGWApWifiLinkVC ()<SRWebSocketDelegate>
@property (strong, nonatomic)NSString *sn;
@property (strong, nonatomic)NSString *wifiName;
@property (strong, nonatomic)NSString *wifiPassWord;

@property (strong, nonatomic)NSTimer *timer;
@property (assign, nonatomic)NSInteger second;
@property (copy, nonatomic)NSString *gwId;
@property(nonatomic,strong,readwrite)SRWebSocket *webSocket;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewState;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UIButton *btnState;
@property (weak, nonatomic) IBOutlet UIView *viewState;
- (IBAction)touchState:(UIButton *)sender;
@end

@implementation GSHAddGWApWifiLinkVC
+(instancetype)addGWApWifiLinkVCWithSN:(NSString*)sn wifiName:(NSString*)wifiName wifiPassWord:(NSString*)wifiPassWord{
    GSHAddGWApWifiLinkVC *vc = [GSHPageManager viewControllerWithSB:@"AddGWSB" andID:@"GSHAddGWApWifiLinkVC"];
    vc.sn = sn;
    vc.wifiName = wifiName;
    vc.wifiPassWord = wifiPassWord;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 6.0 block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.pageControl.numberOfPages == weakSelf.pageControl.currentPage + 1) {
            weakSelf.pageControl.currentPage = 0;
            if (weakSelf.gwId.length > 0) {
                weakSelf.second++;
                if (weakSelf.second > 60) {
                    weakSelf.second = 0;
                    weakSelf.viewState.hidden = NO;
                }
                if (weakSelf.second % 5 == 0) {
                    [weakSelf check];
                }
            }
        }else{
            weakSelf.pageControl.currentPage++;
        }
    } repeats:YES];
    
    self.lblText.text = @"网关配置网络中，请稍等";
    
    [self openWebSocket];
}

-(void)dealloc{
    [self.timer invalidate];
    self.webSocket.delegate = nil;
    [self.webSocket close];
    self.webSocket = nil;
}

-(void)openWebSocket{
    self.webSocket.delegate = nil;
    [self.webSocket close];
    self.webSocket = nil;
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://192.168.100.1:9090"]] protocols:@[@"gem-ws-protocol"]];
    self.webSocket.delegate = self;
    [self.webSocket open];
}

-(void)check{
    __weak typeof(self)weakSelf = self;
    [GSHGatewayManager getGatewayStateWithGatewayId:self.gwId block:^(GSHGatewayM *gateWayM, NSError *error) {
        if (gateWayM.gatewayState.intValue == 2) {
            [weakSelf.timer invalidate];
            GSHAddGWDetailVC *vc = [GSHAddGWDetailVC addGWDetailVCWithGW:weakSelf.gwId family:[GSHOpenSDKShare share].currentFamily];
            NSMutableArray *list = [NSMutableArray array];
            for (UIViewController *vc in weakSelf.navigationController.viewControllers) {
                if ([vc isKindOfClass:GSHAddGWApWifiLinkVC.class]) {
                    break;
                }
                [list addObject:vc];
            }
            [list addObject:vc];
            [weakSelf.navigationController setViewControllers:list animated:YES];
        }
    }];
}

- (IBAction)touchState:(UIButton *)sender {
    self.second = 0;
    self.viewState.hidden = YES;
}

#pragma mark----------------webSockek代理----------------------------------------
// 收到消息
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isKindOfClass:NSData.class]) {
        GSHBaseMsg *msg = [GSHBaseMsg msgBaseMWithData:message];
        NSLog(@"收到消息 id:%d sn:%d",msg.message.id_p,msg.sn);
        if (msg.message.id_p == 804) {
            self.gwId = msg.message.gwId;
        }
    }
}
//链接打开
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"连接成功");
    GSHBaseMsg *msg = [[GSHBaseMsg alloc]init];
    msg.message.errCode = 0;
    msg.message.id_p = 803;
    msg.message.gwId = @"";
    msg.response_id_p = 804;
    
    ProtocolNodeMap *map = [ProtocolNodeMap new];
    
    ProtocolNode *note = [ProtocolNode new];
    note.name = @"WiFiconfig";
    
    ProtocolNodeAttribute *attr1 =  [ProtocolNodeAttribute new];
    attr1.name = @"APname";
    attr1.value = self.wifiName;
    ProtocolNodeAttribute *attr2 =  [ProtocolNodeAttribute new];
    attr2.name = @"APpasswd";
    attr2.value = self.wifiPassWord ? self.wifiPassWord : @"";
    note.attrArray = [NSMutableArray arrayWithObjects:attr1,attr2,nil];
    
    map.nodeArray = [NSMutableArray arrayWithObject:note];
    map.name = @"WiFiconfig";
    msg.message.nodeArray = [NSMutableArray arrayWithObject:map];
    [self.webSocket send:msg.msgData];
}
//
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"连接失败");
}
//
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"连接自己断开或被服务器断开");
}
//
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"收到系统心跳回调");
}

@end

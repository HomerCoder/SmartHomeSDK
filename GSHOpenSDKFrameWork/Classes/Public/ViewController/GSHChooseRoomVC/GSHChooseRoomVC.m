//
//  GSHChooseRoomVC.m
//  SmartHome
//
//  Created by zhanghong on 2018/6/27.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHChooseRoomVC.h"
#import "GSHChooseRoomCell.h"

@interface GSHChooseRoomVC () <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectViewTop;
@property (weak, nonatomic) IBOutlet UIView *chooseRoomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftTableViewWidth;
@property (weak, nonatomic) IBOutlet UITableView *leftTableView;
@property (weak, nonatomic) IBOutlet UITableView *rightTableView;

@property (nonatomic , strong) GSHFloorM *choosedFloorM;
@property (nonatomic , strong) GSHRoomM *choosedRoomM;
@property (nonatomic , strong) NSArray *floorArray;

@end

@implementation GSHChooseRoomVC

- (instancetype)initWithFloorM:(GSHFloorM *)floorM roomM:(GSHRoomM *)roomM floorArray:(NSArray *)floorArray{
    self = [super init];
    if (self) {
        self.choosedRoomM = roomM;
        self.floorArray = floorArray;
        if (floorM) {
            self.choosedFloorM = floorM;
        }else{
            self.choosedFloorM = self.floorArray.firstObject;
        }
        if (roomM) {
            self.choosedRoomM = roomM;
        }else{
            self.choosedRoomM = self.choosedFloorM.rooms.firstObject;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.selectViewTop.constant = KNavigationBar_Height;
    
    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTapClick)];
    dismissGesture.delegate = self;
    [self.view addGestureRecognizer:dismissGesture];
    
    self.leftTableView.dataSource = self;
    self.leftTableView.delegate = self;
    self.leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.leftTableView registerNib:[UINib nibWithNibName:@"GSHChooseRoomCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"leftCell"];
    
    self.rightTableView.dataSource = self;
    self.rightTableView.delegate = self;
    self.rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.rightTableView registerNib:[UINib nibWithNibName:@"GSHChooseRoomCell" bundle:MYBUNDLE] forCellReuseIdentifier:@"rightCell"];
    
    self.leftTableViewWidth.constant = SCREEN_WIDTH / 2.0;
    
    if (self.floorArray.count == 1) {
        self.lineView.hidden = YES;
        self.leftTableViewWidth.constant = 0;
    } 
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissTapClick {
    if (self.dissmissBlock) {
        self.dissmissBlock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.chooseRoomView]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftTableView) {
        return self.floorArray.count;
    } else {
        return self.choosedFloorM.rooms.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTableView) {
        GSHChooseRoomCell *chooseRoomCell = [tableView dequeueReusableCellWithIdentifier:@"leftCell" forIndexPath:indexPath];
        chooseRoomCell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.floorArray.count > indexPath.row) {
            GSHFloorM *floorM = self.floorArray[indexPath.row];
            chooseRoomCell.roomLabel.text = floorM.floorName;
            if (floorM.floorId && [self.choosedFloorM.floorId isEqualToNumber:floorM.floorId]) {
                chooseRoomCell.roomLabel.textColor = [UIColor colorWithHexString:@"#2EB0FF"];
                chooseRoomCell.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
            }else{
                chooseRoomCell.roomLabel.textColor = [UIColor colorWithHexString:@"#222222"];
                chooseRoomCell.backgroundColor = [UIColor whiteColor];
            }
        }
        return chooseRoomCell;
    } else {
        GSHChooseRoomCell *rightChooseRoomCell = [tableView dequeueReusableCellWithIdentifier:@"rightCell" forIndexPath:indexPath];
        rightChooseRoomCell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.choosedFloorM.rooms.count > indexPath.row) {
            GSHRoomM *roomM = self.choosedFloorM.rooms[indexPath.row];
            rightChooseRoomCell.roomLabel.text = roomM.roomName;
            if (roomM.roomId && [self.choosedRoomM.roomId isEqualToNumber:roomM.roomId]) {
                rightChooseRoomCell.roomLabel.textColor = [UIColor colorWithHexString:@"#2EB0FF"];
                rightChooseRoomCell.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
            }else{
                rightChooseRoomCell.roomLabel.textColor = [UIColor colorWithHexString:@"#222222"];
                rightChooseRoomCell.backgroundColor =  [UIColor whiteColor];
            }
        }
        return rightChooseRoomCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseRoomCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.roomLabel.textColor = [UIColor colorWithHexString:@"#2EB0FF"];
    cell.backgroundColor = [UIColor colorWithHexString:@"#F5F5F5"];
    if (tableView == self.leftTableView) {
        if (self.floorArray.count > indexPath.row) {
            GSHFloorM *floorM = self.floorArray[indexPath.row];
            if (floorM.floorId && [self.choosedFloorM.floorId isEqualToNumber:floorM.floorId]) {
                return;
            }
            self.choosedFloorM = floorM;
            self.choosedRoomM = self.choosedFloorM.rooms.firstObject;
            [self.leftTableView reloadData];
            [self.rightTableView reloadData];
        }
    } else {
        if (self.choosedFloorM.rooms.count > indexPath.row) {
            GSHRoomM *roomM = self.choosedFloorM.rooms[indexPath.row];
            if (self.chooseRoomBlock) {
                self.chooseRoomBlock(self.choosedFloorM,roomM);
            }
        }
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    GSHChooseRoomCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.roomLabel.textColor = [UIColor colorWithHexString:@"#222222"];
    cell.backgroundColor = [UIColor whiteColor];
    
}
@end

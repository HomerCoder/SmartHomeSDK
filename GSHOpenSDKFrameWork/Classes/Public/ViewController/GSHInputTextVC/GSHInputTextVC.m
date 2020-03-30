//
//  GSHInputTextVC.m
//  SmartHome
//
//  Created by gemdale on 2018/5/17.
//  Copyright © 2018年 gemdale. All rights reserved.
//

#import "GSHInputTextVC.h"

@interface GSHInputTextVC ()
@property (nonatomic,copy)NSString *oldText;
@property (nonatomic,copy)void(^block)(NSString *text,GSHInputTextVC *inputTextVC);
@property (weak, nonatomic) IBOutlet UITextField *tfText;
@end

@implementation GSHInputTextVC
+(instancetype)inputTextVCWithOldText:(NSString*)oldText block:(void(^)(NSString *text,GSHInputTextVC *inputTextVC))block{
    GSHInputTextVC *vc = [GSHPageManager viewControllerWithClass:GSHInputTextVC.class nibName:@"GSHInputTextVC"];
    vc.oldText = oldText;
    vc.block = block;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#2EB0FF"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn addTarget:self action:@selector(touchSave:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    self.tfText.text = self.oldText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{

}

- (void)touchSave:(id)sender {
    if (self.block) {
        self.block(self.tfText.text, self);
    }
}

@end

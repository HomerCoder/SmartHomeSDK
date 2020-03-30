

#import "PopoverView.h"
#import "PopoverViewCell.h"

static CGFloat const kPopoverViewMargin = 16.f;        ///< 边距
static CGFloat const kPopoverViewCellHeight = 50.f;   ///< cell指定高度
static CGFloat const kPopoverViewArrowHeight = 10.f;  ///< 箭头高度

static NSString *kPopoverCellReuseId = @"_PopoverCellReuseId";

float PopoverViewDegreesToRadians(float angle)
{
    return angle*M_PI/180;
}

@interface PopoverView () <UITableViewDelegate, UITableViewDataSource>

#pragma mark - UI
@property (nonatomic, weak) UIWindow *keyWindow;                ///< 当前窗口
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *shadeView;                ///< 遮罩层
@property (nonatomic, weak) CAShapeLayer *borderLayer;          ///< 边框Layer
@property (nonatomic, weak) UITapGestureRecognizer *tapGesture; ///< 点击背景阴影的手势

#pragma mark - Data
@property (nonatomic, copy) NSArray<PopoverAction *> *actions;
@property (nonatomic, assign) CGFloat windowWidth;   ///< 窗口宽度
@property (nonatomic, assign) CGFloat windowHeight;  ///< 窗口高度
@property (nonatomic, assign) BOOL isUpward;         ///< 箭头指向, YES为向上, 反之为向下, 默认为YES.

@property (nonatomic, copy) void (^hideBlock)(void) ;
@property (nonatomic, assign) BOOL isLeftPic;
@property (nonatomic, assign) BOOL isTitleLabelCenter;

@end

@implementation PopoverView

#pragma mark - Lift Cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    [self initialize];
    return self;
}

-(void)dealloc{
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _tableView.frame = CGRectMake(0, _isUpward ? kPopoverViewArrowHeight : 0,
                                  CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kPopoverViewArrowHeight);
}

#pragma mark - Setter
- (void)setHideAfterTouchOutside:(BOOL)hideAfterTouchOutside
{
    _hideAfterTouchOutside = hideAfterTouchOutside;
    _tapGesture.enabled = _hideAfterTouchOutside;
}

- (void)setShowShade:(BOOL)showShade
{
    _showShade = showShade;
    // [UIColor colorWithWhite:0.f alpha:0.18f]
    _shadeView.backgroundColor = _showShade ? [UIColor colorWithWhite:0.f alpha:0.25f] : [UIColor clearColor];
    
    if (_borderLayer) {
        
        _borderLayer.strokeColor = _showShade ? [UIColor clearColor].CGColor : _tableView.separatorColor.CGColor;
    }
}

- (void)setStyle:(PopoverViewStyle)style
{
    _style = style;
    
    _tableView.separatorColor = [PopoverViewCell bottomLineColorForStyle:_style];
    
    if (_style == PopoverViewStyleDefault) {
        
        self.backgroundColor = [UIColor whiteColor];
    }
    else {
        
        self.backgroundColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.00];
    }
}

#pragma mark - Private
/*! @brief 初始化相关 */
- (void)initialize
{
    // data
    _actions = @[];
    _isUpward = YES;
    _style = PopoverViewStyleDefault;
    _arrowStyle = PopoverViewArrowStyleRound;
    
    // current view
    self.backgroundColor = [UIColor whiteColor];
    
    // keyWindow
    _keyWindow = [UIApplication sharedApplication].keyWindow;
    _windowWidth = CGRectGetWidth(_keyWindow.bounds);
    _windowHeight = CGRectGetHeight(_keyWindow.bounds);
    
    // shadeView
    _shadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self setShowShade:NO];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [_shadeView addGestureRecognizer:tapGesture];
    _tapGesture = tapGesture;
    
    // tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = [PopoverViewCell bottomLineColorForStyle:_style];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView registerClass:[PopoverViewCell class] forCellReuseIdentifier:kPopoverCellReuseId];
    [self addSubview:_tableView];
}

/**
 显示弹窗指向某个点
 */
- (void)showToPoint:(CGPoint)toPoint
{
    // 截取弹窗时相关数据
    CGFloat arrowWidth = 28;
    CGFloat cornerRadius = 6.f;
    CGFloat arrowCornerRadius = 2.5f;
    CGFloat arrowBottomCornerRadius = 4.f;
    
    // 如果是菱角箭头的话, 箭头宽度需要小点.
    if (_arrowStyle == PopoverViewArrowStyleTriangle) {
        arrowWidth = 22.0;
    }
    
    // 如果箭头指向的点过于偏左或者过于偏右则需要重新调整箭头 x 轴的坐标
    CGFloat minHorizontalEdge = kPopoverViewMargin + cornerRadius + arrowWidth/2 + 2;
    if (toPoint.x < minHorizontalEdge) {
        toPoint.x = minHorizontalEdge;
    }
    if (_windowWidth - toPoint.x < minHorizontalEdge) {
        toPoint.x = _windowWidth - minHorizontalEdge;
    }
    
    // 遮罩层
    _shadeView.alpha = 0.f;
    [_keyWindow addSubview:_shadeView];
    
    // 刷新数据以获取具体的ContentSize
    [_tableView reloadData];
    if (!_isTitleLabelCenter) {
        // 此处,场景和联动处不需要修改文字颜色,故通过_isTitleLabelCenter控制,权宜之计
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.seleNumber inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    // 根据刷新后的ContentSize和箭头指向方向来设置当前视图的frame
    CGFloat currentW = [self calculateMaxWidth];// 宽度通过计算获取最大值
    CGFloat currentH = _tableView.contentSize.height;
    
    // 如果 actions 为空则使用默认的宽高
    if (_actions.count == 0) {
        currentW = 150.0;
        currentH = 20.0;
    }
    
    if (self.viewWight > 1) {
        currentW = self.viewWight;
    }
    
    // 箭头高度
    currentH += kPopoverViewArrowHeight;
    
    // 限制最高高度, 免得选项太多时超出屏幕
    CGFloat maxHeight = _isUpward ? (_windowHeight - toPoint.y - kPopoverViewMargin) : (toPoint.y - CGRectGetHeight([UIApplication sharedApplication].statusBarFrame));
    maxHeight = maxHeight > 400 ? 400 : maxHeight;
    if (currentH > maxHeight) { // 如果弹窗高度大于最大高度的话则限制弹窗高度等于最大高度并允许tableView滑动.
        currentH = maxHeight;
        _tableView.scrollEnabled = YES;
        if (!_isUpward) { // 箭头指向下则移动到最后一行
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_actions.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    
    CGFloat currentX = toPoint.x - currentW/2, currentY = toPoint.y;
    // x: 窗口靠左
    if (toPoint.x <= currentW/2 + kPopoverViewMargin) {
        currentX = kPopoverViewMargin;
    }
    // x: 窗口靠右
    if (_windowWidth - toPoint.x <= currentW/2 + kPopoverViewMargin) {
        currentX = _windowWidth - kPopoverViewMargin - currentW;
    }
    // y: 箭头向下
    if (!_isUpward) {
        currentY = toPoint.y - currentH;
    }
    
    self.frame = CGRectMake(currentX, currentY, currentW, currentH);
    
    // 截取箭头
    CGPoint arrowPoint = CGPointMake(toPoint.x - CGRectGetMinX(self.frame), _isUpward ? 0 : currentH); // 箭头顶点在当前视图的坐标
    CGFloat maskTop = _isUpward ? kPopoverViewArrowHeight : 0; // 顶部Y值
    CGFloat maskBottom = _isUpward ? currentH : currentH - kPopoverViewArrowHeight; // 底部Y值
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    // 左上圆角
    [maskPath moveToPoint:CGPointMake(0, cornerRadius + maskTop)];
    [maskPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius + maskTop)
                        radius:cornerRadius
                    startAngle:PopoverViewDegreesToRadians(180)
                      endAngle:PopoverViewDegreesToRadians(270)
                     clockwise:YES];
    // 箭头向上时的箭头位置
    if (_isUpward) {
        
        [maskPath addLineToPoint:CGPointMake(arrowPoint.x - arrowWidth/2, kPopoverViewArrowHeight)];
        // 菱角箭头
        if (_arrowStyle == PopoverViewArrowStyleTriangle) {
            
            [maskPath addLineToPoint:arrowPoint];
            [maskPath addLineToPoint:CGPointMake(arrowPoint.x + arrowWidth/2, kPopoverViewArrowHeight)];
        }
        else {
            
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x - arrowCornerRadius, arrowCornerRadius)
                             controlPoint:CGPointMake(arrowPoint.x - arrowWidth/2 + arrowBottomCornerRadius, kPopoverViewArrowHeight)];
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowCornerRadius, arrowCornerRadius)
                             controlPoint:arrowPoint];
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowWidth/2, kPopoverViewArrowHeight)
                             controlPoint:CGPointMake(arrowPoint.x + arrowWidth/2 - arrowBottomCornerRadius, kPopoverViewArrowHeight)];
        }
    }
    // 右上圆角
    [maskPath addLineToPoint:CGPointMake(currentW - cornerRadius, maskTop)];
    [maskPath addArcWithCenter:CGPointMake(currentW - cornerRadius, maskTop + cornerRadius)
                        radius:cornerRadius
                    startAngle:PopoverViewDegreesToRadians(270)
                      endAngle:PopoverViewDegreesToRadians(0)
                     clockwise:YES];
    // 右下圆角
    [maskPath addLineToPoint:CGPointMake(currentW, maskBottom - cornerRadius)];
    [maskPath addArcWithCenter:CGPointMake(currentW - cornerRadius, maskBottom - cornerRadius)
                        radius:cornerRadius
                    startAngle:PopoverViewDegreesToRadians(0)
                      endAngle:PopoverViewDegreesToRadians(90)
                     clockwise:YES];
    // 箭头向下时的箭头位置
    if (!_isUpward) {
        
        [maskPath addLineToPoint:CGPointMake(arrowPoint.x + arrowWidth/2, currentH - kPopoverViewArrowHeight)];
        // 菱角箭头
        if (_arrowStyle == PopoverViewArrowStyleTriangle) {
            
            [maskPath addLineToPoint:arrowPoint];
            [maskPath addLineToPoint:CGPointMake(arrowPoint.x - arrowWidth/2, currentH - kPopoverViewArrowHeight)];
        }
        else {
            
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x + arrowCornerRadius, currentH - arrowCornerRadius)
                             controlPoint:CGPointMake(arrowPoint.x + arrowWidth/2 - arrowBottomCornerRadius, currentH - kPopoverViewArrowHeight)];
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x - arrowCornerRadius, currentH - arrowCornerRadius)
                             controlPoint:arrowPoint];
            [maskPath addQuadCurveToPoint:CGPointMake(arrowPoint.x - arrowWidth/2, currentH - kPopoverViewArrowHeight)
                             controlPoint:CGPointMake(arrowPoint.x - arrowWidth/2 + arrowBottomCornerRadius, currentH - kPopoverViewArrowHeight)];
        }
    }
    // 左下圆角
    [maskPath addLineToPoint:CGPointMake(cornerRadius, maskBottom)];
    [maskPath addArcWithCenter:CGPointMake(cornerRadius, maskBottom - cornerRadius)
                        radius:cornerRadius
                    startAngle:PopoverViewDegreesToRadians(90)
                      endAngle:PopoverViewDegreesToRadians(180)
                     clockwise:YES];
    [maskPath closePath];
    // 截取圆角和箭头
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    // 边框 (只有在不显示半透明阴影层时才设置边框线条)
    if (!_showShade) {
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.frame = self.bounds;
        borderLayer.path = maskPath.CGPath;
        borderLayer.lineWidth = 1;
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.strokeColor = _tableView.separatorColor.CGColor;
        [self.layer addSublayer:borderLayer];
        _borderLayer = borderLayer;
    }
    
    [_keyWindow addSubview:self];
    
    @weakify(self)
    // 弹出动画
    CGRect oldFrame = self.frame;
    self.layer.anchorPoint = CGPointMake(arrowPoint.x/currentW, _isUpward ? 0.f : 1.f);
    self.frame = oldFrame;
    self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    [UIView animateWithDuration:0.25f animations:^{
        @strongify(self)
        self.transform = CGAffineTransformIdentity;
        self.shadeView.alpha = 1.f;
    }];
}

/*! @brief 计算最大宽度 */
- (CGFloat)calculateMaxWidth
{
    CGFloat maxWidth = 0;
    UIFont *titleFont = [PopoverViewCell titleFont];
    for (PopoverAction *action in _actions) {
        CGFloat titleWidth = [action.title sizeWithAttributes:@{NSFontAttributeName : titleFont}].width;
        maxWidth = maxWidth > titleWidth ? maxWidth : titleWidth;
    }
    if (self.isTitleLabelCenter) {
        maxWidth = maxWidth + 20 + 20;
    }else{
        maxWidth = maxWidth + 20 + 20 + 20 + 10;
    }
    
    return maxWidth > 200 ? 200 : maxWidth;
}

/**
 点击外部隐藏弹窗
 */
- (void)hide
{
    @weakify(self)
    if (self.hideBlock) {
        self.hideBlock();
    }
    [UIView animateWithDuration:0.25f animations:^{
        @strongify(self)
        self.alpha = 0.f;
        self.shadeView.alpha = 0.f;
        self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    } completion:^(BOOL finished) {
        @strongify(self)
        [self.shadeView removeFromSuperview];
        [self removeFromSuperview];
        
    }];
}

#pragma mark - Public
+ (instancetype)popoverView
{
    return [[self alloc] init];
}

- (void)showToView:(UIView *)pointView
         isLeftPic:(BOOL)isLeftPic
isTitleLabelCenter:(BOOL)isTitleLabelCenter
       withActions:(NSArray<PopoverAction *> *)actions
         hideBlock:(void(^)(void))hideBlock
{
    // 判断 pointView 是偏上还是偏下
    CGRect pointViewRect = [pointView.superview convertRect:pointView.frame toView:_keyWindow];
    CGFloat pointViewUpLength = CGRectGetMinY(pointViewRect);
    CGFloat pointViewDownLength = _windowHeight - CGRectGetMaxY(pointViewRect);
    // 弹窗箭头指向的点
    CGPoint toPoint = CGPointMake(CGRectGetMidX(pointViewRect), 0);
    // 弹窗在 pointView 顶部
    if (pointViewUpLength > pointViewDownLength) {
        toPoint.y = pointViewUpLength - 5;
    }
    // 弹窗在 pointView 底部
    else {
        toPoint.y = CGRectGetMaxY(pointViewRect) + 5;
    }
    
    // 箭头指向方向
    _isUpward = pointViewUpLength <= pointViewDownLength;
    
    if (!actions) {
        _actions = @[];
    } else {
        _actions = [actions copy];
    }
    
    _hideBlock = hideBlock;
    _isLeftPic = isLeftPic;
    _isTitleLabelCenter = isTitleLabelCenter;
    [self showToPoint:toPoint];
    
}

- (void)showToPoint:(CGPoint)toPoint withActions:(NSArray<PopoverAction *> *)actions
{
    if (!actions) {
        _actions = @[];
    } else {
        _actions = [actions copy];
    }
    
    // 计算箭头指向方向
    _isUpward = toPoint.y <= _windowHeight - toPoint.y;
    
    [self showToPoint:toPoint];
}

-(void)touchFootView{
    if (self.touchFootBlock) {
        self.touchFootBlock();
        self.actions = nil;
        [self.shadeView removeFromSuperview];
        [self removeFromSuperview];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _actions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPopoverViewCellHeight;
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kPopoverViewCellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.headText.length > 0) {
        return 40;
    }
    return 0.0;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    if (self.headText.length > 0) {
        return 40;
    }
    return 0.0;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.headText.length > 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.size.width, 40)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, tableView.size.width - 40, 40)];
        lbl.text = self.headText;
        lbl.textColor = [UIColor colorWithRGB:0x222222];
        lbl.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [view addSubview:lbl];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.footText.length > 0) {
        return kPopoverViewCellHeight;
    }
    return 0.0;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section{
    if (self.footText.length > 0) {
        return kPopoverViewCellHeight;
    }
    return 0.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.footText.length > 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.size.width, kPopoverViewCellHeight)];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.size.width, 0.5)];
        view.backgroundColor = [UIColor whiteColor];
        line.backgroundColor = [PopoverViewCell bottomLineColorForStyle:_style];
        [view addSubview:line];
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, tableView.size.width, kPopoverViewCellHeight)];
        [btn setTitle:self.footText forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(touchFootView) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor colorWithRGB:0x3C4366] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [view addSubview:btn];
        return view;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PopoverViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPopoverCellReuseId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.style = _style;
    [cell setAction:_actions[indexPath.row] isLeftPic:_isLeftPic isTitleLableCenter:_isTitleLabelCenter];
    [cell showBottomLine: indexPath.row < _actions.count - 1];
    cell.rightImageView.hidden = !(self.seleNumber == indexPath.row);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isLeftPic) {
        PopoverViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.rightImageView.hidden = NO;
    }
    PopoverAction *action = self.actions[indexPath.row];
    action.handler ? action.handler(action) : NULL;
    self.actions = nil;
    [self.shadeView removeFromSuperview];
    [self removeFromSuperview];
}

@end


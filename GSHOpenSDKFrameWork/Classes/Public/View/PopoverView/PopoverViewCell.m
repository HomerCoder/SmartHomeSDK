

#import "PopoverViewCell.h"
#import <Masonry.h>
#import "UIButton+WebCache.h"

#import "UIImageView+WebCache.h"

// extern
float const PopoverViewCellHorizontalMargin = 15.f; ///< 水平边距
float const PopoverViewCellVerticalMargin = 3.f; ///< 垂直边距
float const PopoverViewCellTitleLeftEdge = 8.f; ///< 标题左边边距

@interface PopoverViewCell ()

@property (nonatomic, weak) UIView *bottomLine;
@property (nonatomic, assign)BOOL isLeftPic;
@property (nonatomic, assign)BOOL isTitleLabelCenter;   // 文字是否居中

@property (nonatomic, strong) UIImageView *leftImageView;

@end

@implementation PopoverViewCell

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = self.backgroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self initialize];
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = _style == PopoverViewStyleDefault ? [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00] : [UIColor colorWithRed:0.23 green:0.23 blue:0.23 alpha:1.00];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            self.backgroundColor = [UIColor clearColor];
        }];
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.titleLabel.textColor = [UIColor colorWithRGB:0x2EB0FF];
    }else{
        if (_style == PopoverViewStyleDefault) {
            _titleLabel.textColor = UIColor.blackColor;
        } else {
            _titleLabel.textColor = UIColor.whiteColor;
        }
    }
}

#pragma mark - Setter
- (void)setStyle:(PopoverViewStyle)style {
    _style = style;
    _bottomLine.backgroundColor = [self.class bottomLineColorForStyle:style];
    if (_style == PopoverViewStyleDefault) {
        _titleLabel.textColor = UIColor.blackColor;
    } else {
        _titleLabel.textColor = UIColor.whiteColor;
    }
}

#pragma mark - Private
// 初始化
- (void)initialize {
    // 底部线条
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor colorWithRGB:0xe8e8e8];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:bottomLine];
    _bottomLine = bottomLine;
    // Constraint
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomLine]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(bottomLine)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLine(lineHeight)]|" options:kNilOptions metrics:@{@"lineHeight" : @(1/[UIScreen mainScreen].scale)} views:NSDictionaryOfVariableBindings(bottomLine)]];
    
    _rightImageView = [[UIImageView alloc] init];
    _rightImageView.hidden = YES;
    _rightImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_rightImageView];
    [_rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-20);
        make.width.equalTo(@(20));
        make.height.equalTo(@(20));
    }];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [self.class titleFont];
    _titleLabel.textColor = UIColor.blackColor;
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];
    
    _leftImageView = [[UIImageView alloc] init];
    _leftImageView.hidden = YES;
    [self.contentView addSubview:_leftImageView];
    _leftImageView.contentMode = UIViewContentModeCenter;
    [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(20);
        make.width.equalTo(@(20));
        make.height.equalTo(@(20));
    }];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.isLeftPic) {
        _titleLabel.frame = CGRectMake(20 + 20 + 10, 0, self.frame.size.width - 70, self.height);
    } else {
        _titleLabel.frame = CGRectMake(20, 0, self.frame.size.width - 70, self.height);
    }
    if (self.isTitleLabelCenter) {
        _titleLabel.frame = CGRectMake(20, 0, self.frame.size.width - 40, self.height);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
}

#pragma mark - Public
/*! @brief 标题字体 */
+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:15.f];
}

/*! @brief 底部线条颜色 */
+ (UIColor *)bottomLineColorForStyle:(PopoverViewStyle)style {
    return style == PopoverViewStyleDefault ? [UIColor colorWithRGB:0xe8e8e8] : [UIColor colorWithRGB:0xe8e8e8];
}

- (void)setAction:(PopoverAction *)action isLeftPic:(BOOL)isLeftPic isTitleLableCenter:(BOOL)isTitleLabelCenter {

    self.isLeftPic = isLeftPic;
    self.isTitleLabelCenter = isTitleLabelCenter;
    _titleLabel.text = action.title;
    if (isLeftPic) {
        _leftImageView.hidden = NO;
        _rightImageView.hidden = YES;
        if (action.image) {
            [_leftImageView setImage:action.image];
        }else{
            [_leftImageView sd_setImageWithURL:[NSURL URLWithString:action.imageUrl] placeholderImage:nil];
        }
    } else {
        _leftImageView.hidden = YES;
        _rightImageView.hidden = YES;
        if (action.image) {
            [_rightImageView setImage:action.image];
        }else{
            [_rightImageView sd_setImageWithURL:[NSURL URLWithString:action.imageUrl] placeholderImage:nil];
        }
    }
    
}

- (void)showBottomLine:(BOOL)show {
    _bottomLine.hidden = !show;
}

@end

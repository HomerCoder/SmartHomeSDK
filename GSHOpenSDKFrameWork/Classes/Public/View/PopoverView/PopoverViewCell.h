

#import <UIKit/UIKit.h>
#import "PopoverAction.h"

UIKIT_EXTERN float const PopoverViewCellHorizontalMargin; ///< 水平间距边距
UIKIT_EXTERN float const PopoverViewCellVerticalMargin; ///< 垂直边距
UIKIT_EXTERN float const PopoverViewCellTitleLeftEdge; ///< 标题左边边距

@interface PopoverViewCell : UITableViewCell

@property (nonatomic, assign) PopoverViewStyle style;

@property (nonatomic, strong) UIImageView *rightImageView;


@property (nonatomic, strong) UILabel *titleLabel;

/*! @brief 标题字体
 */
+ (UIFont *)titleFont;

/*! @brief 底部线条颜色
 */
+ (UIColor *)bottomLineColorForStyle:(PopoverViewStyle)style;

- (void)setAction:(PopoverAction *)action isLeftPic:(BOOL)isLeftPic isTitleLableCenter:(BOOL)isTitleLabelCenter;

- (void)showBottomLine:(BOOL)show;

@end

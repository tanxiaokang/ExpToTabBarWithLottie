//
//  EXPTabBarController.m
//  ExpToTabBarWithLottie
//
//  Created by 檀小康 on 2019/9/25.
//  Copyright © 2019 檀小康. All rights reserved.
//

#import "EXPTabBarController.h"
#import <Lottie/Lottie.h>

@interface EXPTabBarController ()<UITabBarControllerDelegate>
/// 关联到 controller 原因：解决快速点击两个不一样的 tabbar 后，需要关闭第一次点击的动画
@property(nonatomic, strong) LOTAnimationView *animationView;

@end

@implementation EXPTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    [self.tabBar setBackgroundColor:[UIColor whiteColor]];

    // 添加子控制器
    [self setupChildVC:[UIViewController class]
                 title:@"Home"
              andImage:@"icon_home_home"
        andSelectImage:@"icon_home_home_select"];
    [self setupChildVC:[UIViewController class]
                 title:@"Function1"
              andImage:@"icon_home_up"
        andSelectImage:@"icon_home_up_select"];
    [self setupChildVC:[UIViewController class]
                 title:@"Function2"
              andImage:@"icon_home_card"
        andSelectImage:@"icon_home_card_select"];
    [self setupChildVC:[UIViewController class]
                 title:@"User"
              andImage:@"icon_home_me"
        andSelectImage:@"icon_home_me_select"];
}

#pragma mark - Animation

- (LOTAnimationView *)getAnimationViewAtTabbarIndex:(NSInteger)index frame:(CGRect)frame {
    
    // tabbar1 。。。 tabbar3
    LOTAnimationView *view = [LOTAnimationView animationNamed:[NSString stringWithFormat:@"tabbar%ld",index+1]];
    view.frame = frame;
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.animationSpeed = 1;
    return view;
}
/**
 通过当前的 UITabBarController 和当前点击的 viewcontroller 拿到 UITabBarButton 并加载动画view
 
 @note 1. 获取当前点击的是第几个
 
 2.遍历取出所有的 tabBarButton
    tabBarController.tabBar.subviews 里面有
    <_UIBarBackground: 0x14be1c4d0; frame = (0 0; 414 49); userInteractionEnabled = NO; layer = <CAGradientLayer: 0x2831e3320>>,
    <UITabBarButton: 0x14be2c970; frame = (2 1; 100 48); opaque = NO; layer = <CAGradientLayer: 0x28303ce80>>,
    <UITabBarButton: 0x14be4b980; frame = (106 1; 99 48); opaque = NO; layer = <CAGradientLayer: 0x283002ac0>>,
    <UITabBarButton: 0x14be4c410; frame = (209 1; 100 48); opaque = NO; layer = <CAGradientLayer: 0x283003b00>>,
    <UITabBarButton: 0x14be4d0a0; frame = (313 1; 99 48); opaque = NO; layer = <CAGradientLayer: 0x2830031e0>>

 2.1 继续遍历tabBarButton 找到 UITabBarSwappableImageView 并保存
 (lldb) po tabBarButton.subviews
     <__NSArrayM 0x600003985740>(
     <UIVisualEffectView: 0x7f80b9c178b0; frame = (0 0; 100 48); userInteractionEnabled = NO; layer = <CAGradientLayer: 0x6000037077c0>> clientRequestedContentView effect=<UIVibrancyEffect: 0x600003560c10> style=UIBlurEffectStyleSystemChromeMaterial vibrancyStyle=UIVibrancyEffectStyleFill,
     <UITabBarSwappableImageView: 0x7f80b9e3ed70; frame = (34.3333 0.166667; 31 31); opaque = NO; userInteractionEnabled = NO; layer = <CAGradientLayer: 0x60000371c1a0>>,
     <UITabBarButtonLabel: 0x7f80b9c26730; frame = (38.6667 29.3333; 22.6667 13.3333); text = '首页'; opaque = NO; userInteractionEnabled = NO; layer = <CAGradientLayer: 0x600003712100>>
     )
 3. 找到当前的UITabBarButton
 
 4. 获取UITabBarButton中的 UITabBarSwappableImageView 并隐藏
    (lldb) po currentTabBarButton.subviews
    <__NSArrayM 0x283e8cb10>(
    <UITabBarSwappableImageView: 0x14be4b240; frame = (38 7.33333; 24 21); opaque = NO; userInteractionEnabled = NO; layer = <CAGradientLayer: 0x2830035e0>>,
    <UITabBarButtonLabel: 0x14be2cde0; frame = (38.6667 29.6667; 22.6667 13.3333); text = '首页'; opaque = NO; userInteractionEnabled = NO; layer = <CAGradientLayer: 0x28300dcc0>>
 
 5. 创建动画 view 加载到 当前的 UITabBarButton 并隐藏 UITabBarSwappableImageView
 
 6. 执行动画，动画结束后 显示 UITabBarSwappableImageView 移除 动画 view 并置空
 )
 */
- (void)setupAnaimationWithTabBarController:(UITabBarController *)tabBarController selectViewController:(UIViewController *)viewController {
    
    if (self.animationView) {
        [self.animationView stop];
    }
    
    //1.
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    
    __block NSMutableArray <UIImageView *>*tabBarSwappableImageViews = [NSMutableArray arrayWithCapacity:4];
    
    //2.
    for (UIView *tempView in tabBarController.tabBar.subviews) {
        
        if ([tempView isKindOfClass:NSClassFromString(@"UITabBarButton")])
        {
            //2.1
            for (UIImageView *tempImageView in tempView.subviews) {
                if ([tempImageView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                    [tabBarSwappableImageViews addObject:tempImageView];
                }
            }
        }
    }
    
    //3.
    __block UIImageView *currentTabBarSwappableImageView = tabBarSwappableImageViews[index];
    
    //4.
    CGRect frame = currentTabBarSwappableImageView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    __block LOTAnimationView *animationView = [self getAnimationViewAtTabbarIndex:index frame:frame];
    self.animationView = animationView;
    animationView.center = currentTabBarSwappableImageView.center;
    [currentTabBarSwappableImageView.superview addSubview:animationView];
    
    currentTabBarSwappableImageView.hidden = YES;

    //6.
    [animationView playFromProgress:0 toProgress:1 withCompletion:^(BOOL animationFinished) {
        currentTabBarSwappableImageView.hidden = NO;
        [animationView removeFromSuperview];
        animationView = nil;
    }];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    [self setupAnaimationWithTabBarController:tabBarController selectViewController:viewController];
}

#pragma mark - Custom
/**
 * 初始化子控制器
 */
- (void)setupChildVC:(Class)vc title:(NSString *)title andImage:(NSString * )image andSelectImage:(NSString *)selectImage{
    
    UIViewController * VC = [[vc alloc] init];
    VC.view.backgroundColor = UIColor.whiteColor;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:VC];
    nvc.tabBarItem.title = title;
    nvc.tabBarItem.image = [[UIImage imageNamed:image]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nvc.tabBarItem.selectedImage = [[UIImage imageNamed:selectImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nvc.tabBarItem.imageInsets = UIEdgeInsetsMake(-1.5, 0, 1.5, 0);
    [self addChildViewController:nvc];
}

@end

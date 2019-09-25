# UITabBarController 加入 lottie 动画
tabbar动画 用 Lottie 
实现原理是 遍历出imageView，做动画时，添加动画视图，动画结束后隐藏视图

![实例](https://github.com/tanxiaokang/ExpToTabBarWithLottie/blob/master/exp.gif)


```
#import <Lottie/Lottie.h>

@interface CDKTabBarController ()<UITabBarControllerDelegate>

/// 关联到 controller 原因：解决快速点击两个不一样的 tabbar 后，需要关闭第一次点击的动画
@property(nonatomic, strong) LOTAnimationView *animationView;

@end

```


implementation

```
@implementation CDKTabBarController


#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    [self setupAnaimationWithTabBarController:tabBarController selectViewController:viewController];
}

#pragma mark - Animation

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

    //5.
    [animationView playFromProgress:0 toProgress:1 withCompletion:^(BOOL animationFinished) {
        currentTabBarSwappableImageView.hidden = NO;
        [animationView removeFromSuperview];
        animationView = nil;
    }];
}

- (LOTAnimationView *)getAnimationViewAtTabbarIndex:(NSInteger)index frame:(CGRect)frame {
    
    // tabbar1 。。。 tabbar3
    LOTAnimationView *view = [LOTAnimationView animationNamed:[NSString stringWithFormat:@"tabbar%ld",index+1]];
    view.frame = frame;
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.animationSpeed = 1;
    return view;
}

```

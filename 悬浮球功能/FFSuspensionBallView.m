////
//  FFSuspensionBallView.m
//  fitfunTool
//
//  Created by ___Fitfun___ on 2018/10/16.
//Copyright © 2018年 penglei. All rights reserved.
//



#import "FFSuspensionBallView.h"
#import "FitFunSystemTool.h"
#import <FitfunCore/FitfunCore.h>

#define MAIN_VIEW_WIDTH         50.
#define MV_PADDING              0.
#define DELAY_TIME              1.6
#define ANIMAT_TIME             0.382

@interface FFSuspensionBallView()

//悬浮球图片
@property(nonatomic, strong)UIImageView* mainImageView;
//是否正在拖拽
@property(nonatomic, assign)BOOL isDragging;

@end

@implementation FFSuspensionBallView

+ (instancetype)sharedBallView {
    static id sharedBallView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBallView = [[self alloc] initWithFrame:
                          CGRectMake(-MAIN_VIEW_WIDTH/2, MAIN_VIEW_WIDTH, MAIN_VIEW_WIDTH, MAIN_VIEW_WIDTH)];
    });
    return sharedBallView;
}

- (void)ff_showSuspensionBallView {
    [[self getRootViewController].view addSubview:self];
    [self initBallView];
}


- (void)ff_hideSuspensionBallView {
    [self.mainImageView removeFromSuperview];
    self.mainImageView = nil;
    self.isDragging = NO;
    [self removeFromSuperview];
}

- (FFSuspensionBallView *(^)(void))showSuspensionBallView {
    return ^id() {
        [self ff_hideSuspensionBallView];
        [[self getRootViewController].view addSubview:self];
        [self initBallView];
        return self;
    };
}

- (FFSuspensionBallView *(^)(void))hideSuspensionBallView {
    return  ^id() {
        [self.mainImageView removeFromSuperview];
        self.mainImageView = nil;
        self.isDragging = NO;
        [self removeFromSuperview];
        return self;
    };
}

- (FFSuspensionBallView *(^)(NSString *ballImageResoucePath))ballImagePath {
    return ^id(NSString *ballImageResoucePath) {
        self.ballImageResoucePath = ballImageResoucePath;
        return self;
    };
}

- (FFSuspensionBallView *(^)(FFTapBallViewBlock tapViewBlock))tapView {
    return ^id(FFTapBallViewBlock tapViewBlock) {
        self.tapBallViewBlock = tapViewBlock;
        return self;
    };
}

#pragma mark private method

- (void)initBallView {
    //给悬浮球图片添加拖拽手势
    UIPanGestureRecognizer *panGes=[[UIPanGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(dragView:)];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBallView)];
    [self addGestureRecognizer:panGes];
    [self addGestureRecognizer:tapGes];
    [self addSubview:self.mainImageView];
}

- (UIViewController *)getRootViewController {
    UIWindow *window=[[[UIApplication sharedApplication] delegate ] window];
    if (!window) {
        window=[UIApplication sharedApplication].keyWindow;
    }
    return window.rootViewController;
}

- (void)dragView:(UIPanGestureRecognizer*)panGes {
    CGPoint currentPoint=[panGes locationInView:[
                                                 UIApplication sharedApplication].keyWindow.rootViewController.view];
    [UIView animateWithDuration:0.182 animations:^{
        CGRect rect=self.frame;
        rect.origin=currentPoint;
        self.frame=rect;
    }];
    if (panGes.state == UIGestureRecognizerStateBegan) {
        self.mainImageView.alpha = 1;
        self.isDragging = YES;
    }else if(panGes.state == UIGestureRecognizerStateEnded
             || panGes.state == UIGestureRecognizerStateCancelled) {
        self.isDragging = NO;
        [self moveSuspensionBallView];
    }
}

- (void)moveSuspensionBallView {
    CGRect rect = self.frame;
    
    self.mainImageView.alpha = 1;
    
    if (self.center.x <= SCREEN_WIDTH/2.) {
        rect.origin.x = MV_PADDING;
    }else{
        rect.origin.x = SCREEN_WIDTH-MAIN_VIEW_WIDTH-MV_PADDING;
    }
    
    if (rect.origin.y <= 20) {
        rect.origin.y = 40;
    
    } else if (rect.origin.y > SCREEN_HEIGHT-80) {
        rect.origin.y = SCREEN_HEIGHT-80;
    } else {
        //iPhone异形屏适配
        if (isIPhoneXSeries()) {
            if (LandscapeLeft) {
                if (self.center.x <= SCREEN_WIDTH/2.) {
                    if (50<rect.origin.y && rect.origin.y <SCREEN_HEIGHT-100) {
                        rect.origin.x = FFStatusBarHeight-20;
                    }
                }
                
            }else if (LandscapeRight) {
                if (self.center.x > SCREEN_WIDTH/2.) {
                    if (50<rect.origin.y && rect.origin.y <SCREEN_HEIGHT-100) {
                       rect.origin.x = SCREEN_WIDTH-MAIN_VIEW_WIDTH-MV_PADDING-FFStatusBarHeight+20;
                    }
                }
            }
        }
    }
    
    [UIView animateWithDuration:ANIMAT_TIME animations:^{
        self.frame = rect;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopSuspensionBallView];
    });
}

- (void)stopSuspensionBallView {
    [UIView animateWithDuration:ANIMAT_TIME animations:^{
        CGRect rect = self.frame;
        if (self.center.x <= SCREEN_WIDTH/2.) {
            rect.origin.x -=  MAIN_VIEW_WIDTH/2;
            //位置重新校准矫正
            if (!(rect.origin.x ==(FFStatusBarHeight-MAIN_VIEW_WIDTH/2-2))
                || !(rect.origin.x == -MAIN_VIEW_WIDTH/2)) {
                if (isIPhoneXSeries()) {
                    if (LandscapeLeft) {
                        if (50<rect.origin.y && rect.origin.y <SCREEN_HEIGHT-100) {
                            rect.origin.x = FFStatusBarHeight-MAIN_VIEW_WIDTH/2-20;
                        } else {
                            rect.origin.x= -MAIN_VIEW_WIDTH/2;
                        }
                    }else {
                        rect.origin.x= -MAIN_VIEW_WIDTH/2;
                    }
                }else {
                    rect.origin.x= -MAIN_VIEW_WIDTH/2;
                }
            }
        }else{
            rect.origin.x += MAIN_VIEW_WIDTH/2;
            if (!(rect.origin.x==(SCREEN_WIDTH-MAIN_VIEW_WIDTH/2-MV_PADDING-FFStatusBarHeight+20)) || !(rect.origin.x == (SCREEN_WIDTH-MAIN_VIEW_WIDTH/2))) {
                if (isIPhoneXSeries()) {
                    if (LandscapeRight) {
                        if (50<rect.origin.y && rect.origin.y <SCREEN_HEIGHT-100) {
                            rect.origin.x = SCREEN_WIDTH-MAIN_VIEW_WIDTH/2-MV_PADDING-FFStatusBarHeight+20;
                        } else {
                            rect.origin.x = SCREEN_WIDTH-MAIN_VIEW_WIDTH/2;
                        }
                    }else {
                        rect.origin.x =SCREEN_WIDTH-MAIN_VIEW_WIDTH/2;
                    }
                }else {
                    rect.origin.x =SCREEN_WIDTH-MAIN_VIEW_WIDTH/2;
                }
            }
        }
        self.frame=rect;
    } completion:^(BOOL finished) {
         self.mainImageView.alpha =0.5;
    }];
}

- (void)tapBallView {
    if (self.isDragging) {
        return;
    }
    self.mainImageView.alpha = 1;
    [self initTapBallViewFrame];
    if (self.tapBallViewBlock) {
        self.tapBallViewBlock();
    }
   
}


- (void)initTapBallViewFrame {
    CGRect rect = self.frame;
    if (self.center.x <= SCREEN_WIDTH/2.) {
            if (isIPhoneXSeries()) {
                if (LandscapeLeft) {
                    if (50<rect.origin.y && rect.origin.y <SCREEN_HEIGHT-100) {
                        rect.origin.x = FFStatusBarHeight-MAIN_VIEW_WIDTH/2-20;
                    } else {
                        rect.origin.x=  -MAIN_VIEW_WIDTH/2;
                    }
                }else {
                    rect.origin.x=  -MAIN_VIEW_WIDTH/2;
                }
            }else {
                rect.origin.x=  -MAIN_VIEW_WIDTH/2;
            }
    }else{
            if (isIPhoneXSeries()) {
                if (LandscapeRight) {
                    if (50<rect.origin.y && rect.origin.y <SCREEN_HEIGHT-100) {
                        rect.origin.x = SCREEN_WIDTH-MAIN_VIEW_WIDTH/2-MV_PADDING-FFStatusBarHeight+20;
                        return;
                    }
                }
            }else {
                rect.origin.x =SCREEN_WIDTH-MAIN_VIEW_WIDTH/2;
            }
    }
    self.frame=rect;
    self.mainImageView.alpha = 0.5;
}
#pragma mark -getter&&setter

- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_VIEW_WIDTH, MAIN_VIEW_WIDTH)];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
         NSBundle *ffBundle = FitfunBUNDLE;
        _mainImageView.image = self.ballImageResoucePath?[UIImage imageWithContentsOfFile:self.ballImageResoucePath]:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/fitfun_ball_icon.png",ffBundle.bundlePath]];
        _mainImageView.alpha = 0.5;
    }
    return _mainImageView;
}

@end

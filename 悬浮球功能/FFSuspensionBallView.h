////
//  FFSuspensionBallView.h
//  fitfunTool
//
//  Created by ___Fitfun___ on 2018/10/16.
//Copyright © 2018年 penglei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FFTapBallViewBlock)(void);


@interface FFSuspensionBallView : UIView

//悬浮球图片本地资源路径 默认取本地资源下的名称为ballIcon.png的图片
@property(nonatomic, copy)NSString *ballImageResoucePath;
//点击事件悬浮球按钮事件响应回调
@property(nonatomic, copy)FFTapBallViewBlock tapBallViewBlock;

+ (instancetype)sharedBallView;

/** 显示悬浮球*/
- (void)ff_showSuspensionBallView;

/**隐藏并移除悬浮球*/
- (void)ff_hideSuspensionBallView;

//*************************** 链式语法兼容****************************
- (FFSuspensionBallView *(^)(void))showSuspensionBallView;
- (FFSuspensionBallView *(^)(void))hideSuspensionBallView;
- (FFSuspensionBallView *(^)(NSString *ballImageResoucePath))ballImagePath;
- (FFSuspensionBallView *(^)(FFTapBallViewBlock tapViewBlock))tapView;

@end

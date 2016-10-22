
#import "MBProgressHUD+PDExtension.h"

@implementation MBProgressHUD (PDExtension)

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:0.7];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    return hud;
}



+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView: [UIApplication sharedApplication].keyWindow];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView: [UIApplication sharedApplication].keyWindow];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:[UIApplication sharedApplication].keyWindow];
}

+ (void)hideHUDForView:(UIView *)view
{
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}


+(void)showToastWithMessage:(NSString *)aMessage
{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow];
    MBProgressHUD *tip = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    tip.opaque = 0.4;
    tip.cornerRadius = 5;
    tip.labelColor = [UIColor whiteColor];
    tip.labelFont = [UIFont systemFontOfSize:15];
    
    tip.mode = MBProgressHUDModeText;
    tip.labelText = aMessage;
    [tip show:YES];
    [tip hide:YES afterDelay:1.5];
}

+(void)showToastWithMuliLinesMessage:(NSString *)aMessage
{
    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow];
    MBProgressHUD *tip = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    tip.opaque = 0.4;
    tip.cornerRadius = 5;
    tip.mode = MBProgressHUDModeText;
    tip.detailsLabelColor = [UIColor whiteColor];
    tip.detailsLabelFont = [UIFont systemFontOfSize:15];

    tip.detailsLabelText = aMessage;
    [tip show:YES];
    [tip hide:YES afterDelay:1.5];
}

@end

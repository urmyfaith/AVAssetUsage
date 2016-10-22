@interface MBProgressHUD (PDExtension)

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

/**
 *  从中间弹出来的的圆角矩形提示消息
 *  适合单行文本
 *  @param aMessage 消息
 */
+(void)showToastWithMessage:(NSString *)aMessage;

/**
 *  从中间弹出来的的圆角矩形提示消息
 *  适合多行文本
 *  @param aMessage 消息
 */
+(void)showToastWithMuliLinesMessage:(NSString *)aMessage;
@end

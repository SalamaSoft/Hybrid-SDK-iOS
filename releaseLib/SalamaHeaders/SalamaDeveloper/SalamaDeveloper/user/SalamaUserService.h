//
//  SalamaUserService.h
//  SalamaDeveloper
//
//  Created by Liu Xinggu on 13-7-26.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAuthInfo : NSObject

@property (nonatomic, retain) NSString* loginId;

@property (nonatomic, retain) NSString* returnCode;

@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* authTicket;
@property (nonatomic, assign) long long expiringTime;

@end

@interface SalamaUserService : NSObject
{
    @private
    UserAuthInfo* _userAuthInfo;
}

@property (nonatomic, readonly) UserAuthInfo* userAuthInfo;

+ (SalamaUserService*)singleton;

/**
 * 返回用户是否已登录(检测是否有登录票据，以及票据是否过期)
 * @return 1:是  0:否
 */
- (int)isUserAuthValid;

/**
 * 取得用户认证信息
 * @return 用户认证信息
 */
- (UserAuthInfo*)getUserAuthInfo;

/**
 * 保存用户认证信息(存储至手机中)
 */
- (void)storeUserAuthInfo:(UserAuthInfo*)userAuthInfo;

/**
 * 用户注册
 * @param loginId 登录ID
 * @param password 密码
 * @return 用户认证信息(包含Ticket，登录操作的结果)。
 * 其中returnCode是操作的结果，有以下种类:
 * 0:成功 
 * -8:失败。loginId格式不正确(正确的格式：长度小于等于32；内容仅允许英文字母，数字，和三种符号'.','_','-'，不能以符号开头或结尾)
 * -9:失败。password格式不正确(正确的格式：长度小于等于32)
 * -20:失败。loginId重复
 * -30:失败。其他错误。
 */
- (UserAuthInfo*)signUp:(NSString*)loginId password:(NSString*)password;

/**
 * 用户登录
 * @param loginId 登录ID
 * @param password 密码
 * @return 用户认证信息(包含Ticket，登录操作的结果)。
 * 其中returnCode是操作的结果，有以下种类:
 * 0:成功
 * -8:失败。loginId格式不正确(正确的格式：长度小于等于32；内容仅允许英文字母，数字，和三种符号'.','_','-'，不能以符号开头或结尾)
 * -9:失败。password格式不正确(正确的格式：长度小于等于32)
 * -10:失败。登录id和密码验证不通过
 * -20:失败。loginId重复
 * -30:失败。其他错误。
 */
- (UserAuthInfo*)login:(NSString*)loginId password:(NSString*)password;

/**
 * 用户通过存储在手机中的登录票据登录
 * @return 用户认证信息(包含Ticket，登录操作的结果)。
 * 其中returnCode是操作的结果，有以下种类:
 * 0:成功
 * -11:失败。登录票据过期失效
 * -30:失败。其他错误。
 */
- (UserAuthInfo*)loginByTicket;

/**
 * 修改密码
 * @param loginId 登录ID
 * @param password 原密码
 * @param newPassword 新密码
 * @return 用户认证信息(包含Ticket，登录操作的结果)。
 * 其中returnCode是操作的结果，有以下种类:
 * 0:成功
 * -8:失败。loginId格式不正确(正确的格式：长度小于等于32；内容仅允许英文字母，数字，和三种符号'.','_','-'，不能以符号开头或结尾)
 * -9:失败。password格式不正确(正确的格式：长度小于等于32)
 * -10:失败。登录id和密码验证不通过
 * -30:失败。其他错误。
 */
- (UserAuthInfo*)changePassword:(NSString*)loginId password:(NSString*)password newPassword:(NSString*)newPassword;

/**
 * 登出
 * @return 1:成功 以外:失败
 */
- (NSString*)logout;

@end

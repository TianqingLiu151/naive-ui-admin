import { Alova } from '@/utils/http/alova/index';
import { SysUserVO } from './types/user-types';

/**
 * @description: 获取用户信息
 */
export function getUserInfo() {
  return Alova.Get<InResult>('/sysUser/userInfo', {
    meta: {
      isReturnNativeResponse: true,
    },
  });
}

/**
 * @description: 用户登录
 */
export function login(params) {
  return Alova.Post<InResult>('/auth/login', params, {
    meta: {
      isReturnNativeResponse: true,
    },
  });
}

/**
 * @description: 用户修改密码
 */
export function changePassword(params, uid) {
  return Alova.Post(`/user/u${uid}/changepw`, { params });
}

/**
 * @description: 用户登出
 */
export function logout(params) {
  return Alova.Post('/auth/logout', {
    params,
  });
}

/**
 * @description: 获取用户分页列表
 */
export function getUserPageList(params) {
  return Alova.Get<SysUserVO[]>('/sysUser/list', {
    params,
  });
}

/**
 * @description: 新增用户
 * @param params
 * @returns
 */
export function addUser(params) {
  return Alova.Post('/sysUser/add', params);
}

/**
 * @description: 更新用户
 * @param params
 * @returns
 */
export function updateUser(params) {
  return Alova.Post('/sysUser/update', params);
}

/**
 * @description: 更新用户状态
 * @param params
 * @returns
 */
export function updateStatus(params) {
  return Alova.Patch(`/sysUser/updateStatus/${params.id}?status=${params.status}`);
}

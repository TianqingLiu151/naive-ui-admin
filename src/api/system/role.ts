import { Alova } from '@/utils/http/alova/index';

/**
 * 系统角色表
 */
export interface SysRole {
  /**
   * 角色ID
   */
  id?: number;

  /**
   * 角色名称
   */
  name?: string;

  /**
   * 角色值
   */
  value?: string;

  /**
   * 说明
   * 注意：`explain` 是 JavaScript/TypeScript 的保留关键字
   * 在实际使用时可能需要修改字段名
   */
  explain?: string;

  /**
   * 是否默认角色
   */
  isDefault?: boolean;

  /**
   * 状态
   */
  status?: string;

  createdAt?: Date;
}

/**
 * @description: 角色列表
 */
export function getRoleList(params) {
  return Alova.Get<SysRole[]>('/sysRole/list', { params });
}

/**
 * @description: 新增角色
 */
export function createRole(data: SysRole) {
  return Alova.Post<SysRole>('/sysRole/create', data);
}

/**
 * @description: 修改角色
 */
export function updateRole(data: SysRole) {
  return Alova.Post<SysRole>('/sysRole/edit', data);
}

/**
 * @description: 删除角色
 */
export function deleteRole(id: number) {
  return Alova.Delete<SysRole>('/sysRole/delete/' + id);
}

/**
 * @description: 更新角色菜单关联
 */
export function updateRoleMenu(data: { roleId: number; menuIds: number[] }) {
  return Alova.Post('/sysRoleMenu/updateRoleMenus', data);
}

/**
 * @description: 根据角色id获取菜单id列表
 */
export function getRoleMenuIds(roleId: number) {
  return Alova.Get<number[]>('/sysRole/getRoleMenus/' + roleId);
}

/**
 * @description: 获取角色关联的用户ID列表
 */
export function getRoleUserIds(roleId: number) {
  return Alova.Get<number[]>('/sysRole/getRoleUsers/' + roleId);
}

/**
 * @description: 更新角色关联的用户
 */
export function updateRoleUsers(data: { roleId: number; userIds: number[] }) {
  return Alova.Post('/sysUserRole/updateRoleUsers', data);
}

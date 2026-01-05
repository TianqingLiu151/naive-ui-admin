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

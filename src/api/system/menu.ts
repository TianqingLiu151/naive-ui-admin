import { Alova } from '@/utils/http/alova/index';
export interface ListDate {
  id?: string | number;
  label: string;
  key: string;
  type: number;
  subtitle: string;
  openType: number;
  auth: string;
  path: string;
  name: string;
  component: string;
  redirect: string;
  keepAlive: boolean;
  activeMenu: string;
  icon: string;
  hidden: boolean;
  sort: number;
  children?: ListDate[];
}

/**
 * @description: 根据用户id获取用户菜单
 */
export function adminMenus() {
  return Alova.Get<ListDate[]>('/sysMenu/userMenus');
}

/**
 * 获取tree菜单列表
 * @param params
 */
export function getMenuList(params?) {
  return Alova.Get<ListDate[]>('/sysMenu/tree', {
    params,
  });
}

/**
 * 新增菜单
 * @param params
 */
export function addMenu(params) {
  return Alova.Post('/sysMenu/create', params);
}

/**
 * 更新菜单
 * @param params
 * @returns
 */
export function updateMenu(params) {
  return Alova.Post<boolean>('/sysMenu/edit', params);
}

/**
 * 删除菜单
 * @param params
 * @returns
 */
export function deleteMenu(params) {
  return Alova.Delete<boolean>(`/sysMenu/delete/${params.id}`);
}

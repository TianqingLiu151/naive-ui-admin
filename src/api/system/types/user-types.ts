export interface SysUserVO {
  /**
   * 用户ID
   */
  id?: number;

  /**
   * 用户名
   */
  username?: string;

  /**
   * 真实姓名
   */
  realName?: string;

  /**
   * 头像地址
   */
  avatar?: string;

  /**
   * 描述
   */
  desc?: string;

  /**
   * 状态: normal-正常, locked-锁定
   */
  status?: 'normal' | 'locked';

  /**
   * 创建时间
   */
  createdAt?: string; // 或者使用 Date 类型: createdAt?: Date;
}

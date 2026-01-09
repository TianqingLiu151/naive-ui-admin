import { h } from 'vue';
import { NAvatar, NTag } from 'naive-ui';
import { BasicColumn } from '@/components/Table';
import { SysUserVO } from '@/api/system/types/user-types';

export const columns: BasicColumn<SysUserVO>[] = [
  {
    title: 'ID',
    key: 'id',
    width: 100,
  },
  {
    title: '用户名',
    key: 'username',
    width: 150,
  },
  {
    title: '真实姓名',
    key: 'realName',
    width: 150,
  },
  {
    title: '头像',
    key: 'avatar',
    width: 100,
    render(record) {
      return h(NAvatar, {
        size: 40,
        src: record.avatar,
        fallbackSrc: 'https://07akioni.oss-cn-beijing.aliyuncs.com/07akioni.jpeg', // Fallback image
      });
    },
  },
  {
    title: '描述',
    key: 'desc',
  },
  {
    title: '状态',
    key: 'status',
    width: 100,
    render(record) {
      return h(
        NTag,
        {
          type: record.status === 'normal' ? 'success' : 'error',
        },
        {
          default: () => (record.status === 'normal' ? '正常' : '锁定'),
        }
      );
    },
  },
  {
    title: '创建时间',
    key: 'createdAt',
    width: 200,
  },
];

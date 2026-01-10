import { h } from 'vue';
import { NTag } from 'naive-ui';

export const columns = [
  {
    title: 'id',
    key: 'id',
    width: 100,
  },
  {
    title: '角色名称',
    key: 'name',
    width: 100,
  },
  {
    title: '说明',
    key: 'explain',
    minWidth: 150,
  },
  {
    title: '是否默认角色',
    key: 'isDefault',
    width: 120,
    render(row) {
      return h(
        NTag,
        {
          type: row.isDefault ? 'success' : 'error',
        },
        {
          default: () => (row.isDefault ? '是' : '否'),
        }
      );
    },
  },
  {
    title: '创建时间',
    key: 'create_date',
    width: 160,
  },
];

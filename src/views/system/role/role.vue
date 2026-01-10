<template>
  <div>
    <n-card :bordered="false" class="mt-4 proCard">
      <BasicTable
        :columns="columns"
        :request="loadDataTable"
        :row-key="(row) => row.id"
        ref="actionRef"
        :actionColumn="actionColumn"
        @update:checked-row-keys="onCheckedRow"
        :scroll-x="1090"
      >
        <template #tableTitle>
          <n-button type="primary" @click="addRole">
            <template #icon>
              <n-icon>
                <PlusOutlined />
              </n-icon>
            </template>
            新增角色
          </n-button>
        </template>

        <template #action>
          <TableAction />
        </template>
      </BasicTable>
    </n-card>

    <n-modal v-model:show="showModal" :show-icon="false" preset="dialog" :title="editRoleTitle">
      <div class="py-3 menu-list">
        <n-tree
          block-line
          cascade
          checkable
          :virtual-scroll="true"
          :data="treeData"
          :expandedKeys="expandedKeys"
          :checked-keys="checkedKeys"
          style="max-height: 950px; overflow: hidden"
          key-field="id"
          @update:checked-keys="checkedTree"
          @update:expanded-keys="onExpandedKeys"
          @update:indeterminate-keys="onIndeterminateKeys"
        />
      </div>
      <template #action>
        <n-space>
          <n-button type="info" ghost icon-placement="left" @click="packHandle">
            全部{{ expandedKeys.length ? '收起' : '展开' }}
          </n-button>

          <n-button type="info" ghost icon-placement="left" @click="checkedAllHandle">
            全部{{ checkedAll ? '取消' : '选择' }}
          </n-button>
          <n-button type="primary" :loading="formBtnLoading" @click="confirmForm">提交</n-button>
        </n-space>
      </template>
    </n-modal>
    <CreateModal ref="createModalRef" @reload="reloadTable" />
    <EditModal ref="editModalRef" @reload="reloadTable" />
    <RoleUserModal ref="roleUserModalRef" @reload="reloadTable" />
  </div>
</template>

<script lang="ts" setup>
  import { reactive, ref, unref, h, onMounted } from 'vue';
  import { useMessage, useDialog } from 'naive-ui';
  import { BasicTable, TableAction } from '@/components/Table';
  import { getRoleList, deleteRole, updateRoleMenu, getRoleMenuIds } from '@/api/system/role';
  import { getMenuList } from '@/api/system/menu';
  import { columns } from './columns';
  import { PlusOutlined } from '@vicons/antd';
  import CreateModal from './CreateModal.vue';
  import EditModal from './EditModal.vue';
  import RoleUserModal from './RoleUserModal.vue';
  import type { ListDate } from '@/api/system/menu';

  const message = useMessage();
  const dialog = useDialog();
  const actionRef = ref();
  const createModalRef = ref();
  const editModalRef = ref();
  const roleUserModalRef = ref();
  const showModal = ref(false);
  const formBtnLoading = ref(false);
  const checkedAll = ref(false);
  const editRoleTitle = ref('');
  const treeData = ref<ListDate[]>([]);
  const expandedKeys = ref<number[]>([]);
  const checkedKeys = ref<number[]>([]);
  const indeterminateKeys = ref<number[]>([]);
  const currentRoleId = ref(0);

  const params = reactive({
    name: 'NaiveAdmin',
  });

  const actionColumn = reactive({
    width: 320,
    title: '操作',
    key: 'action',
    fixed: 'right',
    render(record) {
      return h(TableAction, {
        style: 'button',
        actions: [
          {
            label: '菜单权限',
            onClick: handleMenuAuth.bind(null, record),
            // 根据业务控制是否显示 isShow 和 auth 是并且关系
            ifShow: () => {
              return true;
            },
            // 根据权限控制是否显示: 有权限，会显示，支持多个
            auth: ['role-menu'],
          },
          {
            label: '关联用户',
            onClick: handleUserAuth.bind(null, record),
            ifShow: () => {
              return true;
            },
            auth: ['role-user'],
          },
          {
            label: '编辑',
            onClick: handleEdit.bind(null, record),
            ifShow: () => {
              return true;
            },
            auth: ['role-edit'],
          },
          {
            label: '删除',
            onClick: handleDelete.bind(null, record),
            // 根据业务控制是否显示 isShow 和 auth 是并且关系
            ifShow: () => {
              return true;
            },
            // 根据权限控制是否显示: 有权限，会显示，支持多个
            auth: ['role-delete'],
          },
        ],
      });
    },
  });

  const loadDataTable = async (res: any) => {
    let _params = {
      ...unref(params),
      ...res,
    };
    const method = getRoleList(_params);
    return await method.send(true);
    // return await getRoleList(_params);
  };

  function addRole() {
    createModalRef.value.openModal();
  }

  function onCheckedRow(rowKeys: any[]) {
    console.log(rowKeys);
  }

  function reloadTable() {
    actionRef.value.reload();
  }

  async function confirmForm(e: any) {
    e.preventDefault();
    formBtnLoading.value = true;
    let menuIds = [...checkedKeys.value, ...indeterminateKeys.value];
    try {
      await updateRoleMenu({ roleId: currentRoleId.value, menuIds: menuIds });
      message.success('提交成功');
      showModal.value = false;
      reloadTable();
    } catch (error) {
      console.error(error);
      message.error('提交失败');
    } finally {
      formBtnLoading.value = false;
    }
  }

  function handleEdit(record: Recordable) {
    console.log('点击了编辑', record);
    // router.push({ name: 'basic-info', params: { id: record.id } });
    editModalRef.value.showModal(record);
  }

  function handleUserAuth(record: Recordable) {
    roleUserModalRef.value.showModal(record);
  }

  function handleDelete(record: Recordable) {
    dialog.warning({
      title: '提示',
      content: '您确定要删除此角色吗？',
      positiveText: '确定',
      negativeText: '取消',
      onPositiveClick: async () => {
        await deleteRole(record.id);
        message.success('删除成功');
        reloadTable();
      },
      onNegativeClick: () => {},
    });
  }

  async function handleMenuAuth(record: Recordable) {
    currentRoleId.value = record.id;
    editRoleTitle.value = `分配 ${record.name} 的菜单权限`;
    checkedKeys.value = record.menu_keys;
    //调用根据角色id获取菜单id列表接口
    const keys = await getRoleMenuIds(record.id);
    checkedKeys.value = getLeafKeys(treeData.value, keys);
    indeterminateKeys.value = [];
    showModal.value = true;
  }

  function checkedTree(keys) {
    checkedKeys.value = keys;
  }

  function onExpandedKeys(keys) {
    expandedKeys.value = keys;
  }

  function onIndeterminateKeys(keys: number[]) {
    indeterminateKeys.value = keys;
  }

  function packHandle() {
    if (expandedKeys.value.length) {
      expandedKeys.value = [];
    } else {
      expandedKeys.value = treeData.value.map((item: any) => item.id) as [];
    }
  }

  function checkedAllHandle() {
    if (!checkedAll.value) {
      checkedKeys.value = getTreeIds(treeData.value);
      checkedAll.value = true;
      indeterminateKeys.value = [];
    } else {
      checkedKeys.value = [];
      checkedAll.value = false;
      indeterminateKeys.value = [];
    }
  }

  function getTreeIds(data: any[]) {
    const ids: any[] = [];
    const traverse = (items: any[]) => {
      items.forEach((item) => {
        ids.push(item.id);
        if (item.children) traverse(item.children);
      });
    };
    traverse(data);
    return ids;
  }

  function getLeafKeys(tree: any[], keys: number[]) {
    const leafKeys: number[] = [];
    const keysSet = new Set(keys);
    const traverse = (nodes: any[]) => {
      nodes.forEach((node) => {
        if (!node.children || node.children.length === 0) {
          if (keysSet.has(node.id)) {
            leafKeys.push(node.id);
          }
        } else {
          traverse(node.children);
        }
      });
    };
    traverse(tree);
    return leafKeys;
  }

  onMounted(async () => {
    const treeMenuList = await getMenuList();
    expandedKeys.value =
      treeMenuList?.map((item) => item.id).filter((id): id is number => typeof id === 'number') ||
      [];
    treeData.value = treeMenuList;
  });
</script>

<style lang="less" scoped>
  .menu-list {
    height: 400px;
  }
</style>

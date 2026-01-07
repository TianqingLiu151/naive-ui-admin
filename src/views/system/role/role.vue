<template>
  <div>
    <div class="n-layout-page-header">
      <n-card :bordered="false" title="角色权限管理">
        页面数据为 Mock 示例数据，非真实数据。
      </n-card>
    </div>
    <n-card :bordered="false" class="mt-4 proCard">
      <BasicTable
        :columns="columns"
        :request="loadDataTable"
        :row-key="(row) => row.id"
        ref="actionRef"
        :actionColumn="actionColumn"
        @update:checked-row-keys="onCheckedRow"
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
  import type { ListDate } from '@/api/system/menu';

  const message = useMessage();
  const dialog = useDialog();
  const actionRef = ref();
  const createModalRef = ref();
  const editModalRef = ref();
  const showModal = ref(false);
  const formBtnLoading = ref(false);
  const checkedAll = ref(false);
  const editRoleTitle = ref('');
  const treeData = ref<ListDate[]>([]);
  const expandedKeys = ref<number[]>([]);
  const checkedKeys = ref<number[]>([]);
  const currentRoleId = ref(0);

  const params = reactive({
    name: 'NaiveAdmin',
  });

  const actionColumn = reactive({
    width: 250,
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
            auth: ['basic_list'],
          },
          {
            label: '编辑',
            onClick: handleEdit.bind(null, record),
            ifShow: () => {
              return true;
            },
            auth: ['basic_list'],
          },
          {
            label: '删除',
            onClick: handleDelete.bind(null, record),
            // 根据业务控制是否显示 isShow 和 auth 是并且关系
            ifShow: () => {
              return true;
            },
            // 根据权限控制是否显示: 有权限，会显示，支持多个
            auth: ['basic_list'],
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
    try {
      await updateRoleMenu({ roleId: currentRoleId.value, menuIds: checkedKeys.value });
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
    checkedKeys.value = await getRoleMenuIds(record.id);
    showModal.value = true;
  }

  function checkedTree(keys) {
    checkedKeys.value = keys;
  }

  function onExpandedKeys(keys) {
    expandedKeys.value = keys;
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
    } else {
      checkedKeys.value = [];
      checkedAll.value = false;
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

  onMounted(async () => {
    const treeMenuList = await getMenuList();
    expandedKeys.value =
      treeMenuList?.map((item) => item.id).filter((id): id is number => typeof id === 'number') ||
      [];
    treeData.value = treeMenuList;
  });
</script>

<style lang="less" scoped></style>

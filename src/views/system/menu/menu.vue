<template>
  <div>
    <div class="n-layout-page-header">
      <n-card :bordered="false" title="菜单权限管理">
        页面数据为 Mock 示例数据，非真实数据。
      </n-card>
    </div>
    <n-grid class="mt-4" cols="1 s:1 m:1 l:3 xl:3 2xl:3" responsive="screen" :x-gap="12">
      <n-gi span="1">
        <n-card :segmented="{ content: true }" :bordered="false" size="small">
          <template #header>
            <n-space>
              <n-dropdown trigger="hover" @select="selectAddMenu" :options="addMenuOptions">
                <n-button type="info" ghost icon-placement="right">
                  添加菜单
                  <template #icon>
                    <div class="flex items-center">
                      <n-icon size="14">
                        <DownOutlined />
                      </n-icon>
                    </div>
                  </template>
                </n-button>
              </n-dropdown>
              <n-button type="info" ghost icon-placement="left" @click="packHandle">
                全部{{ expandedKeys.length ? '收起' : '展开' }}
                <template #icon>
                  <div class="flex items-center">
                    <n-icon size="14">
                      <AlignLeftOutlined />
                    </n-icon>
                  </div>
                </template>
              </n-button>
            </n-space>
          </template>
          <div class="w-full menu">
            <n-input type="input" v-model:value="pattern" placeholder="输入菜单名称搜索">
              <template #suffix>
                <n-icon size="18" class="cursor-pointer">
                  <SearchOutlined />
                </n-icon>
              </template>
            </n-input>
            <div class="py-3 menu-list">
              <template v-if="loading">
                <div class="flex items-center justify-center py-4">
                  <n-spin size="medium" />
                </div>
              </template>
              <template v-else>
                <n-tree
                  block-line
                  cascade
                  checkable
                  :virtual-scroll="true"
                  :pattern="pattern"
                  :data="treeData"
                  :expandedKeys="expandedKeys"
                  style="max-height: 650px; overflow: hidden"
                  @update:selected-keys="selectedTree"
                  @update:expanded-keys="onExpandedKeys"
                />
              </template>
            </div>
          </div>
        </n-card>
      </n-gi>
      <n-gi span="2">
        <n-card :segmented="{ content: true }" :bordered="false" size="small">
          <template #header>
            <n-space>
              <n-icon size="18">
                <FormOutlined />
              </n-icon>
              <span>编辑菜单{{ treeItemTitle ? `：${treeItemTitle}` : '' }}</span>
            </n-space>
          </template>
          <n-alert type="info" closable> 从菜单列表选择一项后，进行编辑</n-alert>
          <n-form
            :model="formParams"
            :rules="rules"
            ref="formRef"
            label-placement="left"
            :label-width="100"
            v-if="isEditMenu"
            class="py-4"
          >
            <n-form-item label="类型" path="type">
              <n-radio-group v-model:value="formParams.type">
                <n-space>
                  <n-radio :value="1">菜单</n-radio>
                  <n-radio :value="2">按钮</n-radio>
                </n-space>
              </n-radio-group>
            </n-form-item>
            <n-form-item label="标题" path="label">
              <n-input placeholder="请输入标题" v-model:value="formParams.label" />
            </n-form-item>
            <n-form-item label="副标题" path="subtitle" v-if="formParams.type === 1">
              <n-input placeholder="请输入副标题" v-model:value="formParams.subtitle" />
            </n-form-item>
            <n-form-item label="路径" path="path" v-if="formParams.type === 1">
              <n-input placeholder="请输入路径" v-model:value="formParams.path" />
            </n-form-item>
            <n-form-item label="打开方式" path="openType" v-if="formParams.type === 1">
              <n-radio-group v-model:value="formParams.openType" name="openType">
                <n-space>
                  <n-radio :value="1">当前窗口</n-radio>
                  <n-radio :value="2">新窗口</n-radio>
                </n-space>
              </n-radio-group>
            </n-form-item>
            <n-form-item label="菜单权限" path="auth">
              <n-input placeholder="请输入权限，多个权限用，分割" v-model:value="formParams.auth" />
            </n-form-item>
            <n-form-item label="隐藏侧边栏" path="hidden" v-if="formParams.type === 1">
              <n-switch v-model:value="formParams.hidden" />
            </n-form-item>
            <n-form-item path="auth" style="margin-left: 100px">
              <n-space>
                <n-button type="primary" :loading="subLoading" @click="formSubmit"
                  >保存修改</n-button
                >
                <n-button @click="handleReset">重置</n-button>
                <n-button @click="handleDel">删除</n-button>
              </n-space>
            </n-form-item>
          </n-form>
        </n-card>
      </n-gi>
    </n-grid>
    <CreateDrawer ref="createDrawerRef" :title="drawerTitle" />
  </div>
</template>
<script lang="ts" setup>
  import { ref, unref, reactive, onMounted, computed } from 'vue';
  import { useDialog, useMessage } from 'naive-ui';
  import { DownOutlined, AlignLeftOutlined, SearchOutlined, FormOutlined } from '@vicons/antd';
  import { getMenuList } from '@/api/system/menu';
  import { getTreeItem } from '@/utils';
  import CreateDrawer from './CreateDrawer.vue';
  import type { ListDate } from '@/api/system/menu';
  import { updateMenu } from '@/api/system/menu';

  // 表单验证规则
  const rules = computed(() => {
    return {
      label: {
        required: true,
        message: '请输入标题',
        trigger: 'blur',
      },
      path: {
        required: formParams.type === 1,
        message: '请输入路径',
        trigger: 'blur',
      },
    };
  });

  const formRef: any = ref(null);
  const createDrawerRef = ref();
  const message = useMessage();
  const dialog = useDialog();

  // 当前选中的树节点 key
  let treeItemKey = ref([]);
  // 展开的树节点 keys
  let expandedKeys = ref([]);
  // 树形菜单数据
  const treeData = ref<ListDate[]>([]);

  const loading = ref(true);
  const subLoading = ref(false);
  // 是否处于编辑模式
  const isEditMenu = ref(false);
  // 当前编辑的菜单标题
  const treeItemTitle = ref('');
  // 搜索关键字
  const pattern = ref('');
  // 抽屉标题
  const drawerTitle = ref('');

  // 是否禁用“添加子菜单”选项（仅当未选中任何节点时禁用）
  const isAddSon = computed(() => {
    return !treeItemKey.value.length;
  });

  // 添加菜单下拉选项
  const addMenuOptions = ref([
    {
      label: '添加顶级菜单',
      key: 'home',
      disabled: false,
    },
    {
      label: '添加子菜单',
      key: 'son',
      disabled: isAddSon,
    },
  ]);

  // 编辑表单参数
  const formParams = reactive({
    type: 1,
    label: '',
    subtitle: '',
    path: '',
    auth: '',
    openType: 1,
    hidden: false,
  });

  // 处理添加菜单下拉选择
  function selectAddMenu(key: string) {
    drawerTitle.value = key === 'home' ? '添加顶栏菜单' : `添加子菜单：${treeItemTitle.value}`;
    openCreateDrawer(key);
  }

  // 打开新增菜单抽屉
  function openCreateDrawer(key: string) {
    const { openDrawer } = createDrawerRef.value;
    if (key === 'home') {
      openDrawer(0); // 0 表示顶级菜单
    } else {
      const treeItem = getTreeItem(unref(treeData), treeItemKey.value[0]);
      openDrawer(treeItem.id); // 传递父级菜单 ID
    }
  }

  // 选中树节点时的回调
  function selectedTree(keys) {
    debugger;
    if (keys.length) {
      const treeItem = getTreeItem(unref(treeData), keys[0]);
      treeItemKey.value = keys;
      treeItemTitle.value = treeItem.label;
      Object.assign(formParams, treeItem);
      isEditMenu.value = true;
    } else {
      isEditMenu.value = false;
      treeItemKey.value = [];
      treeItemTitle.value = '';
    }
  }

  // 处理删除操作
  function handleDel() {
    dialog.info({
      title: '提示',
      content: `您确定想删除此权限吗?`,
      positiveText: '确定',
      negativeText: '取消',
      onPositiveClick: () => {
        message.success('删除成功');
      },
      onNegativeClick: () => {
        message.error('已取消');
      },
    });
  }

  // 重置编辑表单
  function handleReset() {
    const treeItem = getTreeItem(unref(treeData), treeItemKey.value[0]);
    Object.assign(formParams, treeItem);
  }

  // 提交编辑表单
  async function formSubmit() {
    formRef.value.validate(async (errors: boolean) => {
      if (!errors) {
        const res = await updateMenu(formParams);
        if (res) {
          message.success('更新成功');
        } else {
          message.error('更新失败');
        }
      } else {
        message.error('请填写完整信息');
      }
    });
  }

  // 展开/收起全部节点
  function packHandle() {
    if (expandedKeys.value.length) {
      expandedKeys.value = [];
    } else {
      expandedKeys.value = unref(treeData).map((item: any) => item.key as string) as [];
    }
  }

  // 初始化菜单数据
  async function initMenuData() {
    loading.value = true;
    const treeMenuList = await getMenuList();
    console.log(treeMenuList);
    treeData.value = treeMenuList;
    loading.value = false;
  }

  onMounted(async () => {
    await initMenuData();
  });

  // 刷新列表
  function reloadTable() {
    initMenuData();
  }

  // 树节点展开/收起时的回调
  function onExpandedKeys(keys) {
    expandedKeys.value = keys;
  }
</script>

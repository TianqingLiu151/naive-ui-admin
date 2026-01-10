<template>
  <n-drawer v-model:show="state.isDrawer" :width="width" :placement="state.placement">
    <n-drawer-content :title="title" closable>
      <n-form
        :model="formParams"
        :rules="rules"
        ref="formRef"
        label-placement="left"
        :label-width="100"
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
        <n-form-item label="路由名称" path="name" v-if="formParams.type === 1">
          <n-input placeholder="请输入路由名称" v-model:value="formParams.name" />
        </n-form-item>
        <n-form-item label="组件路径" path="component" v-if="formParams.type === 1">
          <n-input
            placeholder="请输入组件路径 (如 /system/user/index)"
            v-model:value="formParams.component"
          />
        </n-form-item>
        <n-form-item label="图标" path="icon" v-if="formParams.type === 1">
          <n-input placeholder="请输入图标名称" v-model:value="formParams.icon" />
        </n-form-item>
        <n-form-item label="重定向" path="redirect" v-if="formParams.type === 1">
          <n-input placeholder="请输入重定向地址" v-model:value="formParams.redirect" />
        </n-form-item>
        <n-form-item label="高亮菜单" path="activeMenu" v-if="formParams.type === 1">
          <n-input placeholder="请输入高亮菜单的路由名称" v-model:value="formParams.activeMenu" />
        </n-form-item>
        <n-form-item label="排序" path="sort">
          <n-input-number v-model:value="formParams.sort" />
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
        <n-form-item label="是否缓存" path="keepAlive" v-if="formParams.type === 1">
          <n-switch v-model:value="formParams.keepAlive" />
        </n-form-item>
      </n-form>

      <template #footer>
        <n-space>
          <n-button type="primary" :loading="state.subLoading" @click="formSubmit">提交</n-button>
          <n-button @click="handleReset">重置</n-button>
        </n-space>
      </template>
    </n-drawer-content>
  </n-drawer>
</template>

<script lang="ts" setup>
  import { reactive, ref, toRefs, computed } from 'vue';
  import { useMessage } from 'naive-ui';
  import { addMenu } from '@/api/system/menu';

  const emit = defineEmits(['reload']);

  // 表单验证规则
  const rules = computed(() => {
    return {
      label: {
        required: true,
        message: '请输入标题',
        trigger: 'blur',
      },
      name: {
        required: true,
        message: '请输入路由名称',
        trigger: 'blur',
      },
      path: {
        required: formParams.value.type === 1,
        message: '请输入路径',
        trigger: 'blur',
      },
    };
  });

  defineProps({
    title: {
      type: String,
      default: '添加顶级菜单',
    },
    width: {
      type: Number,
      default: 450,
    },
  });

  const message = useMessage();
  const formRef: any = ref(null);
  // 表单默认值
  const defaultValueRef = () => ({
    label: '',
    type: 1,
    subtitle: '',
    openType: 1,
    auth: '',
    path: '',
    name: '',
    component: '',
    redirect: '',
    activeMenu: '',
    icon: '',
    sort: 1,
    keepAlive: true,
    hidden: false,
    parentId: 0,
  });
  // 表单参数
  const formParams = ref(defaultValueRef());

  // 抽屉状态管理
  const state = reactive({
    isDrawer: false,
    subLoading: false,
    placement: 'right' as const,
  });

  // 打开抽屉
  function openDrawer(parentId = 0) {
    state.isDrawer = true;
    formParams.value.parentId = parentId;
  }

  // 关闭抽屉
  function closeDrawer() {
    state.isDrawer = false;
  }

  // 提交表单
  function formSubmit() {
    formRef.value.validate(async (errors) => {
      if (!errors) {
        try {
          state.subLoading = true;
          await addMenu(formParams.value);
          message.success('添加成功');
          handleReset();
          closeDrawer();
          emit('reload');
        } finally {
          state.subLoading = false;
        }
      } else {
        message.error('请填写完整信息');
      }
    });
  }

  // 重置表单
  function handleReset() {
    formRef.value.restoreValidation();
    formParams.value = Object.assign(formParams.value, defaultValueRef());
  }

  // 暴露方法给父组件
  defineExpose({
    openDrawer,
  });
</script>

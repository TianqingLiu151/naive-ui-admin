<template>
  <n-flex vertical>
    <n-card :bordered="false">
      <BasicForm @register="register" @submit="handleSubmit" @reset="handleReset" />
    </n-card>
    <n-card :bordered="false">
      <BasicTable
        :columns="columns"
        :request="loadDataTable"
        :row-key="(row) => row.id"
        ref="actionRef"
        :actionColumn="actionColumn"
        :scroll-x="1000"
        :striped="true"
      >
        <template #tableTitle>
          <n-button type="primary" @click="handleAdd">
            <template #icon>
              <n-icon>
                <PlusOutlined />
              </n-icon>
            </template>
            新建用户
          </n-button>
        </template>
      </BasicTable>

      <n-modal
        v-model:show="showModal"
        :show-icon="false"
        preset="dialog"
        :title="formParams.id ? '编辑用户' : '新建用户'"
      >
        <n-form
          :model="formParams"
          :rules="rules"
          ref="formRef"
          label-placement="left"
          :label-width="80"
          class="py-4"
        >
          <n-form-item label="用户名" path="username">
            <n-input
              placeholder="请输入用户名"
              v-model:value="formParams.username"
              :disabled="!!formParams.id"
            />
          </n-form-item>
          <n-form-item label="真实姓名" path="realName">
            <n-input placeholder="请输入真实姓名" v-model:value="formParams.realName" />
          </n-form-item>
          <n-form-item label="描述" path="desc">
            <n-input type="textarea" placeholder="请输入描述" v-model:value="formParams.desc" />
          </n-form-item>
        </n-form>

        <template #action>
          <n-space>
            <n-button @click="() => (showModal = false)">取消</n-button>
            <n-button type="info" :loading="formBtnLoading" @click="confirmForm">确定</n-button>
          </n-space>
        </template>
      </n-modal>
    </n-card>
  </n-flex>
</template>

<script lang="ts" setup>
  import { h, reactive, ref } from 'vue';
  import { BasicTable, TableAction } from '@/components/Table';
  import { BasicForm, FormSchema, useForm } from '@/components/Form/index';
  import { getUserPageList, addUser, updateUser, updateStatus } from '@/api/system/user';
  import { columns } from './columns';
  import { PlusOutlined } from '@vicons/antd';
  import { useRouter } from 'vue-router';
  import { type FormRules, useDialog } from 'naive-ui';

  const router = useRouter();
  const actionRef = ref();
  const formRef = ref();
  const showModal = ref(false);
  const formBtnLoading = ref(false);
  const dialog = useDialog();

  const formParams = reactive({
    id: 0,
    username: '',
    realName: '',
    desc: '',
  });

  const rules: FormRules = {
    username: {
      required: true,
      trigger: ['blur', 'input'],
      message: '请输入用户名',
    },
    realName: {
      required: true,
      trigger: ['blur', 'input'],
      message: '请输入真实姓名',
    },
  };

  const schemas: FormSchema[] = [
    {
      field: 'keyword',
      component: 'NInput',
      label: '关键词',
      componentProps: {
        placeholder: '请输入用户名/真实姓名',
        onInput: (e: any) => {
          console.log(e);
        },
      },
    },
  ];

  const actionColumn = reactive({
    width: 150,
    title: '操作',
    key: 'action',
    fixed: 'right',
    render(record) {
      return h(TableAction as any, {
        style: 'button',
        actions: [
          {
            label: '编辑',
            onClick: handleEdit.bind(null, record),
            ifShow: () => {
              return true;
            },
            // auth: ['system:user:edit'],
          },
          {
            label: record.status === 'normal' ? '禁用' : '启用',
            onClick: handleDelete.bind(null, record),
            ifShow: () => {
              return true;
            },
            // auth: ['system:user:remove'],
          },
        ],
      });
    },
  });

  const [register, { getFieldsValue }] = useForm({
    gridProps: { cols: '1 s:1 m:2 l:3 xl:4 2xl:4' },
    labelWidth: 80,
    schemas,
  });

  const loadDataTable = async (res) => {
    return await getUserPageList({ ...getFieldsValue(), ...res });
  };

  function reloadTable() {
    actionRef.value.reload();
  }

  function handleAdd() {
    // 重置表单
    Object.assign(formParams, {
      id: 0,
      username: '',
      realName: '',
      desc: '',
    });
    showModal.value = true;
  }

  function confirmForm(e) {
    e.preventDefault();
    formBtnLoading.value = true;
    formRef.value.validate((errors) => {
      if (!errors) {
        if (formParams.id) {
          updateUser(formParams)
            .then(() => {
              window['$message'].success('更新成功');
              showModal.value = false;
              reloadTable();
              formBtnLoading.value = false;
            })
            .catch(() => {
              window['$message'].error('更新失败');
              formBtnLoading.value = false;
            });
        } else {
          addUser(formParams)
            .then(() => {
              window['$message'].success('新建成功');
              showModal.value = false;
              reloadTable();
              formBtnLoading.value = false;
            })
            .catch(() => {
              window['$message'].error('新建失败');
              formBtnLoading.value = false;
            });
        }
      } else {
        window['$message'].error('请填写完整信息');
        formBtnLoading.value = false;
      }
    });
  }

  function handleEdit(record: Recordable) {
    Object.assign(formParams, {
      id: record.id,
      username: record.username,
      realName: record.realName,
      desc: record.desc,
    });
    showModal.value = true;
  }

  function handleDelete(record: Recordable) {
    const statusText = record.status === 'normal' ? '禁用' : '启用';
    dialog.warning({
      title: '警告',
      content: `确定要${statusText}用户 ${record.username} 吗？`,
      positiveText: '确定',
      negativeText: '取消',
      onPositiveClick: () => {
        const newStatus = record.status === 'normal' ? 'locked' : 'normal';
        updateStatus({ id: record.id, status: newStatus })
          .then(() => {
            window['$message'].success(`${statusText}成功`);
            reloadTable();
          })
          .catch(() => {
            window['$message'].error(`${statusText}失败`);
          });
      },
      onNegativeClick: () => {},
    });
  }

  function handleSubmit(values: Recordable) {
    console.log(values);
    reloadTable();
  }

  function handleReset(values: Recordable) {
    console.log(values);
  }
</script>

<style lang="less" scoped></style>

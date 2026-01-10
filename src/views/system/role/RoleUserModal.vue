<template>
  <basicModal @register="modalRegister" ref="modalRef" @on-ok="okModal" style="width: 700px">
    <div class="pt-5">
      <n-transfer
        v-model:value="targetKeys"
        :options="userOptions"
        virtual-scroll
        :source-filter-placeholder="'搜索用户'"
        filterable
      />
    </div>
  </basicModal>
</template>

<script lang="ts" setup>
  import { ref, unref } from 'vue';
  import { basicModal, useModal } from '@/components/Modal';
  import { getUserPageList } from '@/api/system/user';
  import { getRoleUserIds, updateRoleUsers } from '@/api/system/role';
  import { useMessage } from 'naive-ui';

  const emit = defineEmits(['reload']);
  const message = useMessage();
  const currentRoleId = ref(0);
  const targetKeys = ref<number[]>([]);
  const userOptions = ref<{ label: string; value: number }[]>([]);

  const [modalRegister, { openModal, closeModal, setSubLoading }] = useModal({
    title: '关联用户',
    subBtuText: '保存',
  });

  async function showModal(record: any) {
    currentRoleId.value = record.id;
    openModal();
    setSubLoading(true); // Loading while fetching data
    try {
      // 1. Fetch all users (Simulate fetching all by large page size)
      const userRes = await getUserPageList({ page: 1, pageSize: 10000 });
      // Depending on API structure, userRes might be { list: [], ... } or just []
      // Looking at user.vue: getUserPageList returns SysUserVO[] directly?
      // user.vue: const loadDataTable = async (res) => { return await getUserPageList({ ...getFieldsValue(), ...res }); };
      // api/system/user.ts: return Alova.Get<SysUserVO[]>...
      // Usually list APIs return { list, total } or just list.
      // I'll assume standard list for now, but I should check what user.vue receives.
      // Wait, BasicTable usually expects { list: [], total: 0 } or similar.
      // If Alova.Get<SysUserVO[]> implies it returns the array directly?
      // Let's check src/api/system/user.ts again.
      // It says: return Alova.Get<SysUserVO[]>('/sysUser/list', { params });

      const users = (userRes as any).list || userRes;

      userOptions.value = Array.isArray(users)
        ? users.map((u: any) => ({ label: u.username || u.realName, value: u.id }))
        : [];

      // 2. Fetch associated users
      const roleUsers = await getRoleUserIds(record.id);
      targetKeys.value = roleUsers || [];
    } catch (error) {
      console.error(error);
      message.error('数据加载失败');
    } finally {
      setSubLoading(false);
    }
  }

  async function okModal() {
    setSubLoading(true);
    try {
      await updateRoleUsers({ roleId: currentRoleId.value, userIds: targetKeys.value });
      message.success('保存成功');
      closeModal();
      emit('reload');
    } catch (error) {
      console.error(error);
      // message.error('保存失败'); // Global error handler might catch this
      setSubLoading(false);
    }
  }

  defineExpose({
    showModal,
  });
</script>

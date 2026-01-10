-- 清空现有数据
TRUNCATE TABLE "public"."sys_menu" RESTART IDENTITY CASCADE;

-- 插入菜单数据
INSERT INTO "public"."sys_menu" ("id", "parent_id", "path", "name", "component", "redirect", "label", "subtitle", "icon", "type", "auth", "keep_alive", "is_hidden", "open_type", "sort_order", "active_menu") VALUES
-- Dashboard (100)
(100, NULL, '/dashboard', 'dashboard', 'LAYOUT', '/dashboard/console', 'Dashboard', NULL, 'DashboardOutlined', 1, NULL, true, false, 1, 0, NULL),
(101, 100, 'console', 'dashboard_console', '/dashboard/console/console', NULL, '主控台', NULL, NULL, 1, 'dashboard_console', true, false, 1, 0, NULL),
(102, 100, 'workplace', 'dashboard_workplace', '/dashboard/workplace/workplace', NULL, '工作台', NULL, NULL, 1, 'dashboard_workplace', true, false, 1, 0, NULL),

-- About (103)
(103, NULL, '/about', 'about', 'LAYOUT', NULL, '关于', NULL, 'ProjectOutlined', 1, NULL, true, false, 1, 10, 'about_index'),
(104, 103, 'index', 'about_index', '/about/index', NULL, '关于项目', NULL, NULL, 1, NULL, true, false, 1, 0, 'about_index'),

-- Comp (105)
(105, NULL, '/comp', 'comp', 'LAYOUT', '/comp/table', '组件示例', NULL, 'WalletOutlined', 1, NULL, true, false, 1, 8, NULL),
(106, 105, 'table', 'comp_table', 'LAYOUT', '/comp/table/basic', '表格', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(107, 106, 'basic', 'comp_table_basic', '/comp/table/basic', NULL, '基础表格', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(108, 106, 'editCell', 'comp_table_editCell', '/comp/table/editCell', NULL, '单元格编辑', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(109, 106, 'editRow', 'comp_table_editRow', '/comp/table/editRow', NULL, '整行编辑', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(110, 105, 'form', 'comp_form', 'LAYOUT', '/comp/form/basic', '表单', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(111, 110, 'basic', 'comp_form_basic', '/comp/form/basic', NULL, '基础使用', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(112, 110, 'useForm', 'useForm', '/comp/form/useForm', NULL, 'useForm', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(113, 105, 'upload', 'comp_upload', '/comp/upload/index', NULL, '上传图片', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(114, 105, 'modal', 'comp_modal', '/comp/modal/index', NULL, '弹窗扩展', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(115, 105, 'richtext', 'richtext', '/comp/richtext/vue-quill', NULL, '富文本', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(116, 105, 'drag', 'Drag', '/comp/drag/index', NULL, '拖拽', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),

-- Directive (117)
(117, NULL, '/directive', 'directive', 'LAYOUT', NULL, '指令示例', NULL, 'BorderOuterOutlined', 1, NULL, true, false, 1, 9, 'directive_index'),
(118, 117, 'index', 'directive_index', '/directive/index', NULL, '指令示例', NULL, NULL, 1, NULL, true, false, 1, 0, 'directive_index'),

-- Docs (119)
(119, NULL, '/external', 'https://docs.naiveadmin.com', 'LAYOUT', NULL, '项目文档', NULL, 'DocumentTextOutline', 1, NULL, true, false, 2, 11, NULL),

-- Exception (120)
(120, NULL, '/exception', 'Exception', 'LAYOUT', '/exception/403', '异常页面', NULL, 'ExclamationCircleOutlined', 1, NULL, true, false, 1, 3, NULL),
(121, 120, '403', 'exception-403', '/exception/403', NULL, '403', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(122, 120, '404', 'exception-404', '/exception/404', NULL, '404', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(123, 120, '500', 'exception-500', '/exception/500', NULL, '500', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),

-- Form (124)
(124, NULL, '/form', 'Form', 'LAYOUT', '/form/basic-form', '表单页面', NULL, 'ProfileOutlined', 1, NULL, true, false, 1, 3, NULL),
(125, 124, 'basic-form', 'form-basic-form', '/form/basicForm/index', NULL, '基础表单', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(126, 124, 'step-form', 'form-step-form', '/form/stepForm/stepForm', NULL, '分步表单', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(127, 124, 'detail', 'form-detail', '/form/detail/index', NULL, '表单详情', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),

-- Frame (128)
(128, NULL, '/frame', 'Frame', 'LAYOUT', '/frame/docs', '外部页面', NULL, 'DesktopOutline', 1, NULL, true, false, 1, 8, NULL),
(129, 128, 'naive-admin', 'naive-admin', '/iframe/index', NULL, 'NaiveAdmin', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(130, 128, 'docs', 'frame-docs', '/iframe/index', NULL, '项目文档(内嵌)', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(131, 128, 'naive', 'frame-naive', '/iframe/index', NULL, 'NaiveUi(内嵌)', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),

-- List (132)
(132, NULL, '/list', 'List', 'LAYOUT', '/list/basic-list', '列表页面', NULL, 'TableOutlined', 1, NULL, true, false, 1, 2, NULL),
(133, 132, 'basic-list', 'basic-list', '/list/basicList/index', NULL, '基础列表', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(134, 132, 'basic-info/:id?', 'basic-info', '/list/basicList/info', NULL, '基础详情', NULL, NULL, 1, NULL, true, true, 1, 0, 'basic-list'),

-- NewVersion (135)
(135, NULL, '/newversion', 'https://www.naiveadmin.com', 'LAYOUT', NULL, 'Plus 版本', NULL, 'SketchOutlined', 1, NULL, true, false, 2, 12, NULL),

-- Result (136)
(136, NULL, '/result', 'Result', 'LAYOUT', '/result/success', '结果页面', NULL, 'CheckCircleOutlined', 1, NULL, true, false, 1, 4, NULL),
(137, 136, 'success', 'result-success', '/result/success', NULL, '成功页', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(138, 136, 'fail', 'result-fail', '/result/fail', NULL, '失败页', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(139, 136, 'info', 'result-info', '/result/info', NULL, '信息页', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),

-- Setting (140)
(140, NULL, '/setting', 'Setting', 'LAYOUT', '/setting/account', '设置页面', NULL, 'SettingOutlined', 1, NULL, true, false, 1, 5, NULL),
(141, 140, 'account', 'setting-account', '/setting/account/account', NULL, '个人设置', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(142, 140, 'system', 'setting-system', '/setting/system/system', NULL, '系统设置', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),

-- System (143)
(143, NULL, '/system', 'System', 'LAYOUT', '/system/menu', '系统设置', NULL, 'OptionsSharp', 1, NULL, true, false, 1, 1, NULL),
(144, 143, 'user', 'system_user', '/system/user/user', NULL, '用户管理', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(145, 143, 'menu', 'system_menu', '/system/menu/menu', NULL, '菜单权限', NULL, NULL, 1, NULL, true, false, 1, 0, NULL),
(146, 143, 'role', 'system_role', '/system/role/role', NULL, '角色权限', NULL, NULL, 1, NULL, true, false, 1, 0, NULL);

-- 更新序列值
SELECT setval('sys_menu_id_seq', (SELECT MAX(id) FROM sys_menu));

-- 关联角色 (超级管理员)
INSERT INTO "public"."sys_role_menu" ("role_id", "menu_id") 
SELECT 1, id FROM "public"."sys_menu";

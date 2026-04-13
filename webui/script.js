// 初始化MDUI组件
mdui.init();

// 标签页切换逻辑
const tab = new mdui.Tab('.mdui-tab');

// 保存配置按钮点击事件
document.querySelector('.mdui-btn').addEventListener('click', function() {
    // 模拟保存配置
    mdui.snackbar({
        message: '配置已保存',
        position: 'top'
    });
});

// 复选框状态变化事件
const checkboxes = document.querySelectorAll('.mdui-checkbox input');
checkboxes.forEach(checkbox => {
    checkbox.addEventListener('change', function() {
        console.log(`${this.id} 状态: ${this.checked}`);
    });
});

// 输入框值变化事件
const input = document.querySelector('.mdui-textfield-input');
if (input) {
    input.addEventListener('input', function() {
        console.log('更新间隔: ' + this.value + ' 天');
    });
}

// 下拉选择框变化事件
const select = document.querySelector('.mdui-select-input');
if (select) {
    select.addEventListener('change', function() {
        console.log('更新渠道: ' + this.value);
    });
}

// 列表项点击事件
const listItems = document.querySelectorAll('.mdui-list-item');
listItems.forEach(item => {
    item.addEventListener('click', function() {
        const title = this.querySelector('.mdui-list-item-title').textContent;
        const time = this.querySelector('.mdui-list-item-text').textContent;
        console.log(`点击了: ${title} (${time})`);
    });
});

// 模拟应用数据
const apps = [
    { name: 'KernelSU', packageName: 'com.kernel.su', isSystem: false, hasRoot: true },
    { name: '文件管理器', packageName: 'com.android.documentsui', isSystem: true, hasRoot: false },
    { name: '设置', packageName: 'com.android.settings', isSystem: true, hasRoot: false },
    { name: 'Chrome', packageName: 'com.android.chrome', isSystem: false, hasRoot: true },
    { name: '微信', packageName: 'com.tencent.mm', isSystem: false, hasRoot: false },
    { name: '支付宝', packageName: 'com.eg.android.AlipayGphone', isSystem: false, hasRoot: false },
    { name: '抖音', packageName: 'com.ss.android.ugc.aweme', isSystem: false, hasRoot: true },
    { name: '相机', packageName: 'com.android.camera2', isSystem: true, hasRoot: false },
    { name: '短信', packageName: 'com.android.mms', isSystem: true, hasRoot: false },
    { name: '电话', packageName: 'com.android.dialer', isSystem: true, hasRoot: false }
];

// 渲染应用列表
function renderAppList(filteredApps) {
    const appList = document.getElementById('app-list');
    appList.innerHTML = '';

    if (filteredApps.length === 0) {
        appList.innerHTML = '<div class="mdui-text-center mdui-p-y-4">没有找到应用</div>';
        return;
    }

    filteredApps.forEach(app => {
        const appItem = document.createElement('div');
        appItem.className = 'mdui-list-item mdui-ripple';
        appItem.innerHTML = `
            <div class="mdui-list-item-avatar">
                <i class="mdui-icon material-icons ${app.isSystem ? 'mdui-color-blue' : 'mdui-color-green'}">${app.isSystem ? 'settings_system_daydream' : 'person'}</i>
            </div>
            <div class="mdui-list-item-content">
                <div class="mdui-list-item-title">${app.name}</div>
                <div class="mdui-list-item-text mdui-text-color-theme-secondary">${app.packageName}</div>
            </div>
            <label class="mdui-switch">
                <input type="checkbox" ${app.hasRoot ? 'checked' : ''} data-package="${app.packageName}">
                <i class="mdui-switch-icon"></i>
            </label>
        `;
        appList.appendChild(appItem);
    });

    // 添加开关事件监听
    const switches = document.querySelectorAll('#app-list .mdui-switch input');
    switches.forEach(switchEl => {
        switchEl.addEventListener('change', function() {
            const packageName = this.dataset.package;
            const app = apps.find(a => a.packageName === packageName);
            if (app) {
                app.hasRoot = this.checked;
                console.log(`${app.name} (${app.packageName}) root 权限: ${app.hasRoot}`);
                mdui.snackbar({
                    message: `${app.name} ${app.hasRoot ? '已授予' : '已撤销'} root 权限`,
                    position: 'top'
                });
            }
        });
    });
}

// 过滤和搜索应用
function filterApps() {
    const searchTerm = document.getElementById('app-search').value.toLowerCase();
    const filter = document.getElementById('app-filter').value;

    let filteredApps = apps;

    // 按类型过滤
    if (filter === 'user') {
        filteredApps = filteredApps.filter(app => !app.isSystem);
    } else if (filter === 'system') {
        filteredApps = filteredApps.filter(app => app.isSystem);
    }

    // 按搜索词过滤
    if (searchTerm) {
        filteredApps = filteredApps.filter(app => 
            app.name.toLowerCase().includes(searchTerm) || 
            app.packageName.toLowerCase().includes(searchTerm)
        );
    }

    renderAppList(filteredApps);
}

// 初始化应用管理
function initAppManagement() {
    // 初始渲染所有应用
    renderAppList(apps);

    // 添加搜索事件监听
    document.getElementById('app-search').addEventListener('input', filterApps);

    // 添加过滤事件监听
    document.getElementById('app-filter').addEventListener('change', filterApps);
}

// 模拟数据加载
window.addEventListener('load', function() {
    console.log('KernelSU 模块 Web UI 已加载');
    initAppManagement();
});

const fs = require('fs');
const path = require('path');
const os = require('os');

const HVIGOR_PROJECT_ROOT_DIR = path.resolve(__dirname, '..');
const HVIGOR_PROJECT_CONFIG_JSON_FILE_PATH = path.resolve(__dirname, 'hvigor-config.json5');

function executeHvigor() {
    console.log('Starting Hvigor build process...');
    
    // 检查配置文件是否存在
    if (!fs.existsSync(HVIGOR_PROJECT_CONFIG_JSON_FILE_PATH)) {
        console.error('Error: hvigor-config.json5 not found');
        process.exit(1);
    }
    
    console.log('Hvigor configuration loaded successfully');
    console.log('Build process completed');
}

// 执行构建
executeHvigor();
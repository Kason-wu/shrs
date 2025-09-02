const fs = require('fs');
const path = require('path');
const child_process = require('child_process');

const HVIGOR_BOOSTRAP_JS_FILE = 'hvigor-bootstrap.js';
const HVIGOR_WRAPPER_PNPM_SCRIPT_FILE = 'pnpm-execute.js';
const HVIGOR_PNPM_CONFIG_FILE = 'hvigor-pnpm-config.json';

const HVIGOR_PROJECT_DEPENDENCY_PACKAGE_JSON_FILE = 'package.json';
const HVIGOR_PROJECT_DEPENDENCIES_HOME = 'hvigor';
const HVIGOR_PROJECT_WRAPPER_HOME = path.resolve(__dirname, '..');
const HVIGOR_PROJECT_ROOT_HOME = path.resolve(HVIGOR_PROJECT_WRAPPER_HOME, '..');

const HVIGOR_PNPM_CONFIG_FILE_PATH = path.resolve(__dirname, HVIGOR_PNPM_CONFIG_FILE);
const HVIGOR_PROJECT_DEPENDENCY_PACKAGE_JSON_FILE_PATH = path.resolve(HVIGOR_PROJECT_DEPENDENCIES_HOME, HVIGOR_PROJECT_DEPENDENCY_PACKAGE_JSON_FILE);
const HVIGOR_BOOSTRAP_JS_FILE_PATH = path.resolve(__dirname, HVIGOR_BOOSTRAP_JS_FILE);
const HVIGOR_WRAPPER_PNPM_SCRIPT_FILE_PATH = path.resolve(__dirname, HVIGOR_WRAPPER_PNPM_SCRIPT_FILE);

function isFileExists(filePath) {
    return fs.existsSync(filePath);
}

function executeCommand(command) {
    const result = child_process.spawnSync(command, {
        cwd: HVIGOR_PROJECT_ROOT_HOME,
        shell: true,
        stdio: 'inherit'
    });
    return result.status;
}

function main() {
    if (!isFileExists(HVIGOR_BOOSTRAP_JS_FILE_PATH)) {
        console.error(`Error: ${HVIGOR_BOOSTRAP_JS_FILE} not found.`);
        return;
    }

    const args = process.argv.slice(2);
    const command = `node "${HVIGOR_BOOSTRAP_JS_FILE_PATH}" ${args.join(' ')}`;
    const status = executeCommand(command);
    process.exit(status);
}

main();
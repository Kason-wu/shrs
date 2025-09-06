@echo off
echo ========================================
echo 修复 Windows DevEco Studio 构建问题
echo ========================================

echo.
echo 1. 清理项目缓存...
if exist ".hvigor" (
    rmdir /s /q ".hvigor"
    echo    已删除 .hvigor 目录
)

if exist "node_modules" (
    rmdir /s /q "node_modules"
    echo    已删除 node_modules 目录
)

if exist "entry\node_modules" (
    rmdir /s /q "entry\node_modules"
    echo    已删除 entry\node_modules 目录
)

echo.
echo 2. 重新安装依赖...
call ohpm install
if %errorlevel% neq 0 (
    echo    ohpm install 失败，尝试使用 npm...
    call npm install
)

echo.
echo 3. 进入 entry 目录安装依赖...
cd entry
call ohpm install
if %errorlevel% neq 0 (
    echo    entry ohpm install 失败，尝试使用 npm...
    call npm install
)
cd ..

echo.
echo 4. 清理构建缓存...
call hvigorw clean
if %errorlevel% neq 0 (
    echo    hvigorw clean 失败，尝试直接调用...
    node hvigor\hvigor-wrapper.js clean
)

echo.
echo 5. 验证配置文件...
if not exist "build-profile.json5" (
    echo    错误: build-profile.json5 文件不存在
    goto :error
)

if not exist "hvigorfile.ts" (
    echo    错误: hvigorfile.ts 文件不存在
    goto :error
)

if not exist "oh-package.json5" (
    echo    错误: oh-package.json5 文件不存在
    goto :error
)

echo    配置文件验证通过

echo.
echo 6. 尝试构建项目...
call hvigorw assembleHap
if %errorlevel% neq 0 (
    echo    构建失败，请检查 DevEco Studio 配置
    goto :error
)

echo.
echo ========================================
echo 修复完成！项目应该可以在 DevEco Studio 中正常运行
echo ========================================
echo.
echo 接下来的步骤:
echo 1. 在 DevEco Studio 中重新打开项目
echo 2. 等待项目同步完成
echo 3. 如果仍有问题，请检查 DEVECO_SETUP.md 文档
echo.
pause
goto :end

:error
echo.
echo ========================================
echo 修复过程中出现错误！
echo ========================================
echo.
echo 请检查以下项目:
echo 1. DevEco Studio 版本是否为 5.0.3.900 或更高
echo 2. HarmonyOS SDK API 12 是否已安装
echo 3. Node.js 版本是否为 16.x 或更高
echo 4. 网络连接是否正常
echo.
echo 详细说明请参考 DEVECO_SETUP.md 文档
echo.
pause

:end
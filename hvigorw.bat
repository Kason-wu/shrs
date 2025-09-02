@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  Hvigor startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and HVIGOR_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS="-Xmx4g" "-XX:+HeapDumpOnOutOfMemoryError"

@rem Find node.exe
if defined NODE_HOME goto findNodeFromNodeHome

set NODE_EXE=node.exe
%NODE_EXE% --version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto execute

echo.
echo ERROR: Node.js is not installed or not in PATH.
echo.
echo Please install Node.js and ensure it's in your PATH.
echo.

goto fail

:findNodeFromNodeHome
set NODE_HOME=%NODE_HOME:"=%
set NODE_EXE=%NODE_HOME%\node.exe

if exist "%NODE_EXE%" goto execute

echo.
echo ERROR: NODE_HOME is set to an invalid directory: %NODE_HOME%
echo.
echo Please set the NODE_HOME variable in your environment to match the
echo location of your Node.js installation.
echo.

goto fail

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\hvigor\hvigor-wrapper.js

@rem Execute Hvigor
"%NODE_EXE%" "%CLASSPATH%" %*

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable HVIGOR_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%HVIGOR_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
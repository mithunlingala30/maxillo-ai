@echo off
:: ============================================================
:: MaxilloAI – Run All Test Suites
:: ============================================================
:: Usage: Double-click OR run from terminal:
::   cd "app testing"
::   run_all_tests.bat
:: ============================================================

setlocal
cd /d "%~dp0"

echo.
echo ============================================================
echo   MaxilloAI Test Suite Runner
echo ============================================================
echo.

:: ---------- Check Python ----------
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Install Python 3.8+ and try again.
    pause
    exit /b 1
)

:: ---------- Install dependencies ----------
echo [1/4] Installing dependencies...
pip install -r requirements.txt --quiet
echo       Done.
echo.

:: ---------- Selenium E2E ----------
echo [2/4] Running Selenium E2E Tests (300 cases)...
echo       Output: selenium_results.xlsx
echo ---------------------------------------------------------------
python selenium_e2e_test.py
echo.

:: ---------- Appium ----------
echo [3/4] Running Appium Mobile Tests (300 cases)...
echo       Output: appium_results.xlsx
echo       Note: Tests will SKIP if Appium server is not running.
echo ---------------------------------------------------------------
python appium_test.py
echo.

:: ---------- Load Tests ----------
echo [4/4] Running Load Tests (300 cases)...
echo       Output: load_test_results.xlsx
echo       Target: https://gemini-jy64.onrender.com
echo ---------------------------------------------------------------
python load_test.py
echo.

:: ---------- Summary ----------
echo ============================================================
echo   All test suites complete!
echo.
echo   Results saved in this folder:
echo     selenium_results.xlsx
echo     appium_results.xlsx
echo     load_test_results.xlsx
echo ============================================================
echo.
pause

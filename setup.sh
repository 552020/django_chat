#!/bin/bash

# Exit script on any error
set -e

echo "Setting up the environment for testing..."

# Step 1: Install Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Step 2: Install WebDriver Manager to manage ChromeDriver
echo "Installing WebDriver Manager..."
pip install webdriver-manager

# Step 3: Check if Google Chrome is installed (macOS and Linux)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if ! [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
        echo "Google Chrome could not be found on macOS. Please install Chrome from: https://www.google.com/chrome/"
        exit 1
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if ! command -v google-chrome &> /dev/null && ! command -v chrome &> /dev/null; then
        echo "Google Chrome could not be found on Linux. Please install Chrome from: https://www.google.com/chrome/"
        exit 1
    fi
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Step 4: Install ChromeDriver via WebDriver Manager
echo "Installing ChromeDriver via WebDriver Manager..."
python -c "from webdriver_manager.chrome import ChromeDriverManager; ChromeDriverManager().install()"

echo "Setup complete! You can now run your tests using 'python manage.py test'."

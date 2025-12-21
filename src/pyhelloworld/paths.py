#!/usr/bin/env python3
"""
Path resolution utility for PyInstaller applications.
This module handles path resolution for both development and bundled environments.
"""

import sys
from pathlib import Path


def get_resource_path(relative_path: str) -> Path:
    """
    Get the absolute path to a resource file.
    
    Works in both development and PyInstaller-bundled environments:
    - Development: Uses relative paths from project root
    - PyInstaller: Uses paths relative to the bundle directory
    
    Args:
        relative_path: Relative path to the resource file
        
    Returns:
        Path: Absolute path to the resource file
    """
    # Check if we're running in a PyInstaller bundle
    if getattr(sys, 'frozen', False):
        # We're running in a PyInstaller bundle
        # _MEIPASS is the temporary directory where PyInstaller extracts files
        # Use getattr to avoid static type checking errors
        meipass_path = getattr(sys, '_MEIPASS', None)
        if meipass_path:
            base_path = Path(meipass_path)
        else:
            # Fallback for edge cases
            base_path = Path(sys.executable).parent
    else:
        # We're running in development mode
        # Get the project root directory (4 levels up from this file)
        base_path = Path(__file__).parent.parent.parent
    
    # Resolve the relative path against the base path
    return (base_path / relative_path).resolve()


def get_data_path(filename: str) -> Path:
    """
    Get the path to a data file.
    
    Args:
        filename: Name of the data file
        
    Returns:
        Path: Absolute path to the data file
    """
    if is_bundled():
        # In PyInstaller bundle, data files are placed at the root
        return get_resource_path(filename)
    else:
        # In development, data files are in the data/ directory
        return get_resource_path(f'data/{filename}')


def is_bundled() -> bool:
    """
    Check if the application is running in a PyInstaller bundle.
    
    Returns:
        bool: True if bundled, False if in development
    """
    return getattr(sys, 'frozen', False)


def get_application_directory() -> Path:
    """
    Get the directory where the application is located.
    
    Returns:
        Path: Application directory path
    """
    if is_bundled():
        return Path(sys.executable).parent
    else:
        return Path(__file__).parent.parent.parent


if __name__ == "__main__":
    # Test the path resolution
    print(f"Running bundled: {is_bundled()}")
    print(f"Application directory: {get_application_directory()}")
    print(f"Data path: {get_data_path('data.txt')}")
    
    # Test if the data file exists
    data_path = get_data_path('data.txt')
    if data_path.exists():
        print(f"Data file found at: {data_path}")
        print(f"Data content: {data_path.read_text().strip()}")
    else:
        print(f"Data file not found at: {data_path}")
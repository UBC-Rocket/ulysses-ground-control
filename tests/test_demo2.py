import pytest
import sys
import subprocess

def test_answer():
    print("test 2")
    
def main():
    try:
        x = 1/0
    except ZeroDivisionError:
        print("Should not have divided")
        raise


if __name__ == "__main__":
    main()
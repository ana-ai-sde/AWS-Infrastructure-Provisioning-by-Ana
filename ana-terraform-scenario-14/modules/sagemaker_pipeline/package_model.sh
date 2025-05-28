#!/bin/bash

# Create a temporary directory
mkdir -p model_package
cp inference.py model_package/

# Create tar.gz archive
cd model_package
tar -czf ../model.tar.gz *
cd ..

# Clean up
rm -rf model_package
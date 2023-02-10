mkdir -p dist/nodejs
cp package.json dist/nodejs
cd dist/nodejs
npm install
cd ..
zip -r ../periodic-care-package-layer.zip nodejs
cd ..
rm -rf dist
New-Item -Path ./dist/nodejs -ItemType Directory
Copy-Item "package.json" -Destination "dist/nodejs"
cd dist/nodejs
npm install
cd ..
Compress-Archive -Path .\nodejs -DestinationPath ../periodic-care-package-layer.zip
cd ..
Remove-Item "./dist" -Recurse

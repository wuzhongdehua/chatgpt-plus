#!/bin/bash

version=$1
# build go api
cd ../api/go
make clean linux

# build web app
cd ../../web
npm run build

cd ../docker

# remove docker image if exists
docker rmi registry.cn-hangzhou.aliyuncs.com/geekmaster/chatgpt-plus-go:$version
docker rmi chatgpt-plus-go:$version
# build docker image for chatgpt-plus-go
docker build -t chatgpt-plus-go:$version -f dockerfile-api-go ../

# build docker image for chatgpt-plus-vue
docker rmi registry.cn-hangzhou.aliyuncs.com/geekmaster/chatgpt-plus-vue:$version
docker rmi chatgpt-plus-vue:$version
docker build -t chatgpt-plus-vue:$version -f dockerfile-vue ../

# add tag for aliyum docker registry
goImageId=`docker images |grep chatgpt-plus-go |grep $version |awk '{print $3}'`
docker tag $goImageId registry.cn-hangzhou.aliyuncs.com/geekmaster/chatgpt-plus-go:$version
echo $goImageId
vueImageId=`docker images |grep chatgpt-plus-vue |grep $version |awk '{print $3}'`
echo $vueImageId
docker tag $vueImageId registry.cn-hangzhou.aliyuncs.com/geekmaster/chatgpt-plus-vue:$version


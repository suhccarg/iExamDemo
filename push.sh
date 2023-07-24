#!/bin/bash

cmd=`basename ${0}`
if [ $# -lt 2 ] 
then
	echo usage: $cmd tag remark
	git log --all --graph --oneline  -n 10
	exit 1
fi

tag=${1}
remark=${2}

echo "$tag $remark" >> README.md
echo -e "\n## add" 
git add .
if [ $? -ne 0 ] 
then
	exit 13
fi
echo -e "\n##" commit "$tag  $remark" 
git commit -m "$tag $remark" 
## git commit --amend -m "$tag $remark" 
if [ $? -ne 0 ] 
then
	exit 14
fi
echo -e "\n##" tag $tag
git tag $tag
if [ $? -ne 0 ] 
then
	exit 15
fi
##########################
echo -e "\n##" push
git push origin main
if [ $? -ne 0 ] 
then
	exit 16
fi
echo -e "\n##" push tag
git push origin --tags
if [ $? -ne 0 ] 
then
	exit 17
fi
echo -e "\n##" Success! 
exit 0

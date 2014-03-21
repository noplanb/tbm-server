rsync -av -C --rsh 'ssh -i aws-micro.pem -l threebyme' \
  --exclude-from=exclude_from_deploy.txt \
  --delete ./ threebyme.com:server/
ssh -i aws-micro.pem threebyme@threebyme.com 'touch server/tmp/restart.txt'

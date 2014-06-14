# Can't add the --delete flag because it removes the production database
# Need to add the database to mysql
rsync -av -C --rsh 'ssh -l threebyme' \
  --exclude-from=exclude_from_deploy.txt \
  ./ threebyme.com:server/
ssh threebyme@threebyme.com 'touch server/tmp/restart.txt'

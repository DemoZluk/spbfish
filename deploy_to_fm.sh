ask_yn () {
  question=$1
  func=$2
  while true; do
      read -p "$question [y/n]: " yn
      case $yn in
          [Yy]* ) eval ${func}; break;;
          [Nn]* ) echo "Skipping..."; break;;
          * ) echo "Please answer yes or no.";;
      esac
  done
}

add () {
  git add -A
}

commit () {
  git commit
}

push () {
  git push fishmarkt master
}

deploy () {
  echo "Stopping apache2 to preserve resources"
  ssh -t fish@fishmarkt.ru "sudo service apache2 stop"
  cap production deploy

  echo "Starting apache2 again"
  ssh -t fish@fishmarkt.ru "sudo service apache2 start"

  echo "Restarting rails app"
  ssh fish@fishmarkt.ru "touch /home/fish/www/fishmarkt/current/tmp/restart.txt"
}

git status

ask_yn "Add ALL changes?" add
ask_yn "Commit changes?" commit
ask_yn "Push changes to repo?" push
ask_yn "Deploy to fishmarkt?" deploy


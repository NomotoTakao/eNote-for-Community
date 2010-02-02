export PATH=$PATH:/usr/local/pgsql/bin:/usr/local/pgsql/lib
export LD_LIBRARY_PATH=/usr/local/pgsql/lib

cd /app/gw/rails/enote

/usr/local/bin/ruby /app/gw/rails/enote/send_reminder_mail.rb

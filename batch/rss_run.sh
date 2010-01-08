export PATH=$PATH:/usr/local/pgsql/bin:/usr/local/pgsql/lib
export LD_LIBRARY_PATH=/usr/local/pgsql/lib

cd /app/rails/enote

/usr/local/bin/ruby /app/rails/enote/rss2.rb


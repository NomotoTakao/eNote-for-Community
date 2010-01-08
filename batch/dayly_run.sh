export PATH=$PATH:/usr/local/pgsql/bin:/usr/local/pgsql/lib
export LD_LIBRARY_PATH=/usr/local/pgsql/lib

export ORACLE_HOME=/usr/lib/oracle/11.1/client
export PATH=${ORACLE_HOME}/bin:${PATH}
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${LD_LIBRARY_PATH}
export SQLPATH=/usr/lib/oracle/11.1/client/lib:${SQLPATH}
export TNS_ADMIN=${ORACLE_HOME}/lib
export NLS_LANG=japanese_japan.al32utf8

cd /app/gw/rails/enote

/usr/local/bin/ruby /app/gw/rails/enote/get_web_nippo.rb
/usr/local/bin/ruby /app/gw/rails/enote/send_reminder_mail.rb

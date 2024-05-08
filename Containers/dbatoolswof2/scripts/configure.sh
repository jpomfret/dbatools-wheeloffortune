# loop until sql server is up and ready
for i in {1..50};
do
    sqlcmd -S localhost -d master -Q "SELECT @@VERSION"
    if [ $? -ne 0 ];then
        sleep 2
    fi
done

# create sqladmin with dbatools.IO password and disable sa
sqlcmd -S localhost -d master -i /tmp/create-admin.sql

# change the default login to sqladmin instead of sa
export SQLCMDUSER=sqladmin

# create QALogin and database for refresh demo
sqlcmd -S localhost -d master -i /tmp/create-dbtorefresh.sql

# rename the server 
sqlcmd -d master -Q "EXEC sp_dropserver @@SERVERNAME"
sqlcmd -S localhost -d master -Q "EXEC sp_addserver 'dbatools2', local"

# import the certificate and creates endpoint 
sqlcmd -S localhost -d master -i /tmp/create-endpoint.sql
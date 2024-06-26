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

sqlcmd -d master -Q "EXEC sp_dropserver @@SERVERNAME"

sqlcmd -S localhost -d master -Q "EXEC sp_addserver 'dbatools1', local"
# Download instead of including it in the repo -- it reduces 
# the size of the context and makes the secondary image smaller
wget https://github.com/sqlcollaborative/docker/raw/a61d8e1ffb150cae767c27737ad07e730d4e76dd/sqlinstance/sql/northwind.bak
wget https://github.com/sqlcollaborative/docker/raw/a61d8e1ffb150cae767c27737ad07e730d4e76dd/sqlinstance/sql/pubs.bak
sqlcmd -S localhost -d master -i /tmp/restore-db.sql
sqlcmd -S localhost -d master -i /tmp/create-objects.sql
sqlcmd -S localhost -d master -i /tmp/create-regserver.sql

# import the certificate and creates endpoint 
sqlcmd -S localhost -d master -i /tmp/create-endpoint.sql
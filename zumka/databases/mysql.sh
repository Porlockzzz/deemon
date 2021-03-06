#/bin/bash
# This file is part of Deemon.

# Deemon is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Deemon is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Deemon.  If not, see <http://www.gnu.org/licenses/>.


mount_point=$1
bitnami_tool_dir=$2
target_host_ip=$3
bitnami_outgoing_port=$4
bitnami_startup_script=$5
bitnami_database_port=$6
bitnami_mysql_configuration='opt/bitnami/mysql/my.cnf'
bitnami_mysql_start_script='opt/bitnami/mysql/scripts/ctl.sh'


#change mysql configuration
sed -i "s/port=.*/port=${bitnami_database_port}/" $mount_point$bitnami_mysql_configuration

#change bitnami mysql configuration
sed -i "s/--socket=.* --/--/" $mount_point$bitnami_mysql_start_script

#apparently bitnami sometimes includes the port parameter to startup mysql
if grep --quiet port=3306 $mount_point$bitnami_mysql_start_script; then
    sed -i "s/--port=3306/--port=${bitnami_database_port}/" $mount_point$bitnami_mysql_start_script
fi

##append stuff to startup file
#delete any remaining mysql.sock
echo "rm /opt/bitnami/mysql/tmp/mysql.sock" >> $mount_point$bitnami_startup_script 
#tell socat to jump in
echo "/${bitnami_tool_dir}/socat UNIX-LISTEN:/opt/bitnami/mysql/tmp/mysql.sock,fork,user=mysql,group=mysql,mode=777 TCP:127.0.0.1:3306 &" >> $mount_point$bitnami_startup_script
#redirect traffic from port 3306 to host port 4444
echo "/${bitnami_tool_dir}/redir --lport=3306 --caddr=${target_host_ip} --cport=${bitnami_outgoing_port} &" >> $mount_point$bitnami_startup_script

exit

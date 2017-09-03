#!/bin/bash
# ------------------------------------------------------------------
# Make a new virtual host, a directory for it, a demo HTML file and restart apache
# ------------------------------------------------------------------

VERSION=0.1.0
USAGE="Usage: gogogadgetvirtualhost (hostname)"

# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
   echo $USAGE
   exit 1;
fi

if [[ $EUID -ne 0 ]]; then
   echo "Please only try to do this as root" 2>&1
   exit
fi
fake=false

while getopts ":i:vhf" optname
 do
   case "$optname" in
	 "v")
	   echo "Version $VERSION"
	   exit 0;
	   ;;
	 "f")
   echo "Faking!"
	   fake=true
	   ;;
	 "h")
	   echo $USAGE
	   exit 0;
	   ;;
	 "?")
	   echo "Unknown option $OPTARG"
	   exit 0;
	   ;;
	 ":")
	   echo "No argument value for option $OPTARG"
	   exit 0;
	   ;;
	 *)
	   echo "Unknown error while processing options"
	   exit 0;
	   ;;
   esac
 done

shift $(($OPTIND - 1))



hostname=$1

echo $fake

####################################    Make directories
dirname="/var/www/$hostname"
echo -n Creating the dir $dirname
echo -n \ andr $dirname/public_html...
if ! $fake
then
echo "JAAAH"
mkdir $dirname
mkdir $dirname/public_html
cat > $dirname/public_html/index.html <<TheEnd
<html>
<head>
<title>Coming soon</title>
</head>
<body>
<h1>Hello!</h1>
<p>This is a placeholder page for the domain $hostname.</p>
<p>Some day, this will be a beautiful website.</p>
<p>Stay tuned</p>
</body>
</html>
TheEnd
fi
echo -e "\e[7mDone!\e[0m"

#####################################     Setup VirtualHost
filename=/etc/apache2/sites-available/$hostname.conf

echo -n Writing site config to $filename...
if ! $fake
then
cat > $filename <<TheEnd
<VirtualHost *:80>
   ServerAdmin server@lessormore.nl
   ServerName $hostname
   DocumentRoot $dirname/public_html
   ErrorLog \${APACHE_LOG_DIR}/error.log
   CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
TheEnd
fi
echo -e "\e[7mDone!\e[0m"

echo -n Applying Apache host info...
if ! $fake
then
sudo a2ensite $hostname.conf
fi

echo -n Restarting Apache...
if ! $fake
then
sudo service apache2 restart
fi
echo -e "\e[7mDone!\e[0m"
echo Have fun using $hostname\!

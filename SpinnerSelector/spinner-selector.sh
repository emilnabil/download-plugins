#!/bin/bash
######################################################################################
## Command=wget https://raw.githubusercontent.com/emil237/SpinnerSelector/main/installer.sh -O - | /bin/sh
##
###########################################
###########################################

# my config script #

MY_TAR_PY2="SpinnerSelector_py2.tar.gz"
MY_TAR_PY3="SpinnerSelector_py3.tar.gz"
https://raw.githubusercontent.com/emil237/SpinnerSelector/main"
PYTHON_VERSION=$(python -c 'import sys; print(sys.version_info[0])')

######################################################################################
MY_EM='============================================================================================================'
#  Remove Old Plugin  #
echo "   >>>>   Remove old version   "

rm -r /usr/lib/enigma2/python/Plugins/Extensions/SpinnerSelector

#################################
    
###################
echo "============================================================================================================================"
 echo " DOWNLOAD AND INSTALL PLUGIN "

echo "   Install Plugin please wait "

cd /tmp 
set -e    
if python --version 2>&1 | grep -q '^Python 3\.'; then
  wget "$MY_URL/$MY_TAR_PY3"
sleep 2 
tar -xzf $MY_TAR_PY3 -C / 
rm -f /tmp/$MY_TAR_PY3
	else 
echo "   Install Plugin please wait "
   wget "$MY_URL/$MY_TAR_PY2"
sleep 2 
tar -xzf $MY_TAR_PY2 -C /
rm -f /tmp/$MY_TAR_PY2
	fi
echo "================================="
set +e
cd ..

	if [ $? -eq 0 ]; then
echo ">>>>  SUCCESSFULLY INSTALLED <<<<"
fi
		echo "********************************************************************************"
echo "   UPLOADED BY  >>>>   EMIL_NABIL " 
sleep 4;                         
echo $MY_EM
###################                                                                                                                  
echo " Your Device Will RESTART Now " 
echo "**********************************************************************************"
sleep 2 
exit 0






















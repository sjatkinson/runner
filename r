#!/bin/sh

#- r runs other shell scripts (or any executable) which are in the R_PATH

${R_PATH:?"R_PATH is not set"} 2>/dev/null

global_dir=${R_PATH}


function list_commands()
{
   ( IFS=:
      for p in $R_PATH
      do
         find $p -type f -perm +111 | sort | while read cmd
         do
            printf "\t%s\n" $(basename "$cmd")
         done
      done
   )
}

function usage() {
   #echo `head $0 | grep -v ^\#\! | grep ^\# | sed s/\#- r //`
   echo `basename $0` " - run other commands located in the R_PATH"
   echo ""
   echo "usage: $" `basename $0`-[avdh]
   echo ""
   echo "   Availabe commands:"
   list_commands 
}


# process cmdline.
cmd=""
for arg in "$@"
do
   shift
   if awk -v arg="$arg" 'BEGIN { if(arg ~ /^-/) { exit 0 } else { exit 1 } } '
   then
      if [ -z "$cmd" ]
      then
         case "$arg" in
            -help | --help | -h)
               usage
               exit 1;;
            -v) set -v;;
            -x) set -x;;
         esac
      fi
   else
      if [ -z "$cmd" ]
      then
         cmd=$arg
         break
      fi
   fi
done
if [ "$cmd" == "" ]
then
   usage
   exit 1
fi


found=0
IFS=:
for p in ${R_PATH}; do
   command=$p/$cmd
   if [ -x "$command" ] 
   then
      found=1
      $command $*
      break
   fi
done
if [ $found -eq 0 ]
then
   echo $cmd not found
   usage
fi
  


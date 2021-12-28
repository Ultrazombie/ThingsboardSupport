
list=$(rg --files | grep -i $@)
IFS=$'\n'
select file in $list 
   do test -n "$file" && break; 
exit; 
done
open "$file"
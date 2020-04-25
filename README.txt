$ find master/1/ -name "alife_l*" -exec sh -c "printf {}; grep -rI 'crow' {} | wc -l" \; | awk '{ print $2 "\t" $1 }' | sort -rn
$ rg -I -r \$1 "money = (.+)" master/1/ | sort -n | uniq -c

$ ruby parse.rb master/1/alife_l01_escape.ltx > l01_escape.yaml
$ ruby render.rb l01_1.yaml bg_l01.jpg l01_escape

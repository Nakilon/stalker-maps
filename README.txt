$ find master/1/ -name "alife_l*" -exec sh -c "printf {}; grep -rI 'crow' {} | wc -l" \; | awk '{ print $2 "\t" $1 }' | sort -rn
$ rg -I -r \$1 "money = (.+)" master/1/ | sort -n | uniq -c

$ ruby parse.rb master/1/alife_l01_escape.ltx > l01_escape/1.yaml
$ ruby parse.rb master/2/alife_l01_escape.ltx > l01_escape/2.yaml
$ ruby parse.rb master/3/alife_l01_escape.ltx > l01_escape/3.yaml
$ ruby parse.rb master/4/alife_l01_escape.ltx > l01_escape/4.yaml
$ ruby parse.rb master/5/alife_l01_escape.ltx > l01_escape/5.yaml
$ ruby parse.rb master/1/alife_l02_garbage.ltx > l02_garbage/1.yaml
$ ruby parse.rb master/2/alife_l02_garbage.ltx > l02_garbage/2.yaml
$ ruby parse.rb master/3/alife_l02_garbage.ltx > l02_garbage/3.yaml
$ ruby parse.rb master/4/alife_l02_garbage.ltx > l02_garbage/4.yaml
$ ruby parse.rb master/5/alife_l02_garbage.ltx > l02_garbage/5.yaml

$ ruby render_npcs.rb l01_escape/1.yaml l01_escape l01_escape/2.yaml
$ ruby render_mutants.rb l01_escape/1.yaml l01_escape
$ ruby render_anomalies.rb l01_escape/1.yaml l01_escape
$ ruby render_artifacts.rb l01_escape/1.yaml l01_escape
$ ruby render_npcs.rb l02_garbage/1.yaml l02_garbage l02_garbage/2.yaml
$ ruby render_mutants.rb l02_garbage/1.yaml l02_garbage
$ ruby render_anomalies.rb l02_garbage/1.yaml l02_garbage
$ ruby render_artifacts.rb l02_garbage/1.yaml l02_garbage
$ tree rendered

$ gsutil cp rendered/l01_escape_*.jpg gs://heavy.www.nakilon.pro/stalker_v3/
$ gsutil cp rendered/l02_garbage_*.jpg gs://heavy.www.nakilon.pro/stalker_v1/

v the most outdated code v
render_npcs.rb
render_mutants.rb
render_anomalies.rb
render_artifacts.rb
^ the least outdated code ^

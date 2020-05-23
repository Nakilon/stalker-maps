$ find master/1/ -name "alife_l*" -exec sh -c "printf {}; grep -rI 'crow' {} | wc -l" \; | awk '{ print $2 "\t" $1 }' | sort -rn
$ rg -I -r \$1 "money = (.+)" master/1/ | sort -n | uniq -c

$ ruby parse.rb master/1/alife_l01_escape.ltx > 1/l01_escape.yaml
$ ruby parse.rb master/2/alife_l01_escape.ltx > 2/l01_escape.yaml
$ ruby parse.rb master/3/alife_l01_escape.ltx > 3/l01_escape.yaml
$ ruby parse.rb master/4/alife_l01_escape.ltx > 4/l01_escape.yaml
$ ruby parse.rb master/5/alife_l01_escape.ltx > 5/l01_escape.yaml
$ ruby parse.rb master/1/alife_l02_garbage.ltx > 1/l02_garbage.yaml
$ ruby parse.rb master/2/alife_l02_garbage.ltx > 2/l02_garbage.yaml
$ ruby parse.rb master/3/alife_l02_garbage.ltx > 3/l02_garbage.yaml
$ ruby parse.rb master/4/alife_l02_garbage.ltx > 4/l02_garbage.yaml
$ ruby parse.rb master/5/alife_l02_garbage.ltx > 5/l02_garbage.yaml

$ ruby render_npcs.rb 1/l01_escape.yaml l01_escape
$ ruby render_mutants.rb 1/l01_escape.yaml l01_escape
$ ruby render_anomalies.rb 1/l01_escape.yaml l01_escape
$ ruby render_artifacts.rb 1/l01_escape.yaml l01_escape
$ ruby render_npcs.rb 1/l02_garbage.yaml l02_garbage
$ ruby render_mutants.rb 1/l02_garbage.yaml l02_garbage
$ ruby render_anomalies.rb 1/l02_garbage.yaml l02_garbage
$ ruby render_artifacts.rb 1/l02_garbage.yaml l02_garbage
$ tree rendered

v the most outdated code v
render_npcs.rb
render_mutants.rb
render_anomalies.rb
render_artifacts.rb
^ the least outdated code ^

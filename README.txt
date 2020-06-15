$ find master/1/ -name "alife_l*" -exec sh -c "printf {}; grep -rI 'crow' {} | wc -l" \; | awk '{ print $2 "\t" $1 }' | sort -rn
$ rg -I -r \$1 "money = (.+)" master/1/ | sort -n | uniq -c
$ rg -Np "section_name: (.+)" l04_darkvalley/1.yaml -r '$1' | sort | uniq -c | sort -nr | head

$ mkdir l01_escape
$ ruby parse.rb master/1/alife_l01_escape.ltx > l01_escape/1.yaml
$ ruby parse.rb master/2/alife_l01_escape.ltx > l01_escape/2.yaml
$ ruby parse.rb master/3/alife_l01_escape.ltx > l01_escape/3.yaml
$ ruby parse.rb master/4/alife_l01_escape.ltx > l01_escape/4.yaml
$ ruby parse.rb master/5/alife_l01_escape.ltx > l01_escape/5.yaml
$ mkdir l02_garbage
$ ruby parse.rb master/1/alife_l02_garbage.ltx > l02_garbage/1.yaml
$ ruby parse.rb master/2/alife_l02_garbage.ltx > l02_garbage/2.yaml
$ ruby parse.rb master/3/alife_l02_garbage.ltx > l02_garbage/3.yaml
$ ruby parse.rb master/4/alife_l02_garbage.ltx > l02_garbage/4.yaml
$ ruby parse.rb master/5/alife_l02_garbage.ltx > l02_garbage/5.yaml
$ mkdir l03_agroprom
$ ruby parse.rb master/1/alife_l03_agroprom.ltx > l03_agroprom/1.yaml
$ ruby parse.rb master/2/alife_l03_agroprom.ltx > l03_agroprom/2.yaml
$ ruby parse.rb master/3/alife_l03_agroprom.ltx > l03_agroprom/3.yaml
$ ruby parse.rb master/4/alife_l03_agroprom.ltx > l03_agroprom/4.yaml
$ ruby parse.rb master/5/alife_l03_agroprom.ltx > l03_agroprom/5.yaml
$ mkdir l03u_agr_underground
$ ruby parse.rb master/1/alife_l03u_agr_underground.ltx > l03u_agr_underground/1.yaml
$ ruby parse.rb master/2/alife_l03u_agr_underground.ltx > l03u_agr_underground/2.yaml
$ ruby parse.rb master/3/alife_l03u_agr_underground.ltx > l03u_agr_underground/3.yaml
$ ruby parse.rb master/4/alife_l03u_agr_underground.ltx > l03u_agr_underground/4.yaml
$ ruby parse.rb master/5/alife_l03u_agr_underground.ltx > l03u_agr_underground/5.yaml
$ mkdir l04_darkvalley
$ ruby parse.rb master/1/alife_l04_darkvalley.ltx > l04_darkvalley/1.yaml
$ ruby parse.rb master/2/alife_l04_darkvalley.ltx > l04_darkvalley/2.yaml
$ ruby parse.rb master/3/alife_l04_darkvalley.ltx > l04_darkvalley/3.yaml
$ ruby parse.rb master/4/alife_l04_darkvalley.ltx > l04_darkvalley/4.yaml
$ ruby parse.rb master/5/alife_l04_darkvalley.ltx > l04_darkvalley/5.yaml
$ mkdir l04u_labx18
$ ruby parse.rb master/1/alife_l04u_labx18.ltx > l04u_labx18/1.yaml
$ ruby parse.rb master/2/alife_l04u_labx18.ltx > l04u_labx18/2.yaml
$ ruby parse.rb master/3/alife_l04u_labx18.ltx > l04u_labx18/3.yaml
$ ruby parse.rb master/4/alife_l04u_labx18.ltx > l04u_labx18/4.yaml
$ ruby parse.rb master/5/alife_l04u_labx18.ltx > l04u_labx18/5.yaml
$ mkdir l05_bar
$ ruby parse.rb master/1/alife_l05_bar.ltx > l05_bar/1.yaml
$ ruby parse.rb master/2/alife_l05_bar.ltx > l05_bar/2.yaml
$ ruby parse.rb master/3/alife_l05_bar.ltx > l05_bar/3.yaml
$ ruby parse.rb master/4/alife_l05_bar.ltx > l05_bar/4.yaml
$ ruby parse.rb master/5/alife_l05_bar.ltx > l05_bar/5.yaml
$ mkdir l06_rostok
$ ruby parse.rb master/1/alife_l06_rostok.ltx > l06_rostok/1.yaml
$ ruby parse.rb master/2/alife_l06_rostok.ltx > l06_rostok/2.yaml
$ ruby parse.rb master/3/alife_l06_rostok.ltx > l06_rostok/3.yaml
$ ruby parse.rb master/4/alife_l06_rostok.ltx > l06_rostok/4.yaml
$ ruby parse.rb master/5/alife_l06_rostok.ltx > l06_rostok/5.yaml

$ bash ./render.sh
$ tree rendered
$ hash ./gsutil.sh

$ haml -q stalker.haml ../../www-nakilon-pro/www.nakilon.pro/stalker.htm

$ ruby debug.rb l04_darkvalley/1.yaml 4000x4000 l04_darkvalley/1.yaml l04_darkvalley/2.yaml l04_darkvalley/3.yaml l04_darkvalley/4.yaml l04_darkvalley/5.yaml 1500 5 1000 5 999 m_bloodsucker_e stalker bloodsucker_normal

v the most outdated code v
render_npcs.rb
render_mutants.rb
render_anomalies.rb
render_artifacts.rb
^ the least outdated code ^

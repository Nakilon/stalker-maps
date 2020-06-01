$ find master/1/ -name "alife_l*" -exec sh -c "printf {}; grep -rI 'crow' {} | wc -l" \; | awk '{ print $2 "\t" $1 }' | sort -rn
$ rg -I -r \$1 "money = (.+)" master/1/ | sort -n | uniq -c

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

$ ruby render_npcs.rb l01_escape/1.yaml l01_escape l01_escape/2.yaml
$ ruby render_mutants.rb l01_escape/1.yaml l01_escape
$ ruby render_anomalies.rb l01_escape/1.yaml l01_escape
$ ruby render_artifacts.rb l01_escape/1.yaml l01_escape l01_escape/1.yaml l01_escape/2.yaml l01_escape/3.yaml l01_escape/4.yaml l01_escape/5.yaml
$ ruby render_npcs.rb l02_garbage/1.yaml l02_garbage l02_garbage/2.yaml
$ ruby render_mutants.rb l02_garbage/1.yaml l02_garbage
$ ruby render_anomalies.rb l02_garbage/1.yaml l02_garbage
$ ruby render_artifacts.rb l02_garbage/1.yaml l02_garbage l02_garbage/1.yaml l02_garbage/2.yaml l02_garbage/3.yaml l02_garbage/4.yaml l02_garbage/5.yaml
$ ruby render_npcs.rb l03_agroprom/1.yaml l03_agroprom l03_agroprom/2.yaml
$ ruby render_mutants.rb l03_agroprom/1.yaml l03_agroprom
$ ruby render_anomalies.rb l03_agroprom/1.yaml l03_agroprom
$ ruby render_artifacts.rb l03_agroprom/1.yaml l03_agroprom l03_agroprom/1.yaml l03_agroprom/2.yaml l03_agroprom/3.yaml l03_agroprom/4.yaml l03_agroprom/5.yaml
$ ruby render_npcs.rb l03u_agr_underground/1.yaml l03u_agr_underground l03u_agr_underground/2.yaml
$ ruby render_mutants.rb l03u_agr_underground/1.yaml l03u_agr_underground
$ ruby render_anomalies.rb l03u_agr_underground/1.yaml l03u_agr_underground
$ ruby render_artifacts.rb l03u_agr_underground/1.yaml l03u_agr_underground l03u_agr_underground/1.yaml l03u_agr_underground/2.yaml l03u_agr_underground/3.yaml l03u_agr_underground/4.yaml l03u_agr_underground/5.yaml

$ tree rendered

$ gsutil cp rendered/l01_escape_anomalies.jpg gs://heavy.www.nakilon.pro/stalker_v4/
$ gsutil cp rendered/l01_escape_artifacts_eng.jpg gs://heavy.www.nakilon.pro/stalker_v5/
$ gsutil cp rendered/l01_escape_artifacts_rus.jpg gs://heavy.www.nakilon.pro/stalker_v5/
$ gsutil cp rendered/l01_escape_mutants_eng.jpg gs://heavy.www.nakilon.pro/stalker_v4/
$ gsutil cp rendered/l01_escape_mutants_rus.jpg gs://heavy.www.nakilon.pro/stalker_v4/
$ gsutil cp rendered/l01_escape_npcs.jpg gs://heavy.www.nakilon.pro/stalker_v4/
$ gsutil cp rendered/l02_garbage_anomalies.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l02_garbage_artifacts_eng.jpg gs://heavy.www.nakilon.pro/stalker_v5/
$ gsutil cp rendered/l02_garbage_artifacts_rus.jpg gs://heavy.www.nakilon.pro/stalker_v5/
$ gsutil cp rendered/l02_garbage_mutants_eng.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l02_garbage_mutants_rus.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l02_garbage_npcs.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l03_agroprom_anomalies.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l03_agroprom_artifacts_eng.jpg gs://heavy.www.nakilon.pro/stalker_v5/
$ gsutil cp rendered/l03_agroprom_artifacts_rus.jpg gs://heavy.www.nakilon.pro/stalker_v5/
$ gsutil cp rendered/l03_agroprom_mutants_eng.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l03_agroprom_mutants_rus.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l03_agroprom_npcs.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l03u_agr_underground_anomalies.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l03u_agr_underground_artifacts_eng.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l03u_agr_underground_artifacts_rus.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l03u_agr_underground_mutants_eng.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l03u_agr_underground_mutants_rus.jpg gs://heavy.www.nakilon.pro/stalker_v1/
$ gsutil cp rendered/l03u_agr_underground_npcs.jpg gs://heavy.www.nakilon.pro/stalker_v1/


v the most outdated code v
render_npcs.rb
render_mutants.rb
render_anomalies.rb
render_artifacts.rb
^ the least outdated code ^

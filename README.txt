                 OPENSOURCED IT AS A SIGN THAT I BELIEVE THAT
      S.T.A.L.K.E.R. RELATED MODDING AND OTHER DEVELOPMENT SHOULD BE OPEN

###############################################################################

Required files that are not in git (images, quicksaves, 1.0006 ww gamedata):
https://storage.googleapis.com/stalker-maps-heavy.nakilon.pro/

Credits:
* I took backgrounds from @dawnrazor73's amazing website
* thanks to /u/Zyhgar25 for CSS hint
* thanks to /u/plscome2brazil for NPC names hint

###############################################################################

(the rest of this file are technical notes that initially were not supposed
 to be in a public README so you don't immediately have to understand them)


$ find master/1/ -name "alife_l*" -exec sh -c "printf {}; grep -rI 'crow' {} | wc -l" \; | awk '{ print $2 "\t" $1 }' | sort -rn
$ rg -I -r \$1 "money = (.+)" master/1/ | sort -n | uniq -c
$ rg -Np "section_name: (.+)" l04_darkvalley/1.yaml -r '$1' | sort | uniq -c | sort -nr | head
$ rg -Np "section_name: (.+)" l0*/1.yaml -r '$1' | sort | uniq -c | sort -nr | grep stalker

$ bash ./parse.sh
$ bash ./render.sh
$ bash ./gsutil.sh && bash ./jpegsave.sh && gsutil -m rsync -r -c preview gs://heavy.www.nakilon.pro/stalker_preview
$ haml -q stalker.haml ../www-nakilon-pro/www.nakilon.pro/stalker.htm

$ ruby debug.rb l04_darkvalley/1.yaml 4000x4000 l04_darkvalley/1.yaml l04_darkvalley/2.yaml l04_darkvalley/3.yaml l04_darkvalley/4.yaml l04_darkvalley/5.yaml 1500 5 1000 5 999 m_bloodsucker_e stalker bloodsucker_normal
$ ruby render_dots.rb l04u_labx18/1.yaml l04u_labx18

v the most outdated code v
render_npcs.rb
render_mutants.rb
render_anomalies.rb
render_artifacts.rb
^ the least outdated code ^

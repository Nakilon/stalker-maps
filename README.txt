                 OPENSOURCED IT TO PROMOTE MY BELIEF THAT
    S.T.A.L.K.E.R. MODDING AND RELATED DEVELOPMENT AND REVERSE ENGINEERING
                      SHOULD BE OPEN AND ACCESSIBLE

##############################################################################

Required files that are not in git (images, quicksaves, 1.0006 ww gamedata):
https://storage.googleapis.com/stalker-maps-heavy.nakilon.pro/

Result: http://www.nakilon.pro/stalker.htm
Screencast about all this: https://www.youtube.com/watch?v=_Wwj7mrhFPk

Credits:
* most of the background images are from @dawnrazor73's https://zsg.dk/
* thanks to /u/Zyhgar25 for the CSS hint
* thanks to /u/plscome2brazil for the NPC name localisation hint

##############################################################################

Converting terrain to Wavefront OBJ on macOS:
1. download the Windows XP ISO: https://archive.org/details/WinXPProSP3x86
2. install VirtualBox, Windows, Guest Additions, attach gamedata folder
3. download the converter.exe: https://github.com/revolucas/AXRToolset
4. install VC++ 2015 Upd 3, 14.0.24212.0, md5=1b3d24a3e9c99e63391a53b9e5be5356:
   https://www.reddit.com/r/stalker/comments/floemw/stalker_anomaly_not_launching/
   https://www.itechtics.com/microsoft-visual-c-redistributable-versions-direct-download-links/
   https://www.microsoft.com/en-us/download/details.aspx?id=53587
   https://github.com/revolucas/AXRToolset/pull/8/files
5. unpack: converter.exe -dir db1 -2947ww gamedata.db1
6. download the MeshTool/OGFViewer tools:
   https://xray-engine.org/index.php?title=OGFViewer
   https://files.xray-engine.org/nattefrost/20131229.7z
7. cd db1\levels\l05_bar
   ..\..\..\MESHTOOL\WIN32\CONSOLE\parse_lev.exe 0 ..\..\..\l05_bar.ogf
8. cd ..\..\..
   MESHTOOL\WIN32\CONSOLE\ogf2obj.exe l05_bar.ogf l05_bar.obj
9. ruby fix_obj.rb l05_bar.obj fixed.l05_bar.obj

##############################################################################

(the rest of this file are technical notes that initially were not supposed
 to be in a public README so you don't immediately have to understand them)


$ find master/1/ -name "alife_l*" -exec sh -c "printf {}; grep -rI 'crow' {} | wc -l" \; | awk '{ print $2 "\t" $1 }' | sort -rn
$ rg -I -r \$1 "money = (.+)" master/1/ | sort -n | uniq -c
$ rg -Np "section_name: (.+)" l04_darkvalley/1.yaml -r '$1' | sort | uniq -c | sort -nr | head
$ rg -Np "section_name: (.+)" l0*/1.yaml -r '$1' | sort | uniq -c | sort -nr | grep stalker

$ bash ./parse.sh
$ bash ./render.sh
$ bash ./gsutil.sh    # update and execute partially
$ bash ./jpegsave.sh  # update and execute
$ gsutil -m rsync -r -c preview gs://heavy.www.nakilon.pro/stalker_preview
$ haml -q stalker.haml ../www-nakilon-pro/www.nakilon.pro/stalker.htm
$ haml -q stalker-single-page.haml ../www-nakilon-pro/www.nakilon.pro/stalker-single-page.htm

$ ruby debug.rb l04_darkvalley/1.yaml 4000x4000 l04_darkvalley/1.yaml l04_darkvalley/2.yaml l04_darkvalley/3.yaml l04_darkvalley/4.yaml l04_darkvalley/5.yaml 1500 5 1000 5 999 m_bloodsucker_e stalker bloodsucker_normal
$ ruby render_dots.rb $LOCATION/1.yaml $LOCATION # name agr_physic_object

v the most outdated code v
render_npcs.rb
render_mutants.rb
render_anomalies.rb
render_artifacts.rb
^ the least outdated code ^

$ rg -Np '(\S+).+' ~/_/GAMEDATA/l05_bar.obj -r '$1' | sort | uniq -c | sort -nr

1674870 vt
1674870 vn
1674870 v
1473702 f
13512 #
4504 usemtl
4504 o
4504 g
   1 mtllib

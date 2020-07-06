set -ex

for LOCATION in l01_escape \
                l02_garbage \
                l03_agroprom \
                l03u_agr_underground \
                l04_darkvalley \
                l04u_labx18 \
                l05_bar \
                l06_rostok \
                l07_military \
                l08_yantar \
                l08u_brainlab \
                l10_radar \
                l10u_bunker \
                l11_pripyat \
                l12_stancia \
                l12_stancia_2; do
  mkdir -p $LOCATION &&
  ruby parse.rb master/1/alife_$LOCATION.ltx > $LOCATION/1.yaml &&
  ruby parse.rb master/2/alife_$LOCATION.ltx > $LOCATION/2.yaml &&
  ruby parse.rb master/3/alife_$LOCATION.ltx > $LOCATION/3.yaml &&
  ruby parse.rb master/4/alife_$LOCATION.ltx > $LOCATION/4.yaml &&
  ruby parse.rb master/5/alife_$LOCATION.ltx > $LOCATION/5.yaml;
done

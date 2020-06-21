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
                l12_stancia; do
  ruby render_npcs.rb $LOCATION/1.yaml $LOCATION $LOCATION/2.yaml $LOCATION/3.yaml $LOCATION/4.yaml $LOCATION/5.yaml &&
  ruby render_mutants.rb $LOCATION/1.yaml $LOCATION &&
  ruby render_anomalies.rb $LOCATION/1.yaml $LOCATION &&
  ruby render_artifacts.rb $LOCATION/1.yaml $LOCATION $LOCATION/2.yaml $LOCATION/3.yaml $LOCATION/4.yaml $LOCATION/5.yaml;
done

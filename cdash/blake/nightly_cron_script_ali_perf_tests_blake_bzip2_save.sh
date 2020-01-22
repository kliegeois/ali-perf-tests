#!/bin/csh

BASE_DIR=/home/projects/albany/nightlyCDashAlbanyBlake/aliPerfTests/nightlyCDash
cd $BASE_DIR/build/Testing/Temporary
ln -s $BASE_DIR/repos/ali-perf-tests/jupyter_nb/scripts/ctest2json.py 
python ctest2json.py >& ctest2json.out  
/usr/bin/bzip2 LastTest_*  
cd $BASE_DIR
cp build/Testing/Temporary/LastTest_*bz2 saved/
cp build/Testing/Temporary/ctest*json saved/
cp saved/* /home/projects/albany/nightlyCDashAlbanyBlake/aliPerfTests/nightlyCDash/repos/ikalash.github.io/ali/blake_nightly_data
cd $BASE_DIR/repos/ikalash.github.io/ali/blake_nightly_data
now=$(date +"%Y%m%d")
FILE=ctest-$now.json
git add $FILE
FILE2=LastTest_$now-0500.log.bz2
git add $FILE2
git commit -m "Adding blake ALI nightly performance tests." 
git push

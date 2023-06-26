#!/bin/sh

# -------------------------------------------------------------------------------
# Edit TARDIS_HOME_PATH, GRADLE_REPO_PATH and TOOLSJAR_PATH to 
# reflect the paths where you installed the code:

# TARDIS_HOME_PATH: Folder where TARDIS is installed
# GRADLE_REPO_PATH: Gradle folder
# TOOLSJAR_PATH: 	tools.jar path
TARDIS_HOME_PATH=/dev/hd2/tardisBenatti
GRADLE_REPO_PATH=/dev/hd2/usr/.gradle
TOOLSJAR_PATH=/dev/hd2/usr/lib/jvm/jdk1.8.0_261/lib
# -------------------------------------------------------------------------------

#Compile all TARDIS runner
cd RunFiles
echo "[COMPILE AND MOVE SCRIPT] Compiling all Run files..."
for f in *.java
do
	javac -cp $TARDIS_HOME_PATH/master/build/libs/tardis-master-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/runtime/build/libs/sushi-lib-0.2.0-SNAPSHOT.jar:$TARDIS_HOME_PATH/jbse/build/libs/jbse-0.10.0-SNAPSHOT-shaded.jar:$TARDIS_HOME_PATH/lib/evosuite-shaded-1.2.1-SNAPSHOT.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/args4j/args4j/2.32/1ccacebdf8f2db750eb09a402969050f27695fb7/args4j-2.32.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-api/2.14.0/23cdb2c6babad9b2b0dcf47c6a2c29d504e4c7a8/log4j-api-2.14.0.jar:$GRADLE_REPO_PATH/caches/modules-2/files-2.1/org.apache.logging.log4j/log4j-core/2.14.0/e257b0562453f73eabac1bc3181ba33e79d193ed/log4j-core-2.14.0.jar:$TOOLSJAR_PATH/tools.jar $f && echo "[COMPILE AND MOVE SCRIPT] $f compiled" || echo "[COMPILE AND MOVE SCRIPT] $f: Failed"
done
cd ..

#Move TARDIS runner to the benchmark folders
echo "[COMPILE AND MOVE SCRIPT] Moving all Run files..."
#Authzforce
if [ -d core-release-13.3.0 ]; then
	mkdir -p core-release-13.3.0/pdp-engine/target/classes/settings; mv RunFiles/RunAuthzforce1.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunAuthzforce1.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Dubbo
if [ -d dubbo ]; then
	mkdir -p dubbo/dubbo-common/target/classes/settings; mv RunFiles/RunDubbo.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunDubbo.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Okio
if [ -d okio ]; then
	mkdir -p okio/okio/target/classes/settings; mv RunFiles/RunOkio.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunOkio.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Zxing
if [ -d zxing ]; then
	mkdir -p zxing/core/target/classes/settings; mv RunFiles/RunZxing.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunZxing.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#WebMagic
if [ -d webmagic ]; then
	mkdir -p webmagic/webmagic-core/target/classes/settings; mv RunFiles/RunWebmagic2_3_4.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunWebmagic2_3_4.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
	mkdir -p webmagic/webmagic-extension/target/classes/settings; mv RunFiles/RunWebmagic1_5.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunWebmagic1_5.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#FastJson
if [ -d fastjson ]; then
	mkdir -p fastjson/target/classes/settings; mv RunFiles/RunFastjson.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunFastjson.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Jsoup
if [ -d jsoup ]; then
	mkdir -p jsoup/target/classes/settings; mv RunFiles/RunJsoup.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunRunJsoup.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Bcel
if [ -d bcel-6.0-src ]; then
	mkdir -p bcel-6.0-src/target/classes/settings; mv RunFiles/RunBcel.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunBcel.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Gson
if [ -d gson ]; then
	mkdir -p gson/gson/target/classes/settings; mv RunFiles/RunGson.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunGson.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Image
if [ -d commons-imaging ]; then
	mkdir -p commons-imaging/target/classes/settings; mv RunFiles/RunImage.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunImage.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Jxpath
if [ -d commons-jxpath-1.3-src ]; then
	mkdir -p commons-jxpath-1.3-src/target/classes/settings; mv RunFiles/RunJxpath.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunJxpath.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#La4j
if [ -d la4j-0.6.0 ]; then
	mkdir -p la4j-0.6.0/target/classes/settings; mv RunFiles/RunLa4j.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunLa4j.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Re2j
if [ -d re2j ]; then
	mkdir -p re2j/target/classes/settings; mv RunFiles/RunRe2j.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunRe2j.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Okhttp
if [ -d okhttp ]; then
	mkdir -p okhttp/okhttp/target/classes/settings; mv RunFiles/RunOkhttp.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunOkhttp.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Fescar
if [ -d fescar ]; then
	mkdir -p fescar/core/target/classes/settings; mv RunFiles/RunFescar.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunFescar.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Spoon
if [ -d spoon ]; then
	mkdir -p spoon/target/classes/settings; mv RunFiles/RunSpoon.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunSpoon.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Guava
if [ -d guava ]; then
	mkdir -p guava/guava/target/classes/settings; mv RunFiles/RunGuava.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunGuava.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Pdfbox
if [ -d pdfbox ]; then
	mkdir -p pdfbox/pdfbox/target/classes/settings; mv RunFiles/RunPdfbox.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunPdfbox.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Weka
if [ -d weka ]; then
	mkdir -p weka/dist/settings; mv RunFiles/RunWeka.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunWeka.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Fastjson9th
if [ -d fastjson9th ]; then
	mkdir -p fastjson9th/target/settings; mv RunFiles/RunFastjson9th.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunFastjson9th.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#Guava9th
if [ -d guava9th ]; then
	mkdir -p guava9th/guava/target/settings; mv RunFiles/RunGuava9th.class $_ && echo "[COMPILE AND MOVE SCRIPT] Moved RunGuava9th.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

#MIPC
if [ -d mipc ]; then
	mkdir -p mipc/bin; javac mipc/src/mipc/MIPC.java -d mipc/bin; mv RunFiles/RunMIPC.class $_ && echo "[COMPILE AND MOVE SCRIPT] Compiled MIPC and moved it to mipc/bin, also moved RunMIPC.class to $_" || echo "[COMPILE AND MOVE SCRIPT] Failed"
fi

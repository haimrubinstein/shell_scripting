#how to check correct api
#how to find sdk location

#start scrpit
echo "welcome to bash scripting";


#pul the code
git clone https://github.com/haim6678/shell_scripting.git
export ANDROID_HOME=$HOME/Android/Sdk/
echo "finish cloning"
printf "\n"

#go to the emulator directory
cd ~/Android/Sdk/emulator 

#find the emulators on the device
result=$(./emulator -list-avds)
emunane=$(echo ${result[0]} |cut -d " " -f1)
echo $emunane

#start the emulatur
./emulator -avd $emunane &

#go to android files folder
cd ~/shell_scripting/files

#build the project step by step

#start with workspace file
export WORKSPACE=$HOME/shell_scripting/files
touch $WORKSPACE/WORKSPACE

#write to the file
echo "android_sdk_repository(
    name = \"androidsdk\"
)
" >WORKSPACE 

#create build file
cd ~/shell_scripting/files/android
touch $WORKSPACE/android/BUILD

#go to the file build directory
cd $WORKSPACE/android

#write the build commands
#create the library
echo "android_library(
  name = \"activities\",
  srcs = glob([\"src/main/java/com/activities/*.java\"]),
  custom_package = \"com.google.bazel.example.android.activities\",
  manifest = \"src/main/java/com/activities/AndroidManifest.xml\",
  resource_files = glob([\"src/main/java/com/activities/res/**\"]),
)" > BUILD
#create the apk
echo "android_binary(
    name = \"android\",
    custom_package = \"com.google.bazel.example.android\",
    manifest = \"src/main/java/com/AndroidManifest.xml\",
    resource_files = glob([\"src/main/java/com/res/**\"]),
    deps = [\":activities\"],
)" >> BUILD

#go back to workspace directory
cd $WORKSPACE

#build the program
bazel build //android:android

#find if build failed
result=$?
echo "finish building"
printf "\n"
if [ "$result" -eq "0" ];then
  echo "build success";
else
    adb -s "$emunane" emu kill
    echo "build failed"
    exit 
fi

printf "\n"
sleep 40

#find if the emulator is runnig and wait for it to run


#if pgrep -x "$emunane" > /dev/null
#then
 #   echo "Running"
#else
 #   echo "Stopped"
#fi

#install the app on the device
bazel mobile-install //android:android

#find if install failed
installresult=$?

if [ "$installresult" -eq "0" ];then
  echo "install success";
else
    echo "install failed"
    exit 
fi

#go to adb directory
cd ~/Android/Sdk/platform-tools
#run the app
./adb shell am start -n com.google.bazel.example.android/com.google.bazel.example.android.activities.MainActivity
echo "the end"

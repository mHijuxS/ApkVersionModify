FROM openjdk:11-jdk-slim

# Install necessary dependencies
RUN apt-get update && apt-get install -y wget unzip

# Set environment variables
ENV ANDROID_HOME=/sdk
ENV ANDROID_SDK_ROOT=/sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0

# Download Android SDK command-line tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip /tmp/cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools && \
    rm /tmp/cmdline-tools.zip && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest

# Accept licenses and install Build Tools and Platform Tools
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" "build-tools;34.0.0"

# Download apktool
RUN wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.8.1.jar -O /usr/local/bin/apktool.jar && \
    wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool && \
    chmod +x /usr/local/bin/apktool

# Copy the script into the container
RUN wget https://raw.githubusercontent.com/mHijuxS/ApkVersionModify/refs/heads/main/modify_apk.sh -O /usr/local/bin/modify_apk.sh
RUN chmod +x /usr/local/bin/modify_apk.sh

# Set the working directory
WORKDIR /work

# Default command (can be overridden)
CMD ["modify_apk.sh"]


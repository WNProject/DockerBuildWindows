FROM mcr.microsoft.com/windows/servercore:ltsc2019

# set input arguments to defaults
ARG VS_VERSION
ARG VSSETUP_VERSION="2.2.16"
ARG CMAKE_VERSION="3.18.2"

# set environment variables to defaults
ENV VS_ARCH="amd64"

# set default shell
SHELL ["cmd", "/s", "/c"]

# install chocolatey
ADD https://chocolatey.org/install.ps1 C:\\Temp\\install-chocolatey.ps1
RUN powershell C:\\Temp\\install-chocolatey.ps1 && \
    rmdir /s /q C:\\Temp && \
    del /s /f /q %TEMP%

# install cmake
RUN choco install -y cmake \
      --version %CMAKE_VERSION% \
      --installargs 'ADD_CMAKE_TO_PATH=System' && \
    del /s /f /q %TEMP%

# install ninja
RUN choco install -y ninja && \
    setx PATH "%ChocolateyInstall%\\lib\\ninja\\tools;%PATH%" && \
    del /s /f /q %TEMP%

# install python
RUN choco install -y python3 && \
    del /s /f /q %TEMP%

# install git
RUN choco install -y git && \
    del /s /f /q %TEMP%

# install vssetup
ADD https://github.com/microsoft/vssetup.powershell/releases/download/${VSSETUP_VERSION}/VSSetup.zip \
    C:\\Temp\\vssetup.zip
RUN powershell -command Expand-Archive \
      C:\\Temp\\vssetup.zip \
      %USERPROFILE%\\Documents\\WindowsPowerShell\\Modules\\VSSetup && \
    rmdir /s /q C:\\Temp && \
    del /s /f /q %TEMP%

# install visual studio build tools
ADD http://aka.ms/vscollect.exe C:\\Temp\\vscollect.exe
ADD http://aka.ms/vs/${VS_VERSION}/release/channel \
    C:\\Temp\\vschannel.chman
ADD http://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe \
    C:\\Temp\\vsbuildtools.exe
COPY vs-helpers\\install-wrapper.cmd C:\\Temp\\install-wrapper.cmd
RUN C:\\Temp\\install-wrapper.cmd C:\\Temp\\vsbuildtools.exe \
      --quiet --wait --norestart --nocache \
      --channelUri C:\\Temp\\vschannel.chman \
      --installChannelUri C:\\Temp\\vschannel.chman \
      --add Microsoft.VisualStudio.Workload.VCTools \
      --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
      --add Microsoft.VisualStudio.Component.VC.ATL && \
    rmdir /s /q C:\\Temp && \
    del /s /f /q %TEMP%

# set entrypoint and default command
ENV VS_VERSION=${VS_VERSION}
COPY vs-helpers\\init.ps1 C:\\Scripts\\init.ps1
ENTRYPOINT ["powershell", "C:\\Scripts\\init.ps1"]
CMD ["powershell", "-NoLogo"]

# labels
LABEL maintainer WNProject
LABEL org.opencontainers.image.source \
      https://github.com/WNProject/DockerBuildWindows

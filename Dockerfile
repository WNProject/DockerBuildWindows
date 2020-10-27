FROM mcr.microsoft.com/windows/servercore:ltsc2019

# set input arguments to defaults
ARG VS_VERSION
ARG VSSETUP_VERSION="2.2.16"
ARG CMAKE_VERSION="3.16.4.20200221"
ARG SDK_VERSION="17763"

# set environment variables to defaults
ENV DEBUG="0" \
    VS_VERSION=${VS_VERSION} \
    VS_ARCH="amd64"

# set default shell
SHELL ["powershell", "-Command"]

# install packages
COPY helpers C:\\Temp
RUN $errorActionPreference = 'Stop'; \
    Invoke-WebRequest \
      -Uri https://chocolatey.org/install.ps1 \
      -OutFile C:\Temp\install-chocolatey.ps1; \
    C:\Temp\install-chocolatey.ps1; \
    C:\Temp\execute-wrapper.ps1 choco install -y cmake \
      --version "$env:CMAKE_VERSION" \
      --ia 'ADD_CMAKE_TO_PATH=System'; \
    C:\Temp\execute-wrapper.ps1 choco install -y ninja python git; \
    C:\Temp\add-to-path.ps1 "$env:CHOCOLATEYINSTALL\lib\ninja\tools"; \
    $vsSetupUrl = 'https://github.com/microsoft/vssetup.powershell'; \
    Invoke-WebRequest \
      -Uri "$vsSetupUrl/releases/download/$env:VSSETUP_VERSION/VSSetup.zip" \
      -OutFile C:\Temp\vssetup.zip; \
    Expand-Archive \
      C:\Temp\vssetup.zip \
      "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\VSSetup"; \
    Invoke-WebRequest \
      -Uri http://aka.ms/vscollect.exe \
      -OutFile C:\Temp\vscollect.exe; \
    Invoke-WebRequest \
      -Uri "http://aka.ms/vs/$env:VS_VERSION/release/channel" \
      -OutFile C:\Temp\vschannel.chman; \
    Invoke-WebRequest \
      -Uri "http://aka.ms/vs/$env:VS_VERSION/release/vs_buildtools.exe" \
      -OutFile C:\Temp\vsbuildtools.exe; \
    C:\Temp\execute-wrapper.ps1 cmd /s /c \
      C:\Temp\install-wrapper.cmd C:\Temp\vsbuildtools.exe \
      --quiet --wait --norestart --nocache \
      --channelUri C:\Temp\vschannel.chman \
      --installChannelUri C:\Temp\vschannel.chman \
      --add Microsoft.VisualStudio.Workload.VCTools \
      --add Microsoft.VisualStudio.Component.VC.ATL \
      --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \
      --add "Microsoft.VisualStudio.Component.Windows10SDK.$env:SDK_VERSION"; \
    Invoke-WebRequest \
      -Uri https://win.rustup.rs/x86_64 \
      -Outfile C:\Temp\rustup-init.exe; \
    C:\Temp\execute-wrapper.ps1 C:\Temp\rustup-init.exe -y; \
    C:\Temp\add-to-path.ps1 "$env:USERPROFILE\.cargo\bin"; \
    C:\Temp\execute-wrapper.ps1 cargo install sccache --features=gcs; \
    Remove-Item "$env:USERPROFILE\.cargo\registry" -Force -Recurse; \
    Remove-Item C:\Temp -Force -Recurse; \
    Remove-Item "$env:TEMP\*" -Force -Recurse

# set entrypoint and default command
COPY scripts C:\\Scripts
ENTRYPOINT ["powershell", "C:\\Scripts\\init.ps1"]
CMD ["powershell", "-NoLogo"]

# labels
LABEL maintainer WNProject
LABEL org.opencontainers.image.source \
      https://github.com/WNProject/DockerBuildWindows

FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS builder
SHELL ["cmd", "/S", "/C"]

LABEL maintainer "florian.stosse@safrangroup.com"
LABEL lastupdate "01-12-2021"
LABEL author "Florian Stosse"
LABEL description "Windows 10 LTSC 2022 image, with Microsoft Build Tools 2022 (v17.0)"
LABEL license "MIT license"

# Set up environment to collect install errors.
ADD https://aka.ms/vscollect.exe C:/TEMP/collect.exe
ADD Install.cmd C:/TEMP/

# Download channel for fixed install.
ADD https://aka.ms/vs/17/preview/channel C:/TEMP/VisualStudio.chman

# Add latest build tools
ADD https://aka.ms/vs/17/pre/vs_buildtools.exe C:/TEMP/vs_buildtools.exe

# For the workloads, cf. https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022&preserve-view=true#desktop-development-with-c
RUN \
  (start /w C:/TEMP/Install.cmd C:/TEMP/vs_buildtools.exe --quiet --wait --norestart --nocache modify \
  --channelUri C:/TEMP/VisualStudio.chman \
  --installChannelUri C:/TEMP/VisualStudio.chman \
  --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended \
  --add Microsoft.VisualStudio.Component.VC.Llvm.Clang \
  --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset \
  --installPath C:/BuildTools) \
  && del /q C:/TEMP/vs_buildtools.exe


FROM mcr.microsoft.com/windows/servercore:ltsc2022

COPY --from=builder C:/BuildTools/ C:/BuildTools

# Use developer command prompt and start PowerShell if no other command specified.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
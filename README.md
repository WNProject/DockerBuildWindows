# Docker Build Windows

[![License]](LICENSE)
[![Build][Build Badge]][Build Workflow]

Docker container containing all needed **Windows** C/C++ build tools. Each
container will contain only one version of **MSVC** but will contain all
additional libraries and build tools needed (**Python 3**, **Ninja**, etc).
Currently we only support **x86-64** compilers.

## Usage

There are 2 ways to use this container [Interactive](#interactive) and
[Command](#command) mode.

### Interactive

This will run the container which will pre-configure the correct **MSVC** build
tools and drop you into `powershell`.

```cmd
docker run -it -v C:\src:C:\src build-windows
```

### Command

This will run the container which will pre-configure the correct **MSVC** build
tools and run the supplied command directly.

```cmd
docker run -v C:\src:C:\src build-windows [command]
```

## Building

```cmd
docker build -t build-windows --build-arg VS_VERSION=[15|16] .
```

Note that `VS_VERSION` must be supplied as the `Dockerfile` does not specify a
default. Currently only `15` (**MSVC 15/Visual Studio 2017**) and `16`
(**MSVC 16/Visual Studio 2019**) are supported.

<!-- external links -->
[License]: https://img.shields.io/github/license/WNProject/DockerBuildWindows?label=License
[Build Badge]: https://github.com/WNProject/DockerBuildWindows/workflows/Build/badge.svg?branch=main
[Build Workflow]: https://github.com/WNProject/DockerBuildWindows/actions?query=workflow%3ABuild+branch%3Amain

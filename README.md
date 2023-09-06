<!-- <div id="readme" class="Box-body readme blob js-code-block-container">
<article class="markdown-body entry-content p-3 p-md-6" itemprop="text"> -->
<p align="right">
<a href="https://github.com/fpgasystems">fpgasystems</a> <a href="https://github.com/fpgasystems/hacc">HACC</a> <a href="https://github.com/fpgasystems/sgrt">SGRT</a>
</p>

<p align="center">
<img src="https://github.com/fpgasystems/sgrt_install/blob/main/sgrt-install-removebg.png" align="center" width="350">
</p>

<h1 align="center">
  Systems Group RunTime Installation
</h1> 

To install [SGRT](https://github.com/fpgasystems/sgrt), please proceed by following these steps:

* [Download the installer](#download-the-installer)
* [Run the installer](#run-the-installer)
* [Install dependencies](#install-dependencies)

## Download the installer
```
git clone https://github.com/fpgasystems/sgrt_install.git
```

## Run the installer
```
./sgrt_install/run.sh
```

During the installation process, the installer will prompt you to define a set of parameters. The following information is intended to assist you in making the correct 

### Paths prompts
selections:
* MPICH_PATH: This field designates the path to a valid MPICH installation, with the default setting being ```/opt/mpich```.
* MY_DRIVERS_PATH: This parameter designates a path where a ```$USER``` has the necessary capabilities to utilize the ```rmmod``` and ```insmmod``` system calls. The default value is ```/local/home/$USER```.
* MY_PROJECTS_PATH: This parameter specifies a directory where the user (```$USER```) possesses the requisite permissions to perform read, write, and application execution operations. By default, this path is defined as ```/home/$USER/sgrt_projects```, where ```/home/$USER``` typically represents an NFS hard drive that is accessible from all servers within a cluster.

* ROCM_PATH:
* XILINX_PLATFORMS_PATH:
* XILINX_TOOLS_PATH:
* XRT_PATH:



## Install dependencies
* [Xilinx tools](#xilinx-tools)
* [GitHub CLI](#github-cli)
(this simulates alveo-cluster/playbooks/cli-install.yml)

### Xilinx tools
hola

### GitHub CLI
hola

## Limitations
* SGRT has only been tested on Ubuntu.

# License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Copyright (c) 2023 FPGA @ Systems Group, ETH Zurich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
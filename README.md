# dPanda
dPanda, pronounced as "The Panda", is a dashboard application that contains a set of complementary services for DataPower administrators and developers.

dPanda stands for "DataPower Administration and Development Applications".

## Getting Started

### Prerequisites
- docker
- git

### Installing
Start by cloning the project, this will create a new directory "dpanda":
```sh
cd ..
git clone https://github.com/Tangram-Soft/dpanda.git
```

You can either pull the docker container from ibm's repository or download another version from the access catalog and create an image out of it.
```sh
$ docker pull ibmcom/datapower:latest
```

Once the image is ready, create the container:
```sh
$ cd dpanda
$ docker create -it \
  -v $PWD/config:/drouter/config \
  -v $PWD/local:/drouter/local \
  -e DATAPOWER_ACCEPT_LICENSE=true \
  -e DATAPOWER_INTERACTIVE=true \
  --name idg.dpanda \
  ibmcom/datapower
```

You'll later need to:
Create a crypto pair for the https front side handler to work. Make sure the CN is "dpanda-gui".

Login to the gui as user dpanda (pw: dpanda) and change its password to dpanda again.

Make sure the host alias points to the correct IP address.

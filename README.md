# ssb-pi-pub
Easily run a Scuttlebutt pub on a Raspberry Pi via Docker.


### Use
1. Install the [latest version of Raspbian Lite](https://www.raspberrypi.org/downloads/raspbian/) onto a microSD card (16GB+ recommended)
    1. [Etcher](https://etcher.io/) is a great utility for flashing the microSD image

2. Create an empty file named `ssh` in the boot partition to enable SSH access
	1. This is the FAT32 partition which will be the only one that appears on a Mac or Windows machine

3. SSH into the Raspberry Pi
    1. ```
       ssh pi@X.X.X.X
       ```
        1. The default password is `raspberry`
        2. Use an app such as [Fing](https://www.fing.io/) to find the IP of your Pi
        3. [PuTTY](https://www.putty.org/) is an excellent SSH client for Windows

4. Ensure you have changed the default password for the `pi` user
    1. ```
       passwd
       ```

5. Install Docker on your Raspberry Pi
    1. Update packages
       ```
       sudo apt update
       ```

    2. Install Docker dependencies 
       ```
       sudo apt install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg2 \
            software-properties-common
       ```

    3. Add the Docker GPG key
       ```
       curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
       ```

    4. Add the Docker apt repo
       ```
       echo "deb [arch=armhf] https://download.docker.com/linux/debian \
            $(lsb_release -cs) stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list
       ```

    5. Install Docker
       ```
       sudo apt update && apt install -y docker-ce
       ```

    6. Add your user to the Docker group (so that you can use the docker command)
       ```
       sudo usermod -aG docker $USER
       ```

    7. Log out and back in (now that you are in the docker group)

6. Deploy the sbot Docker container
   ```
   docker run -d --restart=always -v ssbdata:/home/sbot/.ssb --net=host \
   --name=sbot ericbarch/ssb-pi-pub server --host YOUR_PUB_HOSTNAME
   ```
   1. If this pub will only be used on a LAN, simply use localhost as YOUR_PUB_HOSTNAME
   2. This will store all sbot data in a docker volume named "ssbdata", outside of the Docker container (so you can easily upgrade without losing data).
   3. Note that we must use --net=host to support UDP multicast

7. Generate an invite (if hosting a public pub)
   ```
   docker exec -it sbot /sbot.sh invite.create 1
   ```

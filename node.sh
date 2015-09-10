#! /bin/bash

function nodeversion {
        echo "Node version: $(node -v)"
	echo "Npm version: $(npm -v)"
}

function nodeinstall {

	TMP_FOLDER='_node'
	UNAME_STR=$(uname)

	if [[ "$UNAME_STR" == 'Linux' ]]; then
	        OS='linux'
	elif [[ "$UNAME_STR" == 'Darwin' ]]; then
	        OS='darwin'
	fi

	if [[ ! -z "$OS" ]]; then

	        ARCH=`getconf LONG_BIT`

	        if [[ "$ARCH" == "32" ]]; then
	                ARCH_VALUE='86'
	        elif [[ "$ARCH" == "64" ]]; then
	                ARCH_VALUE='64'
		elif [[ "$OS" == "darwin" ]]; then
			# for darwin (mac os x) there is only a 64 bit version
			ARCH_VALUE='64'
	        fi

	        if [[ ! -z "$ARCH_VALUE" ]]; then
	                # getting latest node
	                NODE_URL=$(curl -vsL https://nodejs.org/dist/latest/ | sed -E 's/.*href="([^"#]+)".*/\1/' | grep $OS-x$ARCH_VALUE.tar.gz)

		        # downloading
		        DOWNLOAD_URL=https://nodejs.org/dist/latest/$NODE_URL
			echo `curl -Lo $NODE_URL $DOWNLOAD_URL && mkdir $TMP_FOLDER && tar xf $NODE_URL -C $TMP_FOLDER --strip-components=1`

		        # installing
		        USER=$(whoami); 
		        sudo chown -R $USER /usr/local
		        cp -R ./$TMP_FOLDER/lib/node_modules /usr/local/lib/node_modules
		        cp -R ./$TMP_FOLDER/include/node /usr/local/include/node
		        mkdir -p /usr/local/man/man1
		        cp ./$TMP_FOLDER/share/man/man1/node.1 /usr/local/man/man1/node.1
		        cp ./$TMP_FOLDER/bin/node /usr/local/bin/node
		        ln -sf "/usr/local/lib/node_modules/npm/bin/npm-cli.js" /usr/local/bin/npm

		        # cleaning up
		        rm -rf $TMP_FOLDER
		        rm -rf $NODE_URL
		else
			echo "Could not determine your ARCH value try changing ARCH=$(getconf LONG_BIT)"
		fi

	else
        	echo "Your OS is not supported (yet)"
	fi

}

function noderemove {
	sudo rm -rf /usr/local/bin/npm
	sudo rm -rf /usr/local/bin/node
	sudo rm -rf /usr/local/lib/node_modules/
	sudo rm -rf /usr/local/include/node/
	sudo rm -rf /usr/local/man/man*/node*
	sudo rm -rf /usr/local/man/man*/npm*
	sudo rm -rf /usr/local/bin/_node/
}

function nodeupdate {
	if [[ -f /usr/local/bin/npm && -f /usr/local/bin/node ]]; then
		echo "Updating Node and npm..."
		npm install -g npm
		npm cache clean -f
		npm install -g n
		n stable
		nodeversion
	else
		echo "Node and npm could not be updated because they are not installed"
	fi
}

ARGS=("$@")

if [[ "${ARGS[0]}" = "--install" ]]; then
	echo "Installing latest Node and npm..."
	nodeinstall
	nodeversion
elif [[ "${ARGS[0]}" = "--update" ]]; then
	nodeupdate
elif [[ "${ARGS[0]}" = "--remove" ]]; then
	echo "Removing node and npm..."
	noderemove
elif [[ "${ARGS[0]}" = "--version" ]]; then
	nodeversion
else
	noderemove
	nodeinstall
	nodeupdate
fi

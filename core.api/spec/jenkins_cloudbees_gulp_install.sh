# UNUSED!
# This is script is currently UNUSED! As this script seems to be executed in a subshell by Cloudbees, "npm" is later not available in the path of the actual Jenkins shell...
# =============================================================
# Cloudbees' own NodeJS-installation always failed to install gulp (it's fucked):
#curl -s -o use-node https://repository-cloudbees.forge.cloudbees.com/distributions/ci-addons/node/use-node
#NODE_VERSION=0.10.4 . ./use-node
#npm install gulp --global
#npm install --save gulp-install


# Manual installation
# as taken from https://github.com/gtramontina/cloudbees-node/blob/master/start.sh
# =============================================================
NODE_SOURCE_DIR='build/node'
NODE_INSTALL_DIR=$NODE_SOURCE_DIR'/installed'

# Plumbing...
exist_directory() {
    [ -d $1 ];
}
clone_node_from_github() {
    git clone https://github.com/joyent/node.git $NODE_SOURCE_DIR
}
install_node() {
    mkdir $NODE_INSTALL_DIR
    PREFIX=$PWD/$NODE_INSTALL_DIR
    pushd $NODE_SOURCE_DIR
    ./configure --prefix=$PREFIX
    make install
    popd
}
is_command_in_path() {
    command -v $1 > /dev/null;
}
add_node_to_path() {
    export PATH=$PWD/$NODE_INSTALL_DIR/bin:${PATH}
}
install_npm() {
    curl http://npmjs.org/install.sh | clean=yes sh
}

# [ Start! ]
# Checking Node.js
exist_directory $NODE_SOURCE_DIR || clone_node_from_github
exist_directory $NODE_INSTALL_DIR || install_node
is_command_in_path 'node' || add_node_to_path
echo 'NodeJS Version:'
node --version

#Checking NPM
is_command_in_path 'npm' || install_npm
echo 'NPM Version:'
npm --version

npm install gulp --global
#npm install gulp
#npm install --save gulp-install


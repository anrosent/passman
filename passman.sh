#!/bin/bash
HOME=~/.passman
KEY_DIR=$HOME/keys
SECRETS_DIR=$HOME/secrets
GPGID=""

# Declare our global vars
NAME=""
COMMAND="list" # Default command

###### Utility Functions #######
### Lib Funcs
assert (){
    COND=$1;
    MSG=$2;
    if [[ -z $COND ]];
    then
        echo "ERROR"
        echo $MSG
        exit 1
    fi
}

check_not_exists (){
    if [[ -f $SECRETS_DIR/$NAME ]];
    then
        echo "Secret $NAME already exists!"
        echo "Exiting..."
        exit 1
    fi
}

check_exists (){
    if [[ ! -f $SECRETS_DIR/$NAME ]];
    then
        echo "Secret $NAME doesn't exist!"
        echo "Exiting..."
        exit 1
    fi
}

# Since this keyring is just for PassMan, you will always use the same
# recipient ID. This is the first one in your PassMan secret key ring.
load_gpgid () {
    GPGID="$(gpg --list-secret-keys --homedir=$KEY_DIR | grep uid | head -1 | sed -e 's/uid\s*//g')"
}
###### End Utility Functions #######

# Store a password in PassMan
create () {
    check_not_exists $NAME
    echo "Creating password: $NAME"
    echo "Enter your password, followed by [ENTER]:"
    read password
    
    NEW_SECRET_FILE=$SECRETS_DIR/$NAME
    echo $password | gpg --homedir=$KEY_DIR -r "$GPGID" --encrypt --output $NEW_SECRET_FILE 
    echo "Password $NAME successfully encrypted and stored"
}

# Retrieve a password from PassMan and have it placed on your system clipboard
# TODO: use gpg-agent so we don't have to prompt for password every time
# TODO: tab complete over existing passwords
get () {
    check_exists $NAME
    SECRET_FILE=$SECRETS_DIR/$NAME
    
    echo "Enter your master passphrase"
    read -s password

    #TODO: portable clip to MAC
    echo $password | gpg --homedir=$KEY_DIR -q --batch --passphrase-fd 0 --decrypt $SECRET_FILE | xclip -i -sel c
    echo "The password for $NAME has been placed on your clipboard!"
}

# List the names of the passwords registered with PassMan
list () {
    echo "PassMan Registry:"
    ls $SECRETS_DIR 
}

init () 
{
    SETUP=""

    # Check GPG
    assert "$(which gpg)" "No installation of Gnu Privacy Guard (GPG) detected. You must install it."

    # Check install dirs
    if [[ ! -d $HOME || ! -d $KEY_DIR || ! -d $SECRETS_DIR ]];
    then
        echo "Incomplete installation in $HOME"
        echo "Creating directories..."
        mkdir -p $HOME/{keys,secrets}
        chmod 700 $HOME/{keys,secrets}
        SETUP=true
    fi

    # Check for master key
    if [[ ! -f $KEY_DIR/secring.gpg ]];
    then
        echo "Generating master key..."
        gpg --homedir=$KEY_DIR --gen-key
        SETUP=true
    fi

    if [[ $SETUP ]];
    then
        echo "Setup complete!"
    fi

    load_gpgid
}

usage ()
{
    echo "Usage:"
    echo "passman [[-c|--create] secret_name]"
    exit 0
}

main() 
{
    # Make sure we're installed properly
    init 

    # Parse cmdline args 
    while [[ "$#" -gt 0 ]];
    do 
        arg="$1"
        case $arg in
            -c|--create)
                COMMAND="create"; shift
                ;;
            *)
                NAME=$arg; shift
                COMMAND="get"
                ;;
        esac
    done


    # Execute the command
    case $COMMAND in
        get)
            assert "$NAME" "You must provide a secret name!"
            get $NAME
            ;;
        create)
            assert "$NAME" "You must provide a secret name!"
            create $NAME;
            ;;
        list)
            list $NAME;
            ;;
    esac
}

# GO!
main $@

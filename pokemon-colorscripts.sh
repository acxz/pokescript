#!/bin/sh

# Checking the OS so as to use mac specific utilities on MacOS
OS=$(uname)
if [ $OS = 'Darwin' ]
then
    PROGRAM=$(greadlink -f "$0")
else
    PROGRAM=$(readlink -f "$0")
fi

PROGRAM_DIR=$(dirname "$PROGRAM")
# directory where all the art files exist
POKEART_DIR="$PROGRAM_DIR/colorscripts"
# formatting for the help strings
fmt_help="  %-20s\t%-54s\n"


_help(){
    #Function that prints out the help text

    echo "Description: CLI utility to print out unicode image of a pokemon in your shell"
    echo ""
    echo "Usage: pokemon-colorscripts [OPTION] [POKEMON NAME]"
    printf "${fmt_help}" \
        "-h, --help, help" "Print this help." \
        "-l, --list, list" "Print list of all pokemon"\
        "-r, --random, random" "Show a random pokemon. This flag can optionally be
                        followed by a generation number or range (1-8) to show random
                        pokemon from a specific generation or range of generations.
                        The generations can be provided as a continuous range (eg. 1-3)
                        or as a list of generations (1 3 6)"\
        "-n, --name" "Select pokemon by name. Generally spelled like in the games.
                        a few exceptions are nidoran-f,nidoran-m,mr-mime,farfetchd,flabebe
                        type-null etc. Perhaps grep the output of --list if in
                        doubt"
    echo "Examples: pokemon-colorscripts --name pikachu"
    echo "          pokemon-colorscripts -r"
    echo "          pokemon-colorscripts -r 1-3"
    echo "          pokemon-colorscripts -r 1 2 6"
}


# Index values where the different generations are seperated in the names list
# Cannot think of a better way to do arrays with narrow POSIX compliance
# 0-151 gen 1, 810-898 gen 8
indices="1 152 251 387 494 650 722 810 898"

_show_random_pokemon(){
    #selecting a random art file from the whole set

    # if there are no arguments show across all generations
    if [ $# = 0 ]; then
        start_gen=1
        end_gen=8
    # show from single generation or continuous range of generations
    elif [ $# = 1 ]; then
        generation=$1
        start_gen=${generation%-*}
        end_gen=${generation#*-}
    # show from list of generations
    else
        generations=$@
        if [ $OS = 'Darwin' ]; then
            start_gen=$(gshuf -e $generations -n 1)
        else
            start_gen=$(shuf -e $generations -n 1)
        fi
        end_gen=$start_gen
    fi

    if [ "$end_gen" -gt 8 ]||[ "$start_gen" -lt 1 ]; then
        echo "Invalid generation"
        exit 1
    fi

    start_index=$(_get_start_index $start_gen)
    end_index=$(_get_end_index $end_gen)

    # getting a random index (using shuf instead of $RANDOM for POSIX compliance)
    # Using mac coreutils if on MacOS
    if [ $OS = 'Darwin' ]
    then
        random_index=$(gshuf -i "$start_index"-"$end_index" -n 1)
    else
        random_index=$(shuf -i "$start_index"-"$end_index" -n 1)
    fi

    random_pokemon=$(sed $random_index'q;d' "$PROGRAM_DIR/nameslist.txt")
    echo $random_pokemon

    # print out the pokemon art for the pokemon
    cat "$POKEART_DIR/$random_pokemon.txt"
}

_get_end_index(){
    local i=0
    local gen=$1
    for index in $indices; do
        if [ "$i" = "$gen" ]; then
            echo $index
            break
        fi
        i=$((i + 1))
    done
}

_get_start_index(){
    local i=0
    local gen=$1
    for index in $indices; do
        if [ "$i" = "$((gen-1))" ]; then
            echo $index
            break
        fi
        i=$((i + 1))
    done
}
_show_pokemon_by_name(){
    pokemon_name=$1
    echo $pokemon_name
    # Error handling. Can't think of a better way to do it
    cat "$POKEART_DIR/$pokemon_name.txt" 2>/dev/null || echo "Invalid pokemon"
}

_list_pokemon_names(){
    cat "$PROGRAM_DIR/nameslist.txt"|less
}

# Handling command line arguments
case "$#" in
    0)
        # display help if no arguments are given
        _help
        ;;
    1)
        # Check flag and show appropriate output
        case $1 in
            -h | --help | help)
                _help
                ;;
            -r | --random | random)
                _show_random_pokemon
                ;;
            -l | --list | list)
                _list_pokemon_names
                ;;
            *)
                echo "Input error."
                exit 1
                ;;
        esac
        ;;

    *)
        if [ "$1" = '-n' ]||[ "$1" = '--name' ]||[ "$1" = 'name' ]; then
            _show_pokemon_by_name "$2"
        elif [ "$1" = -r ]||[ "$1" = '--random' ]||[ "$1" = 'random' ]; then
            shift
            _show_random_pokemon $@
        else
            echo "Input error, too many arguments."
            exit 1
        fi
        ;;
esac

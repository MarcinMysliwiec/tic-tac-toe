#!/bin/bash

set=0
declare -a spots
declare -a users=(p1 c)
declare -a b=(. . . . . . . . . .)
declare -a ids=(o x)
declare -a starts=c

# Informacje o grze
usage()
{
cat<<_EOF_

  Dostepne parametry:
    --start           - Gracz rozpoczyna gre (domyslnie zaczyna komputer)
    --nought={param}  - Podmien 'o' na {param}
    --cross={param}   - Podmien 'x' na {param}
    --how-to-play     - Wyswietla zasady gry

  Zasady gry:
  * Na poczatku rozgrywki zostaniesz poproszony o wybrbanie figury.
  Figura zaczynajaca rozgrywke: 'o'
  * Mozesz korzystac tylko z niezajetych pol oznaczonych kropka: '.'
  * Wybor pola dokonywany jest poprzez wprowadzenie cyfry odpowiadajacej jednej z ponizszych pol:

	  #  1 | 2 | 3
	  #  --------
	  #  4 | 5 | 6
	  #  --------
	  #  7 | 8 | 9

  * Ture wygrywa gracz, ktoremu uda sie ulozyc ciagla linie (pozioma, pionowa, ukosna) z 3 figur
  * Skrypt na koniec rozgrywki poda wygranego lub oglosi remis w zaleznosci od wyniku
  * Aby wymusic zakonczenie wykonywania skryptu uzyj polecenia 'ctrl+c'

_EOF_
}

force_exit()
{
  clear
  echo -e "\n\nWcisnales ctrl+c. Opuszczasz gre.\nDo zobaczenia!\n"
  get_winner
  exit 1
}

# Wolne punkty na planszy
get_empty_spots()
{
 spots=""
 for i in {1..9}; do
   if [[ ${b[$i]} = "." ]]; then
     spots="$spots $i"
   fi
     aspots=${spots// /}
 done
     spots=${spots/ /}
}

# Generuj widok
generate_board()
{
clear

cat <<_EOF_
  ---  RUNDA $set  ---
---------------------
| P1 [$p1]  | C [$c]   |
---------------------
|    ${w1:-0}    |    ${w2:-0}    |
---------------------

    ${b[1]} | ${b[2]} | ${b[3]}
    ---------
    ${b[4]} | ${b[5]} | ${b[6]}
    ---------
    ${b[7]} | ${b[8]} | ${b[9]}

_EOF_
}

# Sprawdz dostepnosc danego pola
is_spot_free()
{
  local s=$1
  if [ "${b[$s]}" = '.' ]; then
    spot=$1
    b[$spot]=$c
    echo -e "Informacja: Komputer wybral wspolrzedne: $spot"
    ((moved+=1))   
  fi
}

computer_move()
{
  if [[ $moved -eq 0 ]]; then
    spot=$(shuf -e ${spots} -n 1)
    is_spot_free $spot
  fi
}

# Logika wylaniajaca wygranego
if_winner()
{
  local i=$1    # Pobierz parametr funkcji
  local v=0     # Wygrana  

  if [[ "${b[1]}" = "${!i}" ]] && [[ ${b[2]} = "${!i}" ]] && [[ ${b[3]} = "${!i}" ]]; then
    ((v+=1))  
  elif [[ "${b[1]}" = "${!i}" ]] && [[ ${b[4]} = "${!i}" ]] && [[ ${b[7]} = "${!i}" ]]; then
    ((v+=1))  
  elif [[ "${b[1]}" = "${!i}" ]] && [[ ${b[5]} = "${!i}" ]] && [[ ${b[9]} = "${!i}" ]]; then
    ((v+=1))  
  elif [[ "${b[2]}" = "${!i}" ]] && [[ ${b[5]} = "${!i}" ]] && [[ ${b[8]} = "${!i}" ]]; then
    ((v+=1))  
  elif [[ "${b[3]}" = "${!i}" ]] && [[ ${b[6]} = "${!i}" ]] && [[ ${b[9]} = "${!i}" ]]; then
    ((v+=1))  
  elif [[ "${b[3]}" = "${!i}" ]] && [[ ${b[5]} = "${!i}" ]] && [[ ${b[7]} = "${!i}" ]]; then
    ((v+=1))  
  elif [[ "${b[4]}" = "${!i}" ]] && [[ ${b[5]} = "${!i}" ]] && [[ ${b[6]} = "${!i}" ]]; then
    ((v+=1))  
  elif [[ "${b[7]}" = "${!i}" ]] && [[ ${b[8]} = "${!i}" ]] && [[ ${b[9]} = "${!i}" ]]; then
    ((v+=1))  
  fi

  if [[ "$i" = 'p1' ]]; then
      v1=$v
      w1=$((c1 + v))
  else
      v2=$v
      w2=$((c2 + v))
  fi

  if [[ ${v1} -gt ${v2} ]]; then
    return 0
  elif [[ ${v1} -lt ${v2} ]]; then
    return 0
  else
    return 1
  fi
}

# Logika wylaniajaca wygranego
get_winner()
{
  if [[ ${w1} -gt ${w2} ]]; then
    echo -e "\nInformacja: *Gracz wygral [${w1:-0}-${w2:-0}] w $set turach.*\n"
  elif [[ ${w1} -lt ${w2} ]]; then
    echo -e "\nInformacja: *Komputer wygral [${w1:-0}-${w2:-0}] w $set turach.*\n"
  else
    echo -e "\nInformacja: *Remis [${w1:-0}] w $set turach.*\n"
  fi
}

play()
{
  local u=$starts
  ((set+=1))
  get_empty_spots
  generate_board
  while [ ${#aspots} -ge 1 ]; do
    moved=0
    case $u in
      p1) get_empty_spots
          if [ ${#aspots} -lt 1 ]; then
            break
          fi
          while true; do
            read -p "Wybierz wspolrzedne [dostepne: ${aspots}]: " spot
            if [[ "${b[$spot]}" = '.' ]] && [[ ! -z $spot ]] && [[ ! $spot -gt 9 ]] && [[ ! "$spot" =~ [a-z] ]]; then
                b[$spot]=${p1}
              break
            else
              echo -e "Ostrzezenie: wspolrzedne sa niedozwolone"
            fi
          done
          generate_board
          if_winner p1 && { break; }
          u=c;;
      c ) get_empty_spots
          if [ ${#aspots} -lt 1 ]; then
            break
          fi
          computer_move
          generate_board
          if_winner c && { break; }
          u=p1;;
    esac
  done
  generate_board
  v1=0
  v2=0
}


### main ###
trap force_exit INT

# Pobierz parametry
optspec=":h-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in
                start)
                    starts=p1
                    ;;
                nought=*)
                    ids[0]=${OPTARG#*=}
                    ;;
                cross=*)
                    ids[1]=${OPTARG#*=}
                    ;;
                *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        echo -e "Blad: nieznany argument: ${OPTARG}"
                    fi
                    ;;
            esac;;
        h)
            usage
            exit 2
            ;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                echo -e "Blad: Brak opcji: '-${OPTARG}'"
            fi
            ;;
    esac
done

if [[ ${starts} = "p1" ]]; then
  p1=${ids[0]}
  c=${ids[1]}
else
  c=${ids[0]}
  p1=${ids[1]}
fi
play

while true; do
  read -p 'Informacja: chcesz zagrac ponownie? [y/n] ' yn
  case $yn in
    [Yy]) b=(. . . . . . . . . .)
          c1=${w1:-0}
          c2=${w2:-0}
          play;;
    [Nn]) clear
          get_winner
          echo -e "Informacja: do zobaczenia."
          exit 0;;
  esac 
done

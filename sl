#!/usr/bin/env bash
#
# sl is a utility to log usage of different skills

LOGFILE="$HOME/.skill-log/skill-log"

error() {
  if (( $? != 0 )); then
    echo "error: $*" >&2
    exit 1
  fi
}

mkdir -p "$(dirname "${LOGFILE}")" 2> /dev/null
error "could not access logfile directory ($(dirname LOGFILE))"

touch -a "${LOGFILE}" 2> /dev/null
error "could not access logfile (${LOGFILE})"

usage() {
  echo >&2 "usage: $0 [-h] [-l] [-r [[YYYY-]MM] [SKILL]] [SKILL]"
  echo >&2 "Log usage of arbitrary skills"
  echo >&2 "Default behavior is to log usage for given skill"
  echo >&2 " -h     display this help and exit"
  echo >&2 " -l     list all logged skills"
  echo >&2 " -r     print report"

  exit 0
}

cancel_input?() {
  echo "Confirm logging new skill: '""$1""' (y/n)"
  read -n1 input
  # print newline after input
  echo

  # don't cancel
  [[ $input =~ [yY] ]] && return 1

  return 0
}

log_skill() {
  # prompt confirmation to log a new skill in case of typo
  ! grep -q "$1" "${LOGFILE}" && cancel_input? "$1" && exit

  log_string="$1 $(date +%Y-%m-%d)"
  # duplicate skills on same day are NOT logged
  grep -q "${log_string}" "${LOGFILE}"
  found=$?

  if (( found == 0 )); then
    echo "Skill '${1}' already logged today."
  else
    echo "${log_string}" >> "${LOGFILE}"
  fi
}

list() {
  awk -e '{ skills[$1] += 1 }' \
      -e 'END { for (skill in skills) { print skill ": " skills[skill] } }' \
      "${LOGFILE}"
}

report() {
  timeperiod="$1"
  skill="$2"

  title="Skill log for ${timeperiod}"
  if [[ -n $skill ]]; then
    title+=" (${skill})"
  fi

  echo "${title}"
  awk -v TIMEPERIOD="${timeperiod}" \
      -v SKILL="${skill}" \
      -e '$2 ~ TIMEPERIOD { if((SKILL!="") && (SKILL==$1)){ skills[$1] += 1 } }' \
      -e '$2 ~ TIMEPERIOD { if(SKILL==""){ skills[$1] += 1 } }' \
      -e 'END { for (skill in skills) { print skill ": " skills[skill] } }' \
      "${LOGFILE}"
}

main() {
  while getopts "hlr:" opt; do
    case "${opt}" in
      l)    list
            exit
            ;;
      r)    month="$OPTARG"
            shift $(( OPTIND - 1))
            skill="$1"
            report "${month}" "${skill}"
            exit
            ;;
      h|*)  usage
            exit
            ;;
    esac
  done

  log_skill "$1"
}

main "$@"

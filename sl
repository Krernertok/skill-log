#!/usr/bin/env bash
#
# sl is a utility to log usage of different skills

LOGFILE="$HOME/.skill-log/skill-log"

error() {
  if (( $? != 0 )); then
    echo >&2 "error: $*"
    exit 1
  fi
}

mkdir -p "$(dirname "${LOGFILE}")" 2> /dev/null
error "could not access logfile directory ($(dirname LOGFILE))"

touch -a "${LOGFILE}" 2> /dev/null
error "could not access logfile (${LOGFILE})"

usage() {
  echo >&2 "usage: $0 [-h] [-l] [-r [YYYY[-MM]]] [SKILL]"
  echo >&2 "Log usage of arbitrary skills"
  echo >&2 "Default behavior is to log usage for given skill"
  echo >&2 " -h     display this help and exit"
  echo >&2 " -l     list all logged skills"
  echo >&2 " -r     print report"
}

validate_input() {
  type=$1
  shift

  case "$type" in
    log)
      if (( $# != 1 )); then
        echo >&2 "Incorrect number of arguments: '$*'"
        return 1
      fi
      ;;

    list)
      if (( $# > 1 )); then
        echo >&2 "Incorrect number of arguments: '$*'"
        return 1
      fi
      ;;

    report)
      # get rid of the flag itself
      shift
      if (( $# > 1 )); then
        echo >&2 "Incorrect number of arguments: '$*'"
        return 1
      fi
      time="$1"
      if [[ ! $time =~ [[:digit:]]{4}([./-][[:digit:]]{2})? ]]; then
        echo >&2 "Incorrect format: '${time}'."
        return 1
      fi
      ;;
  esac
}

prompt_cancel_input() {
  echo "Confirm logging new skill: '""$1""' (y/n)"
  read -r -n1 input
  # print newline after input
  echo

  # don't cancel
  [[ $input =~ [yY] ]] && return 1

  return 0
}

log_skill() {
  ! validate_input "log" "$@" && usage && exit 1

  # prompt confirmation to log a new skill in case of typo
  ! grep -q "$1" "${LOGFILE}" && prompt_cancel_input "$1" && exit

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
  title="Skill log for ${timeperiod}"

  echo "${title}"
  awk -v TIMEPERIOD="${timeperiod}" \
      -e '$2 ~ TIMEPERIOD { skills[$1] += 1 }' \
      -e 'END { for (skill in skills) { print skill ": " skills[skill] } }' \
      "${LOGFILE}"
}

main() {
  while getopts "hlr:" opt; do
    case "${opt}" in
      l)    ! validate_input "list" "$@" && usage && exit 1
            list
            exit
            ;;
      r)    ! validate_input "report" "$@" && usage && exit 1
            month="$OPTARG"
            shift $(( OPTIND - 1))
            skill="$1"
            report "${month}" "${skill}"
            exit
            ;;
      h|*)  ! validate_input
            usage
            exit
            ;;
    esac
  done

  log_skill "$1"
}

main "$@"

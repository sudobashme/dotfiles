# Force path arrays to have unique values only
typeset -U path cdpath fpath manpath


alias path='echo -e ${PATH//:/\\n}'
alias fpath='echo -e ${FPATH//:/\\n}'

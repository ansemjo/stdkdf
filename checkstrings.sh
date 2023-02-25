#!/usr/bin/env bash
# check some test passwords to see whether the output remains the same between versions
# table created with stdkdf v1.0, development (linux/amd64, runtime go1.20) [git r34-g7b41db7]

# function that checks given test strings
checkpw() {
  err=0;
  grep -v '^#' | while read salt password cost shouldbe; do
    printf "stdkdf(%s, %s, %6s)" "$salt" "$password" "$cost";
    result=$(./stdkdf -salt "$salt" -cost "$cost" <<<"$password");
    if [[ $result != $shouldbe ]]; then
      printf " != %s (ERR)\n" "$shouldbe";
      err=1;
    else
      printf " == %s\n" "$shouldbe";
    fi
  done
  exit "$err";
}

# check if binary exists
[[ -x ./stdkdf ]] || {
  echo "ERR: executable ./stdkdf not found" >&2;
  exit 1;
}

cat <<'EOF' | checkpw
# salt                    password                  cost      result
HrCvKHBTB3QS72fE4muCjpLa  84ynY7KSNU9AFxRXYLefg7Se  low       U/6prrqQ0RJUhv0yK6DwtxTSTvIZnPUXJgegoSObcT0=
HrCvKHBTB3QS72fE4muCjpLa  84ynY7KSNU9AFxRXYLefg7Se  normal    9y7IYAIZ0pfGEuLB2J3Pb08DErmqsZkvP+08X7YyCoI=
HrCvKHBTB3QS72fE4muCjpLa  84ynY7KSNU9AFxRXYLefg7Se  high      brFMkbhxvtG71UptgyD0up4p1YsC010lqA2gisOqiQE=
XW2E28rR5Ldz9X34uzRKvsxJ  aqrw3ksMucgGxtyyHUYsRtL4  low       /WLcq8hUD8zkjzFNdrWrQiLlfeBBgmz1PDfJXEHADTM=
XW2E28rR5Ldz9X34uzRKvsxJ  aqrw3ksMucgGxtyyHUYsRtL4  normal    o8DSVqBQMBBpcrdyV8+wf9r8iVzlvCLJpa2Dc68maR8=
XW2E28rR5Ldz9X34uzRKvsxJ  aqrw3ksMucgGxtyyHUYsRtL4  high      B/Wf/l/Zcr0zE61KpB38o/ca98QdXSijQjALbVMewj0=
nZEuZuCAgy5waYVLn9bNXrWR  YRXfCtX7AUMX7HVa8CBRtc5k  low       odtIGLwYSix8/TGNHZ4KCLw/eLJTylsTGaZRxd1vvr8=
nZEuZuCAgy5waYVLn9bNXrWR  YRXfCtX7AUMX7HVa8CBRtc5k  normal    l4Ph/bXW7rNbVRAR8tsrP+FnLjdlzfnZT1E01vya4kE=
nZEuZuCAgy5waYVLn9bNXrWR  YRXfCtX7AUMX7HVa8CBRtc5k  high      yyJvJaqcPaoWZJmds0MQptRGgulLK9lT+whG8lwsJ0A=
y83bCu3fARxGyxVuK7WzV85s  EhyzXDd9FpXS4R5SMDy7VSp9  low       Wle/tuEPK9LOYo500wAgNyn1181cvXvj92wBusQziRE=
y83bCu3fARxGyxVuK7WzV85s  EhyzXDd9FpXS4R5SMDy7VSp9  normal    ECf04HxusLNScoMe0NKl4dn5Z5JWzK9l5owIWReYWzc=
y83bCu3fARxGyxVuK7WzV85s  EhyzXDd9FpXS4R5SMDy7VSp9  high      WisWVNLTVxJItG9qq0VkHx02xu2xXt5bqvDe4r8WU74=
Z82DvzchznbQzkwYk4CgeKDg  bUrkdHsT58vLSh6aPH6jmzQb  low       +d5g+Ii3B9+P7mNgWuZCYY7KXxXWzO2Ee2Dn5HJ67zM=
Z82DvzchznbQzkwYk4CgeKDg  bUrkdHsT58vLSh6aPH6jmzQb  normal    mmBwpcqstotpKQJ57DIJs6d8582EgZvdwxhIncdhmqE=
Z82DvzchznbQzkwYk4CgeKDg  bUrkdHsT58vLSh6aPH6jmzQb  high      TwlDT8//aPMExuEeU0Al4wFylyIcZoMukQuqzsCySQ8=
gF6Y6vW55zy4npmYew62DkFQ  SE6Dc6apSNMNZ4GPaKnBhkPJ  low       CkbvOmrrU093J0FISGwb6X0W4PjYnrEqJkpRwGcNVQI=
gF6Y6vW55zy4npmYew62DkFQ  SE6Dc6apSNMNZ4GPaKnBhkPJ  normal    E50B+yN0qnCpFoKU20MR2W7Q2jctG1PVWzuVIi9EeCk=
gF6Y6vW55zy4npmYew62DkFQ  SE6Dc6apSNMNZ4GPaKnBhkPJ  high      tzvLlaEEfkr7ALpS0xNy++7WYnLxuLEyK2PC2F4Lnec=
nZUENTFpKyN5Z55ArN3xU97P  bGgYUJZ5FRKM48Q8AZuuWwJE  low       HpA5uvayFdaJ+7ZFaQvbsusa6U9/UeTp9kZ9YIDHX3U=
nZUENTFpKyN5Z55ArN3xU97P  bGgYUJZ5FRKM48Q8AZuuWwJE  normal    dUA2keD75tMOkXATSTood8aKObk6no7JbhNr3T+8eiw=
nZUENTFpKyN5Z55ArN3xU97P  bGgYUJZ5FRKM48Q8AZuuWwJE  high      ECaevaDz/X7xCljSp0flVTbGQM6++6jYGWlKPTqx6HY=
5fqSMmQXF4r8KJA9GgMDsQZj  8WQGLxn2Xc2KSkse4Nt3tvmt  low       Rr3LIsy3aUEOi9Qm8j7qyFs7SykaB2374/jJrK9b1dU=
5fqSMmQXF4r8KJA9GgMDsQZj  8WQGLxn2Xc2KSkse4Nt3tvmt  normal    ajZyX25LpY4tfRQMcBcdc7jt4GUcHLY+YgoMlaaMj8Y=
5fqSMmQXF4r8KJA9GgMDsQZj  8WQGLxn2Xc2KSkse4Nt3tvmt  high      AA5TZ6s0lfcytihQmgrSujWvfU2+BEfnOBhxVg7K9KI=
WuNHjtBjT5Xh543cFRg5jZHw  MQEdXmnR7FLhHKuqQdK9J9yM  low       AYkcKOXgs+u5tEWVJcbkMiA5xueoj3pAkEDbLMsRJv0=
WuNHjtBjT5Xh543cFRg5jZHw  MQEdXmnR7FLhHKuqQdK9J9yM  normal    v+LPHlaAlmZJBu8PEgEoinnU9bLfRclrJxBLYa03itQ=
WuNHjtBjT5Xh543cFRg5jZHw  MQEdXmnR7FLhHKuqQdK9J9yM  high      o3kvpUyNG98bkZVKj9aRSl2PbBPoliDfodeDaVdeeQI=
cEmVJrwMVFAWZqvwtx3kLfUz  YpaANbWATAe8cP2UuhGDaVzb  low       95uKqzYbBUDogkTgEMsatm2/dUDqQp/rn2c4W20nqqo=
cEmVJrwMVFAWZqvwtx3kLfUz  YpaANbWATAe8cP2UuhGDaVzb  normal    poQSfqQTUUeAFs5VoDqKpa+e8o2fDo9vKkW0kFGsxiM=
cEmVJrwMVFAWZqvwtx3kLfUz  YpaANbWATAe8cP2UuhGDaVzb  high      f+vEoMx9SOaX4SNaTYauzIUSrnktwJuDIRB/BnfDWvk=
EOF

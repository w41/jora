rm jora.sqlite && cat jora.sqlite-bootstrap | sqlite3 jora.sqlite

cat >jora.cfg <<EOF
[sqlite]
filename=jora.sqlite
tasks=tasks
users=users
EOF
 


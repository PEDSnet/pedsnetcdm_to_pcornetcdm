OLD_PASS=$PGPASSWORD

function finish {
  export PGPASSWORD=$OLD_PASS
}
trap finish EXIT

echo "Enter DB password"
read -s PGPASSWORD
export PGPASSWORD=$PGPASSWORD

for csvfile in load/*.csv
do
    header=$(head -n 1 $csvfile)
    table=${csvfile##*/}
    table=${table%%.*}
    echo "Loading $table from $csvfile"
    psql -h $1 -d $2 -c "\copy $3.$table($header) from '$csvfile' DELIMITER ',' CSV HEADER"
done

#! @shell@

COMMAND=$1
shift
exec @kythe@/tools/http_server --serving_table "@out@/share/tbl" \
                               --listen=localhost:8080 \
                               --public_resources "@kythe@/web/ui"

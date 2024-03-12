#!/usr/bin/bash
timestamp=`date +%Y-%m-%d_%H-%M-%S` 
exec mail -s "Egmond : Reset ot fhe router " andreas@jablonowski.be -a From:egmond176@jablonowski.be << EOF
The router has been resetet $timestamp
EOF
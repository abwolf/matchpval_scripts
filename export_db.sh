#!/bin/bash

sqlite3 -header -csv "$1" "select * from match_pct_counts;"

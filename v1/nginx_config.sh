#!/usr/bin/env bash
set -eu

# Create correct configuration file for NGINX

cur_path="$(cd "$(dirname "$0")" ; pwd)"

conf_template="$cur_path/template/nginx.conf.template"
output_file="$PWD/nginx.conf"

###### Parameter
couloir="${1:-}"
if [[ -z "$couloir" ]]; then
	echo "!!! Parametre demande"
	echo "appel du script : $0 <COULOIR>"
	echo "exemple : $0 int1"
	exit 1	
fi

if [ "$couloir" = "prod" ]; then
    couloir=""
fi

cat "$conf_template" |\
	sed "s/#COULOIR#/$couloir/g" |\
	cat > "$output_file"

echo "Fichier de sortie : $output_file"


#__EOF__

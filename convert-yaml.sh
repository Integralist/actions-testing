# 2.7.0p0 is default, and permitted_classes isn't supported in that version
# ruby -rjson -ryaml -e "puts YAML.load_file('test.yml', permitted_classes: [Time]).to_json" | jq
ruby -rjson -ryaml -e "puts YAML.load_file('test.yml').to_json" | jq

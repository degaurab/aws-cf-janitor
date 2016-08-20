json.extract! aws_datum, :id, :aws_access_key, :aws_secret_key, :manifest_template, :created_at, :updated_at
json.url aws_datum_url(aws_datum, format: :json)
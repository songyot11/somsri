json.total @parents.count
json.rows @parents.limit(params[:limit]).offset(params[:offset]).as_json({ index: true })

json.array!(@mailers) do |mailer|
  json.extract! mailer, :id, :title, :subject, :body
  json.url mailer_url(mailer, format: :json)
end

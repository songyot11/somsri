old_handler = I18n.exception_handler
I18n.exception_handler = lambda do |exception, locale, key, options|
  case exception
  when I18n::MissingTranslation
    return key
  else
    old_handler.call(exception, locale, key, options)
  end
end
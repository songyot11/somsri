namespace :db do
  namespace :cms do
    desc "Prepare data for CMS"
    task :seeds,  [] => :environment do |t, args|
      if Comfy::Cms::Site.count == 0
          Comfy::Cms::Site.create!({label: 'Somsri School', identifier: 'default', hostname: 'localhost', locale: 'en', is_mirrored: 'f'})
      end
    end
  end
end

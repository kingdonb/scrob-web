require 'active_support/core_ext'
require 'active_support/encrypted_configuration'

# Define a development Kuby deploy environment
Kuby.define('Scrob') do
  environment(:development) do
    # Because the Rails environment isn't always loaded when
    # your Kuby config is loaded, provide access to Rails
    # credentials manually.
    app_creds = ActiveSupport::EncryptedConfiguration.new(
      config_path: File.join('config', 'credentials.yml.enc'),
      key_path: File.join('config', 'master.key'),
      env_key: 'RAILS_MASTER_KEY',
      raise_if_missing_key: true
    )

    docker do
      credentials do
        username ENV['HARBOR_BOT_USER']
        password ENV['HARBOR_BOT_PASSWORD']
        email app_creds[:KUBY_DOCKER_EMAIL]
      end

      image_url 'img.hephy.pro/scrob/web'
    end

    kubernetes do
      provider :bare_metal

      # Add a plugin that facilitates deploying a Rails app.
      add_plugin :rails_app do
        hostname 'scrob-dev.hephy.pro'

        manage_database false
        ingress_class 'public'

        env do
          data do
            add 'RAILS_LOG_TO_STDOUT', 'yes'
            add 'DATABASE_URL', 'nulldb://nohost'
            # add 'RAILS_ENV', 'development'
          end
        end
      end
    end
  end
end

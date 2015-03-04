require 'middleman_prismic/version'
require 'middleman_prismic/commands/prismic'

module MiddlemanPrismic
  class << self
    attr_reader :options
  end

  class Core < Middleman::Extension

    option :api_url, nil, 'The prismic api url'
    option :release, 'master', 'Content release'
    option(
      :link_resolver,
      ->(link) {"http://www.example.com/#{link.type.pluralize}/#{link.slug}"},
      'The link resolver'
    )
    option :custom_queries, {}, 'Custom queries'

    def initialize(app, options_hash={}, &block)
      super

      MiddlemanPrismic.instance_variable_set('@options', options)
    end

    helpers do
      Dir["data/prismic_*"].each do |file|
        define_method(file.gsub('data/prismic_','')) do
          YAML::load(File.read(file))
        end
      end

      def reference
        ref = YAML::load(File.read('data/prismic_reference'))
        ref.class.send(
          :define_method, :link_to, MiddlemanPrismic.options.link_resolver
        )

        return ref
      end
    end
  end

end

::Middleman::Extensions.register(:prismic, MiddlemanPrismic::Core)

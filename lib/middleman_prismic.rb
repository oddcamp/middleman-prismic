require 'middleman_prismic/version'
require 'middleman_prismic/commands/prismic'

module MiddlemanPrismic
  class << self
    attr_reader :options
  end

  class Core < Middleman::Extension

    option :api_url, nil, 'The prismic api url'
    option :release

    def initialize(app, options_hash={}, &block)
      super

      MiddlemanPrismic.instance_variable_set('@options', options)
    end
  end

end

::Middleman::Extensions.register(:prismic, MiddlemanPrismic::Core)

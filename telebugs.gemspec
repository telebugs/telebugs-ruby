# frozen_string_literal: true

require_relative "lib/telebugs/version"

Gem::Specification.new do |spec|
  spec.name = "telebugs"
  spec.version = Telebugs::VERSION
  spec.authors = ["Kyrylo Silin"]
  spec.email = ["help@telebugs.com"]

  spec.summary = "Report errors to Telebugs with the offical Ruby SDK"
  spec.description = <<~DESC
    Telebugs Ruby is an SDK for Telebugs (https://telebugs.com/), a simple error monitoring tool for developers. With
    Telebugs, you can track production errors in real-time and report them to Telegram.
  DESC

  spec.homepage = "https://telebugs.com"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/telebugs/telebugs-ruby"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", "~> 1.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end

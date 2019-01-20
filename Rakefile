# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  task :coverage do
    ENV["COVERAGE"] = "true"
    Rake::Task["spec"].invoke
  end
end

task default: :spec

task :clean do
  FileUtils.rm_r ".yardoc" if Dir.exist?(".yardoc")
  FileUtils.rm_r "doc" if Dir.exist?("doc")
  FileUtils.rm_r "pkg" if Dir.exist?("pkg")
  FileUtils.rm_r "coverage" if Dir.exist?("coverage")
end

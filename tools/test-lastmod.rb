# frozen_string_literal: true

# 无需启动 Jekyll：验证插件在真实 Git 历史和特殊文件名下的行为。
require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'open3'

module Jekyll
  module Hooks
    class << self
      attr_reader :callback

      def register(*_args, &block)
        @callback = block
      end
    end
  end
end

require_relative '../_plugins/posts-lastmod-hook'

class PostsLastmodTest < Minitest::Test
  def test_history_with_special_characters_and_different_working_directory
    Dir.mktmpdir('jekyll-lastmod') do |source|
      git(source, 'init', '--quiet')
      git(source, 'config', 'user.name', 'Plugin Test')
      git(source, 'config', 'user.email', 'test@example.invalid')
      FileUtils.mkdir_p(File.join(source, '_posts'))
      path = '_posts/2026-01-01-$HOME-"quoted".md'
      full_path = File.join(source, path)
      File.write(full_path, 'first version')
      site = Struct.new(:source).new(source)
      post = Struct.new(:site, :path, :data).new(site, full_path, {})

      # 未跟踪的文件、只提交一次的新文章均不应设置修改日期。
      Jekyll::Hooks.callback.call(post)
      refute post.data.key?('last_modified_at')
      git(source, 'add', '--', path)
      git(source, 'commit', '--quiet', '-m', 'Add post')
      Jekyll::Hooks.callback.call(post)
      refute post.data.key?('last_modified_at')

      File.write(full_path, 'second version')
      git(source, 'commit', '--quiet', '-am', 'Update post')
      Jekyll::Hooks.callback.call(post)
      expected = git(source, 'log', '-1', '--format=%aI', '--', path).strip
      assert_equal expected, post.data['last_modified_at']
    end
  end

  private

  def git(source, *args)
    output, status = Open3.capture2e('git', '-C', source, *args)
    assert status.success?, output
    output
  end
end

#!/usr/bin/env ruby
#
# Check for changed posts

require 'open3'

Jekyll::Hooks.register :posts, :post_init do |post|
  # 以独立参数传递路径，避免文件名被 shell 展开；从站点源码目录读取历史。
  source = post.site.source
  commit_num, _error, status = Open3.capture3('git', '-C', source, 'rev-list', '--count',
                                            'HEAD', '--', post.path)

  if status.success? && commit_num.to_i > 1
    lastmod_date, _error, status = Open3.capture3('git', '-C', source, 'log', '-1',
                                                '--format=%aI', '--', post.path)
    post.data['last_modified_at'] = lastmod_date.strip if status.success? && !lastmod_date.strip.empty?
  end
end

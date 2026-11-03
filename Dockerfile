FROM docker.io/ruby:3.4

WORKDIR /app

# 可选国内镜像源，加速 bundle install，例如：
#   docker build --build-arg RUBYGEMS_MIRROR=https://mirrors.huaweicloud.com/repository/rubygems -t leetcode-jekyll:latest .
ARG RUBYGEMS_MIRROR=

# 先只复制依赖文件，利用层缓存：仅当 Gemfile/Gemfile.lock 变化时才重新 bundle install
COPY Gemfile Gemfile.lock ./
RUN if [ -n "$RUBYGEMS_MIRROR" ]; then \
        bundle config mirror.https://rubygems.org "$RUBYGEMS_MIRROR" && \
        bundle config mirror.https://index.rubygems.org "$RUBYGEMS_MIRROR"; \
    fi \
    && bundle install

# 复制源码（源码变更不会使上方的 bundle install 层失效）
COPY . .

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--port", "4000"]

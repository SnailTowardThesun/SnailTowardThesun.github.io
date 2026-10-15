FROM ruby:3.4
WORKDIR /app
# 先只拷贝 Gemfile 以利用层缓存：Gemfile 不变时不会重新装依赖
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
CMD ["bundle", "exec", "jekyll", "build"]

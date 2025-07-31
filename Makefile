# Jekyll项目快捷命令

.PHONY: serve build clean install help

# 默认命令
default: serve

# 启动开发服务器
serve:
	bundle exec jekyll serve --host 0.0.0.0 --port 4000 --livereload

# 启动开发服务器（后台运行）
serve-bg:
	bundle exec jekyll serve --host 0.0.0.0 --port 4000 --livereload --detach

# 启动开发服务器（草稿模式）
serve-draft:
	bundle exec jekyll serve --host 0.0.0.0 --port 4000 --livereload --drafts

# 构建网站
build:
	bundle exec jekyll build

# 构建生产环境网站
build-prod:
	JEKYLL_ENV=production bundle exec jekyll build

# 清理生成的文件
clean:
	bundle exec jekyll clean

# 安装依赖
install:
	bundle install

# 更新依赖
update:
	bundle update

# 检查网站
doctor:
	bundle exec jekyll doctor

# 显示帮助信息
help:
	@echo "Jekyll项目快捷命令："
	@echo "  make serve       - 启动开发服务器"
	@echo "  make serve-bg    - 后台启动开发服务器"
	@echo "  make serve-draft - 启动开发服务器（包含草稿）"
	@echo "  make build       - 构建网站"
	@echo "  make build-prod  - 构建生产环境网站"
	@echo "  make clean       - 清理生成的文件"
	@echo "  make install     - 安装依赖"
	@echo "  make update      - 更新依赖"
	@echo "  make doctor      - 检查网站配置"